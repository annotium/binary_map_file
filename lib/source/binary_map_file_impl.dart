// Copyright NgocKhanh 2024

part of "../binary_map_file.dart";

typedef BackgroundArgumentType = (String, Map);

@pragma('vm:entry-point')
Map? loadInBackground(String path) {
  final file = File(path);
  final bytes = file.readAsBytesSync();
  return bytes.isEmpty
      ? null
      : const StandardMessageCodec().decodeMessage(
          bytes.buffer.asByteData(0, bytes.lengthInBytes),
        );
}

@pragma('vm:entry-point')
void saveInBackground((String, Map) data) {
  final (path, map) = data;
  try {
    final byteData = const StandardMessageCodec().encodeMessage(map);
    if (byteData == null) {
      throw Exception("Failed to serialize map. Empty data");
    } else {
      final bytes = byteData.buffer.asUint8List(0, byteData.lengthInBytes);
      final file = File(path);
      file.writeAsBytesSync(bytes);
    }
  } catch (error, stackTrace) {
    log(error.toString(), stackTrace: stackTrace);
    rethrow;
  }
}

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
class BinaryMapFile implements IBinaryMapFile {
  final rootIsolateToken = RootIsolateToken.instance!;
  final bool secured;
  final Map<String, dynamic> _map;
  final String path;
  bool saved;

  /// Creates a [BinaryMapFile]. If file does not exist, it will be in memory
  /// only until [serialize] is called
  ///
  /// * `path` path to file, maybe load existed file or create a new file
  /// * `secured` secure serialization or not, default is `false`
  BinaryMapFile({
    required this.path,
    this.secured = false,
  })  : _map = {},
        saved = false {
    assert(path.isNotEmpty, "Input path must be a valid file path");
  }

  /// Return the internal map
  @override
  Map<String, dynamic> get map => _map;

  @override
  bool get existed => File(path).existsSync();

  /// Ensure initialize before using
  @override
  Future<void> ensureInitialized() async {
    _map.clear();

    try {
      final file = File(path);
      if (file.existsSync()) {
        saved = true;
        final stopwatch = Stopwatch()..start();

        // final bytes = await file.readAsBytes();
        // if (bytes.isNotEmpty) {
        //   final encodeMap = Map<String, dynamic>.from(
        //       const StandardMessageCodec().decodeMessage(
        //     bytes.buffer.asByteData(0, bytes.lengthInBytes),
        //   ) as Map<Object?, Object?>);
        //   map.addAll(encodeMap);
        // }

        final map = await compute<String, Map?>(loadInBackground, path);
        if (map != null) {
          _map.addAll(Map<String, dynamic>.from(map));
        }
        debugPrint(
            "Deserialize `$path` takes ${stopwatch.elapsed.inMilliseconds}ms");
      }
    } on Exception catch (ex) {
      log(ex.toString());
    }
  }

  /// Get value for given key
  ///
  /// * `key` key to lookup
  @override
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
  @override
  bool containsKey(String key) => _map.containsKey(hashKey(key));

  /// Get value for given key, if key is not set, set default value
  ///
  /// * `key` key to lookup,
  /// * `defaultValue` default value to set if map contains no such `key`
  @override
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
  @override
  void setValue<T extends Object>(String key, T? value) {
    final rawKey = hashKey(key);

    _map[rawKey] = value;

    saved = false;
  }

  /// Remove map entry with key
  ///
  /// * `key` key to remove
  @override
  void remove(String key) => _map.remove(key);

  /// Serialize file
  @override
  Future<void> serialize() async {
    debugPrint("Serialize file `$path`");
    final stopwatch = Stopwatch()..start();
    await Isolate.spawn<(String, Map)>(saveInBackground, (path, _map));
    debugPrint("Serialize `$path` takes ${stopwatch.elapsed.inMilliseconds}ms");
  }

  /// Hash the key before lookup or serialize, works only if `secured` is set to true
  ///
  /// * `key` key to hash
  @visibleForTesting
  String hashKey(String key) =>
      secured ? md5.convert(utf8.encode(key)).toString() : key;
}
