import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ielts_simulator/content/models/json_reader.dart';
import 'package:ielts_simulator/content/models/papers.dart';
import 'package:ielts_simulator/content/models/practice.dart';
import 'package:ielts_simulator/core/result.dart';

/// Reads bundled exam and practice content. Read-only; never throws.
class ContentRepository {
  ContentRepository(this._bundle);

  final AssetBundle _bundle;
  static const _root = 'assets/content';

  Future<Result<T, ContentFailure>> _load<T>(String path, T Function(Json) parse) async {
    try {
      final raw = await _bundle.loadString('$_root/$path');
      return Ok(parse(jsonDecode(raw) as Json));
      // Asset loading reports a missing file as a FlutterError, and a bad
      // field shape surfaces as a TypeError from the casts in fromJson.
      // ignore: avoid_catching_errors
    } on FlutterError catch (error) {
      return Err(ContentFailure('missing:$path', cause: error));
    } on FormatException catch (error) {
      return Err(ContentFailure('malformed:$path', cause: error));
      // ignore: avoid_catching_errors — see the note on FlutterError above.
    } on TypeError catch (error) {
      return Err(ContentFailure('malformed:$path', cause: error));
    }
  }

  Future<Result<List<TestSummary>, ContentFailure>> tests() => _load(
    'tests/index.json',
    (json) => json.objectList('tests').map(TestSummary.fromJson).toList(),
  );

  Future<Result<ListeningPaper, ContentFailure>> listening(String testId) =>
      _load('tests/$testId/listening.json', ListeningPaper.fromJson);

  Future<Result<ReadingPaper, ContentFailure>> reading(String testId, ExamModule module) =>
      _load('tests/$testId/reading_${module.name}.json', ReadingPaper.fromJson);

  Future<Result<WritingPaper, ContentFailure>> writing(String testId, ExamModule module) =>
      _load('tests/$testId/writing_${module.name}.json', WritingPaper.fromJson);

  Future<Result<SpeakingPaper, ContentFailure>> speaking(String testId) =>
      _load('tests/$testId/speaking.json', SpeakingPaper.fromJson);

  Future<Result<List<PracticeUnitSummary>, ContentFailure>> practiceUnits() => _load(
    'practice/index.json',
    (json) => json.objectList('units').map(PracticeUnitSummary.fromJson).toList(),
  );

  Future<Result<PracticeUnit, ContentFailure>> practiceUnit(String id) =>
      _load('practice/$id.json', PracticeUnit.fromJson);

  Future<Result<Descriptors, ContentFailure>> descriptors() =>
      _load('descriptors.json', Descriptors.fromJson);
}

final assetBundleProvider = Provider<AssetBundle>((ref) => rootBundle);

final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => ContentRepository(ref.watch(assetBundleProvider)),
);

/// Unwraps a content result for a `FutureProvider`: failures surface as
/// `AsyncError` carrying the typed [ContentFailure].
T unwrapContent<T>(Result<T, ContentFailure> result) => switch (result) {
  Ok(:final value) => value,
  Err(:final failure) => throw failure,
};

final testsProvider = FutureProvider<List<TestSummary>>(
  (ref) async => unwrapContent(await ref.watch(contentRepositoryProvider).tests()),
);

final listeningPaperProvider = FutureProvider.family<ListeningPaper, String>(
  (ref, testId) async =>
      unwrapContent(await ref.watch(contentRepositoryProvider).listening(testId)),
);

final readingPaperProvider = FutureProvider.family<ReadingPaper, (String, ExamModule)>(
  (ref, key) async =>
      unwrapContent(await ref.watch(contentRepositoryProvider).reading(key.$1, key.$2)),
);

final writingPaperProvider = FutureProvider.family<WritingPaper, (String, ExamModule)>(
  (ref, key) async =>
      unwrapContent(await ref.watch(contentRepositoryProvider).writing(key.$1, key.$2)),
);

final speakingPaperProvider = FutureProvider.family<SpeakingPaper, String>(
  (ref, testId) async => unwrapContent(await ref.watch(contentRepositoryProvider).speaking(testId)),
);

final practiceUnitsProvider = FutureProvider<List<PracticeUnitSummary>>(
  (ref) async => unwrapContent(await ref.watch(contentRepositoryProvider).practiceUnits()),
);

final practiceUnitProvider = FutureProvider.family<PracticeUnit, String>(
  (ref, id) async => unwrapContent(await ref.watch(contentRepositoryProvider).practiceUnit(id)),
);

final descriptorsProvider = FutureProvider<Descriptors>(
  (ref) async => unwrapContent(await ref.watch(contentRepositoryProvider).descriptors()),
);
