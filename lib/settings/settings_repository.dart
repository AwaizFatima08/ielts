import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ielts_simulator/content/models/papers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores small preferences: the module the candidate is preparing for.
class SettingsRepository {
  SettingsRepository(this._preferences);

  final SharedPreferencesAsync _preferences;
  static const _moduleKey = 'module';

  Future<ExamModule?> module() async => switch (await _preferences.getString(_moduleKey)) {
    final String name => ExamModule.values.asNameMap()[name],
    null => null,
  };

  Future<void> setModule(ExamModule module) => _preferences.setString(_moduleKey, module.name);
}

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(SharedPreferencesAsync()),
);

/// The chosen module; null until the candidate picks one on first launch.
class ModuleNotifier extends AsyncNotifier<ExamModule?> {
  @override
  Future<ExamModule?> build() => ref.watch(settingsRepositoryProvider).module();

  Future<void> choose(ExamModule module) async {
    await ref.read(settingsRepositoryProvider).setModule(module); // persist first
    state = AsyncData(module);
  }
}

final moduleProvider = AsyncNotifierProvider<ModuleNotifier, ExamModule?>(ModuleNotifier.new);
