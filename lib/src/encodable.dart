// Copyright NgocKhanh 2024

part of "../binary_map_file.dart";

/// Interface which support encode for binary map file
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
abstract interface class IEncodable {
  Map toMap();
}
