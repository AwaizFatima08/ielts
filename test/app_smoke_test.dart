import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ielts_simulator/app.dart';
import 'package:ielts_simulator/attempts/attempt_repository.dart';
import 'package:ielts_simulator/content/models/papers.dart';
import 'package:ielts_simulator/settings/settings_repository.dart';

class _MemoryStore implements AttemptStore {
  String? contents;

  @override
  Future<String?> read() async => contents;

  @override
  Future<void> write(String contents) async => this.contents = contents;
}

class _FakeSettings implements SettingsRepository {
  ExamModule? stored;

  @override
  Future<ExamModule?> module() async => stored;

  @override
  Future<void> setModule(ExamModule module) async => stored = module;
}

void main() {
  testWidgets('first launch asks for the module, then lists the tests', (tester) async {
    final settings = _FakeSettings();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          attemptStoreProvider.overrideWithValue(_MemoryStore()),
          settingsRepositoryProvider.overrideWithValue(settings),
        ],
        child: const IeltsApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('General Training'), findsOneWidget);
    await tester.tap(find.text('Academic'));
    await tester.pumpAndSettle();

    expect(settings.stored, ExamModule.academic);
    expect(find.text('Test 1'), findsOneWidget);
    expect(find.text('Coming soon'), findsWidgets);
  });
}
