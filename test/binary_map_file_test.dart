// Copyright NgocKhanh 2024

import 'dart:io';

import 'package:binary_map_file/binary_map_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as fs_path;

void main() {
  group('BinaryMapFile', () {
    late String path;
    late BinaryMapFile binaryMapFile;

    setUp(() async {
      final dir = Directory.current;
      path = fs_path.join(dir.path, 'file.dat');
    });

    Future<void> prepareFile(Map<String, dynamic> map) async {
      final file = BinaryMapFile(path: path, secured: false);

      for (final key in map.keys) {
        final value = map[key];

        file.setValue(key, value);
      }

      await file.serialize();
    }

    test('ensureInitialized should load data if file exists', () async {
      final testMap = {'key': 'value', 'other_key': 1, 'null_value': null};
      await prepareFile(testMap);

      binaryMapFile = BinaryMapFile(path: path, secured: false);
      await binaryMapFile.ensureInitialized();

      expect(binaryMapFile.map, contains('key'));
      expect(binaryMapFile.map['key'], 'value');
      expect(binaryMapFile.map['other_key'], 1);
      expect(binaryMapFile.map['null_value'], null);

      expect(() => File(path).deleteSync(), returnsNormally);
    });

    test('getValue should return the correct value/in memory map file', () {
      const updatedValue = 'value1';

      binaryMapFile = BinaryMapFile(path: path, secured: false);
      binaryMapFile.map['key'] = updatedValue;
      expect(binaryMapFile.getValue<String>('key'), updatedValue);
    });

    test('setValue should correctly set the value', () {
      binaryMapFile = BinaryMapFile(path: path, secured: false);
      binaryMapFile.setValue<String>('new_key', 'new_value');
      expect(binaryMapFile.map['new_key'], 'new_value');
    });

    test('serialize should write to file if data is present', () async {
      binaryMapFile = BinaryMapFile(path: path, secured: false);
      binaryMapFile.map['key'] = 'value';

      await binaryMapFile.serialize();
      expect(File(binaryMapFile.path).existsSync(), isTrue);
      expect(() => File(path).deleteSync(), returnsNormally);
    });

    test('getEncodedKey should return hashed key if secured', () {
      binaryMapFile = BinaryMapFile(path: path, secured: true);
      final encodedKey = binaryMapFile.hashKey('key');

      // Since the hashing will be consistent for the same input and algorithm,
      // we can assert the exact output hash if you know it, or just ensure it's different from 'key'.
      expect(encodedKey, isNot('key'));
    });

    test('containsKey should work successfully', () async {
      final testMap = {'key': 'value', 'other_key': 1, 'null_value': null};
      await prepareFile(testMap);

      binaryMapFile = BinaryMapFile(path: path, secured: false);
      await binaryMapFile.ensureInitialized();

      expect(binaryMapFile.containsKey('key'), isTrue);
      expect(binaryMapFile.containsKey('other_key'), isTrue);
      expect(binaryMapFile.containsKey('null_value'), isTrue);
      expect(binaryMapFile.containsKey('not_exist'), isFalse);
      expect(() => File(path).deleteSync(), returnsNormally);
    });
  });
}
