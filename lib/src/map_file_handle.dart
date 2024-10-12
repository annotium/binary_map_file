// Copyright NgocKhanh 2024

part of "../binary_map_file.dart";

abstract class BaseMapFileHandle<T extends IMapable> {
  bool _initialized = false;

  final IBinaryMapFile _mapFile;
  final Map<String, T?> map;

  BaseMapFileHandle(this._mapFile) : map = {};

  Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }

    _mapFile.ensureInitialized();
    map.clear();

    for (final entry in _mapFile.map.entries) {
      map[entry.key.toString()] = decode(entry.value);
    }

    _initialized = true;
  }

  T? getValue(String key) => map[key];

  void setValue(String key, T? value) {
    map[key] = value;

    _mapFile.map[key] = value?.toMap();
  }

  void remove(String key) => map.remove(key);

  T decode(Map map);

  void serialize() => _mapFile.serialize();
}
