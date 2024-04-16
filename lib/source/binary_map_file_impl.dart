// Copyright NgocKhanh 2024

library binary_map_file;

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';

/// [BinaryMapFile] is used to file based key-value serialization
///
/// Supported messages are acyclic values of these forms:
///
///  * null
///  * [bool]s
///  * [num]s
///  * [String]s
///  * [Uint8List]s, [Int32List]s, [Int64List]s, [Float64List]s
///  * [List]s of supported values
///  * [Map]s from supported values to supported values
class BinaryMapFile {
  final bool secured;
  final String path;
  final StandardMessageCodec _codec;
  final File _file;
  final Map<String, dynamic> _map;

  /// Creates a [BinaryMapFile].
  ///
  /// * `_file` file system,
  /// * `secured` secure serialization or not, default is `false`
  BinaryMapFile(this._file, {this.secured = false})
      : _codec = const StandardMessageCodec(),
        path = _file.path,
        _map = {};

  /// Return the internal map
  Map<String, dynamic> get map => _map;

  /// Ensure initialize before using
  Future<void> ensureInitialized() async {
    _map.clear();

    try {
      if (_file.existsSync()) {
        final stopwatch = Stopwatch()..start();
        final bytes = await _file.readAsBytes();
        if (bytes.isNotEmpty) {
          final encodeMap = Map<String, dynamic>.from(_codec.decodeMessage(
                  bytes.buffer.asByteData(0, bytes.lengthInBytes))
              as Map<Object?, Object?>);
          _map.addAll(encodeMap);
          debugPrint(
              "Deserialize `$path` takes ${stopwatch.elapsed.inMilliseconds}ms");
        }
      }
    } on Exception catch (ex) {
      log(ex.toString());
    }
  }

  /// Get value for given key
  ///
  /// * `key` key to lookup
  T? getValue<T extends Object>(String key) {
    final rawKey = hashKey(key);

    final value = _map[rawKey];
    if (value is T?) {
      return value;
    }

    return null;
  }

  /// Check if key is set
  ///
  /// * `key` key to lookup
  bool containsKey(String key) => _map.containsKey(hashKey(key));

  /// Get value for given key, if key is not set, set default value
  ///
  /// * `key` key to lookup,
  /// * `defaultValue` default value to set if map contains no such `key`
  T? getDefaultValue<T extends Object>(String key, [T? defaultValue]) {
    final rawKey = hashKey(key);

    if (!containsKey(rawKey)) {
      _map[rawKey] = defaultValue;

      return defaultValue;
    }

    return _map[rawKey];
  }

  /// Set value for key
  ///
  /// * `key` key to lookup,
  /// * `value` value to set
  void setValue<T extends Object>(String key, T? value) {
    final rawKey = hashKey(key);

    _map[rawKey] = value;
  }

  /// Save data to file
  ///
  Future<void> serialize() async {
    debugPrint('Serialize file `$path`');
    try {
      final stopwatch = Stopwatch()..start();
      final byteData = _codec.encodeMessage(_map);
      if (byteData == null) {
        throw Exception("Failed to serialize map. Empty data");
      } else {
        final bytes = byteData.buffer.asUint8List(0, byteData.lengthInBytes);
        await _file.writeAsBytes(bytes);
        debugPrint(
            "Serialize `$path` takes ${stopwatch.elapsed.inMilliseconds}ms");
      }
    } catch (error, stackTrace) {
      log(error.toString(), stackTrace: stackTrace);
      rethrow;
    }
  }

  @visibleForTesting

  /// Hash the key before lookup or serialize, works only if `secured` is set to true
  ///
  /// * `key` key to hash
  String hashKey(String key) =>
      secured ? md5.convert(utf8.encode(key)).toString() : key;
}
