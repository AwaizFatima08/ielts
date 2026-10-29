import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ielts_simulator/app.dart';
import 'package:ielts_simulator/attempts/attempt.dart';
import 'package:ielts_simulator/attempts/attempt_repository.dart';
import 'package:ielts_simulator/content/content_repository.dart';
import 'package:ielts_simulator/content/models/papers.dart';
import 'package:ielts_simulator/core/result.dart';
import 'package:ielts_simulator/services/audio_service.dart';
import 'package:ielts_simulator/services/recorder_service.dart';
import 'package:ielts_simulator/settings/settings_repository.dart';

/// Reads assets straight from disk, synchronously: the default bundle
/// decodes large files on an isolate, which never runs under fake time.
class _DiskBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async => ByteData.sublistView(File(key).readAsBytesSync());

  @override
  Future<String> loadString(String key, {bool cache = true}) async => File(key).readAsStringSync();
}

class _MemoryStore implements AttemptStore {
  String? contents;

  @override
  Future<String?> read() async => contents;

  @override
  Future<void> write(String contents) async => this.contents = contents;
}

class _FakeSettings implements SettingsRepository {
  @override
  Future<ExamModule?> module() async => ExamModule.academic;

  @override
  Future<void> setModule(ExamModule module) async {}
}

/// No clips bundled: the listening engine falls back to timed gaps.
class _SilentAudio implements AudioService {
  @override
  Future<bool> hasAsset(String assetPath) async => false;

  @override
  Future<Result<void, MediaFailure>> playAsset(String assetPath) async => const Ok(null);

  @override
  Future<Result<void, MediaFailure>> playFile(String filePath) async => const Ok(null);

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

class _FakeRecorder implements RecorderService {
  String? _current;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<Result<String, MediaFailure>> start(String name) async => Ok(_current = '/tmp/$name.m4a');

  @override
  Future<String?> stop() async => _current;

  @override
  Future<void> dispose() async {}
}

/// Pumps fixed steps: the listening engine and timers never fully settle.
Future<void> _settle(WidgetTester tester) async {
  for (var step = 0; step < 10; step++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _submitSection(WidgetTester tester) async {
  await tester.tap(find.text('Submit').first);
  await _settle(tester);
  await tester.tap(find.widgetWithText(FilledButton, 'Submit'));
  await _settle(tester);
}

void main() {
  testWidgets('a full Academic test runs from Listening to the report', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    final store = _MemoryStore();
    final container = ProviderContainer(
      overrides: [
        assetBundleProvider.overrideWithValue(_DiskBundle()),
        attemptStoreProvider.overrideWithValue(store),
        settingsRepositoryProvider.overrideWithValue(_FakeSettings()),
        audioServiceProvider.overrideWithValue(_SilentAudio()),
        recorderServiceProvider.overrideWithValue(_FakeRecorder()),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const IeltsApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Test 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Full test'));
    await _settle(tester);

    // Listening: start, type one answer, submit early.
    expect(find.text('INSTRUCTIONS TO CANDIDATES'), findsOneWidget);
    await tester.tap(find.text('Start'));
    await tester.pump(const Duration(seconds: 1));
    await tester.enterText(find.byType(TextField).first, 'test');
    await tester.pump();
    await _submitSection(tester);

    // Reading: start, flip to questions, submit.
    expect(find.text('Academic Reading'), findsWidgets);
    await tester.tap(find.text('Start'));
    await _settle(tester);
    await tester.tap(find.text('Questions'));
    await _settle(tester);
    expect(tester.takeException(), isNull);
    await _submitSection(tester);

    // Writing: start, write a little, submit.
    expect(find.text('Academic Writing'), findsWidgets);
    await tester.tap(find.text('Start'));
    await _settle(tester);
    await tester.enterText(find.byType(TextField).first, 'The line graph shows four sources.');
    await tester.pump();
    await _submitSection(tester);

    // Speaking: step through every examiner turn.
    expect(find.text('Speaking'), findsWidgets);
    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    for (var turn = 0; turn < 40 && find.byType(FilledButton).evaluate().isNotEmpty; turn++) {
      final button = find.widgetWithText(FilledButton, 'Next').evaluate().isNotEmpty
          ? find.widgetWithText(FilledButton, 'Next')
          : find.widgetWithText(FilledButton, 'Start speaking');
      if (button.evaluate().isEmpty) break;
      await tester.tap(button);
      await _settle(tester);
    }
    await _settle(tester);

    expect(find.text('Test report'), findsOneWidget);
    final attempt = (await container.read(attemptRepositoryProvider).watchAll().first).single;
    expect(attempt.isComplete, isTrue);
    expect(attempt.listening, isNotNull);
    expect(attempt.reading?.rawScore, 0);
    expect(attempt.essays.first, contains('line graph'));
    expect(attempt.recordings, isNotEmpty);
    expect(attempt.finishedSections, ExamSection.values);
  });
}
