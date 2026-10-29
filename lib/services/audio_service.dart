import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ielts_simulator/content/content_repository.dart';
import 'package:ielts_simulator/core/result.dart';
import 'package:just_audio/just_audio.dart';

/// Plays listening clips and the candidate's own recordings.
abstract interface class AudioService {
  /// Whether a bundled clip exists (homidev audio may not be generated yet).
  Future<bool> hasAsset(String assetPath);

  /// Plays a bundled clip; completes when it finishes or is stopped.
  Future<Result<void, MediaFailure>> playAsset(String assetPath);

  /// Plays a recording from disk; completes when it finishes or is stopped.
  Future<Result<void, MediaFailure>> playFile(String filePath);

  Future<void> stop();

  Future<void> dispose();
}

class JustAudioService implements AudioService {
  JustAudioService(this._bundle);

  final AssetBundle _bundle;
  final AudioPlayer _player = AudioPlayer();
  Set<String>? _assets;

  @override
  Future<bool> hasAsset(String assetPath) async {
    _assets ??= (await AssetManifest.loadFromAssetBundle(_bundle)).listAssets().toSet();
    return _assets!.contains(assetPath);
  }

  @override
  Future<Result<void, MediaFailure>> playAsset(String assetPath) =>
      _play(() => _player.setAsset(assetPath));

  @override
  Future<Result<void, MediaFailure>> playFile(String filePath) =>
      _play(() => _player.setFilePath(filePath));

  Future<Result<void, MediaFailure>> _play(Future<Duration?> Function() load) async {
    try {
      await load();
      await _player.play(); // completes on finish, pause or stop
      await _player.stop();
      return const Ok(null);
    } on PlayerException catch (error) {
      return Err(MediaFailure('playback', cause: error));
    } on PlayerInterruptedException catch (error) {
      return Err(MediaFailure('interrupted', cause: error));
    }
  }

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() => _player.dispose();
}

/// One player per screen that needs it; disposed with the screen.
final Provider<AudioService> audioServiceProvider = Provider.autoDispose<AudioService>((ref) {
  final service = JustAudioService(ref.watch(assetBundleProvider));
  ref.onDispose(service.dispose);
  return service;
});
