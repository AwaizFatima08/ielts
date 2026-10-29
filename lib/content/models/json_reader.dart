/// Typed access to decoded JSON objects. Missing or mistyped fields throw a
/// [FormatException], which the content repository turns into a failure.
typedef Json = Map<String, Object?>;

extension JsonReader on Json {
  T _required<T>(String key) {
    final value = this[key];
    if (value is T) return value;
    throw FormatException('Field "$key" should be $T but was ${value.runtimeType}');
  }

  String string(String key) => _required<String>(key);

  String? optionalString(String key) => this[key] as String?;

  int integer(String key) => _required<num>(key).toInt();

  int? optionalInteger(String key) => (this[key] as num?)?.toInt();

  bool? optionalBool(String key) => this[key] as bool?;

  List<Object?> list(String key) => (this[key] as List<Object?>?) ?? const [];

  List<String> stringList(String key) => [for (final item in list(key)) item! as String];

  Json? optionalObject(String key) => this[key] as Json?;

  Json object(String key) => _required<Json>(key);

  List<Json> objectList(String key) => [for (final item in list(key)) item! as Json];

  Map<int, String> intKeyedStrings(String key) {
    final map = (this[key] as Json?) ?? const <String, Object?>{};
    return {for (final entry in map.entries) int.parse(entry.key): entry.value! as String};
  }

  Map<int, List<String>> intKeyedStringLists(String key) {
    final map = (this[key] as Json?) ?? const <String, Object?>{};
    return {
      for (final entry in map.entries)
        int.parse(entry.key): [for (final item in entry.value! as List<Object?>) item! as String],
    };
  }
}
