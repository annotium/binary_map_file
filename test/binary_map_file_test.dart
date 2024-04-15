// Copyright NgocKhanh 2024

import 'dart:io';

import 'package:binary_map_file/binary_map_file.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Create mocks
class MockQFile extends Mock implements File {}

class MockQMessageCodec extends Mock implements StandardMessageCodec {}

void main() {
  group('BinaryMapFile', () {
    late MockQFile mockFile;
    late BinaryMapFile binaryMapFile;

    setUp(() {
      mockFile = MockQFile();
      when(() => mockFile.path).thenReturn('test_path');

      binaryMapFile = BinaryMapFile(mockFile, secured: false);
    });

    test('ensureInitialized should load data if file exists', () async {
      when(() => mockFile.existsSync()).thenReturn(true);

      final testMap = {'key': 'value', 'other_key': 1, 'null_value': null};

      const codec = StandardMessageCodec();
      final byteData = codec.encodeMessage(testMap)!;
      final bytes = byteData.buffer.asUint8List(0, byteData.lengthInBytes);

      when(() => mockFile.readAsBytes()).thenAnswer((_) async => bytes);

      await binaryMapFile.ensureInitialized();

      expect(binaryMapFile.map, contains('key'));
      expect(binaryMapFile.map['key'], 'value');
      expect(binaryMapFile.map['other_key'], 1);
      expect(binaryMapFile.map['null_value'], null);
    });

    test('getValue should return the correct value', () {
      const updatedValue = 'value1';
      binaryMapFile.map['key'] = updatedValue;
      expect(binaryMapFile.getValue<String>('key'), updatedValue);
    });

    test('setValue should correctly set the value', () {
      binaryMapFile.setValue<String>('new_key', 'new_value');
      expect(binaryMapFile.map['new_key'], 'new_value');
    });

    test('serialize should write to file if data is present', () async {
      when(() => mockFile.writeAsBytes(any()))
          .thenAnswer((_) async => Future.value(MockQFile()));
      binaryMapFile.map['key'] = 'value';

      await binaryMapFile.serialize();

      verify(() => mockFile.writeAsBytes(any())).called(1);
    });

    test('getEncodedKey should return hashed key if secured', () {
      binaryMapFile = BinaryMapFile(mockFile, secured: true);
      final encodedKey = binaryMapFile.hashKey('key');

      // Since the hashing will be consistent for the same input and algorithm,
      // we can assert the exact output hash if you know it, or just ensure it's different from 'key'.
      expect(encodedKey, isNot('key'));
    });

    test('containsKey should work successfully', () async {
      when(() => mockFile.existsSync()).thenReturn(true);

      final testMap = {'key': 'value', 'other_key': 1, 'null_value': null};

      const codec = StandardMessageCodec();
      final byteData = codec.encodeMessage(testMap)!;
      final bytes = byteData.buffer.asUint8List(0, byteData.lengthInBytes);

      when(() => mockFile.readAsBytes()).thenAnswer((_) async => bytes);

      await binaryMapFile.ensureInitialized();

      expect(binaryMapFile.containsKey('key'), isTrue);
      expect(binaryMapFile.containsKey('other_key'), isTrue);
      expect(binaryMapFile.containsKey('null_value'), isTrue);
      expect(binaryMapFile.containsKey('not_exist'), isFalse);
    });
  });
}
