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
  final StandardMessageCodec _codec;
  final Map<String, dynamic> _map;
  final String path;
  bool saved;

  /// Creates a [BinaryMapFile]. If file does not exist, it will be in memory
  /// only until [serialize] is called
  ///
  /// * `path` path to file, maybe load existed file or create a new file
  /// * `secured` secure serialization or not, default is `false`
  BinaryMapFile({required this.path, this.secured = false})
      : _codec = const StandardMessageCodec(),
        _map = {},
        saved = false {
    assert(path.isNotEmpty, "Input path must be a valid file path");
  }

  /// Return the internal map
  Map<String, dynamic> get map => _map;

  bool get existed => File(path).existsSync();

  /// Ensure initialize before using
  Future<void> ensureInitialized() async {
    _map.clear();

    try {
      final file = File(path);
      if (file.existsSync()) {
        saved = true;
        final stopwatch = Stopwatch()..start();
        final bytes = await file.readAsBytes();
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

    saved = false;
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
        final file = File(path);
        await file.writeAsBytes(bytes);
        saved = true;
        debugPrint(
            "Serialize `$path` takes ${stopwatch.elapsed.inMilliseconds}ms");
      }
    } catch (error, stackTrace) {
      log(error.toString(), stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Hash the key before lookup or serialize, works only if `secured` is set to true
  ///
  /// * `key` key to hash
  @visibleForTesting
  String hashKey(String key) =>
      secured ? md5.convert(utf8.encode(key)).toString() : key;
}
