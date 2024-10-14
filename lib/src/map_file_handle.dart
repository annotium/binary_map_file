// Copyright NgocKhanh 2024

part of "../binary_map_file.dart";

abstract class BaseMapFileHandle {
  bool _initialized = false;

  final IBinaryMapFile _mapFile;
  final Map<String, dynamic> map;

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

  T? getValue<T extends Object>(String key) => map[key];

  void setValue<T extends Object>(String key, T? value) {
    map[key] = value;
  }

  void remove(String key) => map.remove(key);

  T decode<T extends Object>(Map map);

  Future<void> serialize() async {
    _mapFile.map.clear();
    for (final entry in map.entries) {
      final type = entry.value.runtimeType;

      if (type is int || type is double || type is num || type is String) {
        _mapFile.map[entry.key] = entry.value;
      } else if (type is IEncodable) {
        _mapFile.map[entry.key] = entry.value?.toMap();
      } else {
        throw UnsupportedError(
            'Unsupported type $type. Please use primitive type or IEncodable');
      }
    }

    await _mapFile.serialize();
  }
}
