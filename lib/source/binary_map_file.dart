// Copyright NgocKhanh 2024

part of "../binary_map_file.dart";

abstract interface class IBinaryMapFile {
  /// Return the internal map
  Map get map;

  /// Check if file existed
  bool get existed;

  /// Ensure initialize before using
  Future<void> ensureInitialized();

  /// Check if key is set
  ///
  /// * `key` key to lookup
  bool containsKey(String key);

  /// Get value for given key
  ///
  /// * `key` key to lookup
  T? getValue<T extends Object>(String key);

  /// Get value for given key, if key is not set, set default value
  ///
  /// * `key` key to lookup,
  /// * `defaultValue` default value to set if map contains no such `key`
  T? getDefaultValue<T extends Object>(String key, [T? defaultValue]);

  /// Set value for key
  ///
  /// * `key` key to lookup,
  /// * `value` value to set
  void setValue<T extends Object>(String key, T? value);

  /// Serialize file
  Future<void> serialize();
}
