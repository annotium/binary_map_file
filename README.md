# BinaryMapFile

Performant key-value store using file system in pure Dart, secured support.

---

## Getting Started

To get started, simply import the `binary_map_file` package:

```dart
import "dart:io";
import 'package:binary_map_file/binary_map_file.dart';

final file = File(path),
final binaryMapFile = BinaryMapFile(file, secured: false); 
await binaryMapFile.ensureInitialized();
// if you want a secured serialization, set the flag secured to `true`

final map = binaryMapFile.map;

```
### Get value 

Get the bool value for key `firstRun`, if the key is not set or null, then reset the value in map to `default value` and return gotten value
```dart
final firstRun = binaryMapFile.getDefaultValue<bool>('firstRun' , true); //  
// or 
final value = binaryMapFile.getValue<bool>('firstRun'); // boolean or null
```

### Set value
```dart 
binaryMapFile.setValue<bool>('firstRun', false);
```

### Check containing key
```dart 
final existed = binaryMapFile.containsKey('firstRun');
```


### Serialize
Save the current map to file
```dart
await binaryMapFile.serialize();
```

## Supported data types

Support all data types which [MessageCodec](https://api.flutter.dev/flutter/services/MessageCodec-class.html) using the Flutter standard binary encoding.

Supported messages are acyclic values of these forms:

 * null
 * [bool](https://api.flutter.dev/flutter/dart-core/bool-class.html)s
 * [num](https://api.flutter.dev/flutter/dart-core/num-class.html)s
 * [String](https://api.flutter.dev/flutter/dart-core/String-class.html)s
 * [Uint8List](https://api.flutter.dev/flutter/dart-typed_data/Uint8List-class.html)s, [Int32List](https://api.flutter.dev/flutter/dart-typed_data/Int32List-class.html)s, [Int64List](https://api.flutter.dev/flutter/dart-typed_data/Int64List-class.html)s, [Float64List](https://api.flutter.dev/flutter/dart-typed_data/Float64List-class.html)s
 * [List](https://api.flutter.dev/flutter/dart-core/List-class.html)s of supported values
 * [Map](https://api.flutter.dev/flutter/dart-core/Map-class.html)s from supported values to supported values

## License

This library is licensed under the [MIT License](LICENSE). Feel free to use it and contribute to its development.

---

Made with ❤️ by Annotium