// Copyright NgocKhanh 2024

part of "../binary_map_file.dart";

abstract class BaseMapFileHandle<T extends IEncodable> {
  bool _initialized = false;

  final IBinaryMapFile _mapFile;
  final Map map;

  BaseMapFileHandle(this._mapFile) : map = {};

  Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }

    await _mapFile.ensureInitialized();
    map.clear();

    for (final entry in _mapFile.map.entries) {
      map[entry.key.toString()] = decode(entry.value);
    }

    _initialized = true;
  }

  T? getValue(String key) => map[key];

  void setValue(String key, T? value) {
    map[key] = value;
  }

  void remove(String key) => map.remove(key);

  T decode(Map map);

  Future<void> serialize() async {
    _mapFile.map.clear();
    for (final entry in map.entries) {
      _mapFile.map[entry.key] = entry.value?.toMap();
    }

    await _mapFile.serialize();
  }
}
