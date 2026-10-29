import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ielts_simulator/core/result.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Records the candidate's spoken answers to files in app storage.
abstract interface class RecorderService {
  Future<bool> requestPermission();

  /// Starts recording to a new file named after [name]; returns its path.
  Future<Result<String, MediaFailure>> start(String name);

  /// Stops the current recording; returns the file path, if any.
  Future<String?> stop();

  Future<void> dispose();
}

class DeviceRecorderService implements RecorderService {
  final AudioRecorder _recorder = AudioRecorder();

  @override
  Future<bool> requestPermission() => _recorder.hasPermission();

  @override
  Future<Result<String, MediaFailure>> start(String name) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final folder = await Directory('${directory.path}/recordings').create(recursive: true);
      final path = '${folder.path}/$name.m4a';
      await _recorder.start(const RecordConfig(numChannels: 1), path: path);
      return Ok(path);
    } on Exception catch (error) {
      return Err(MediaFailure('record', cause: error));
    }
  }

  @override
  Future<String?> stop() => _recorder.stop();

  @override
  Future<void> dispose() => _recorder.dispose();
}

final Provider<RecorderService> recorderServiceProvider = Provider.autoDispose<RecorderService>((
  ref,
) {
  final service = DeviceRecorderService();
  ref.onDispose(service.dispose);
  return service;
});
