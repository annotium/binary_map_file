// Copyright NgocKhanh 2024

part of "../binary_map_file.dart";

class CryptoHash {
  const CryptoHash._();

  static String md5(String input) =>
      crypto.md5.convert(utf8.encode(input)).toString();
}
