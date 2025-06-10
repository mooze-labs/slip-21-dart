<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages). 
-->

# SLIP-0021: Symmetric Key Derivation

A Dart implementation of [SLIP-0021](https://github.com/satoshilabs/slips/blob/master/slip-0021.md), which defines a method for deriving symmetric keys from a master seed using a hierarchical deterministic approach.

## Features

- Derive master node from a BIP-39 or SLIP-39 seed
- Hierarchical deterministic key derivation
- Support for labeled child nodes
- Compatible with the SLIP-0021 specification

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  slip_0021: ^1.0.0
```

## Usage

### Creating a Master Node

```dart
import 'package:slip_0021/slip_0021.dart';
import 'dart:typed_data';

// Create a master node from a 64-byte seed
final seed = Uint8List.fromList([/* your 64-byte seed */]);
final masterNode = Slip21Node.newMaster(seed);

// Get the master node's key (32 bytes)
final masterKey = masterNode.key;
```

### Deriving Child Nodes

```dart
// Derive a child node with a label
final childNode = masterNode.deriveChild(
  Uint8List.fromList('SLIP-0021'.codeUnits)
);

// Get the child node's key
final childKey = childNode.key;

// Derive nested child nodes
final encryptionKeyNode = childNode.deriveChild(
  Uint8List.fromList('Master encryption key'.codeUnits)
);
final authKeyNode = childNode.deriveChild(
  Uint8List.fromList('Authentication key'.codeUnits)
);
```

### Complete Example

Here's a complete example using the test vectors from the specification:

```dart
import 'package:slip_0021/slip_0021.dart';
import 'dart:typed_data';

void main() {
  // Test seed from BIP-39 mnemonic "all all all all all all all all all all all all"
  final seed = Uint8List.fromList([
    0xc7, 0x6c, 0x4a, 0xc4, 0xf4, 0xe4, 0xa0, 0x0d,
    0x6b, 0x27, 0x4d, 0x5c, 0x39, 0xc7, 0x00, 0xbb,
    0x4a, 0x7d, 0xdc, 0x04, 0xfb, 0xc6, 0xf7, 0x8e,
    0x85, 0xca, 0x75, 0x00, 0x7b, 0x5b, 0x49, 0x5f,
    0x74, 0xa9, 0x04, 0x3e, 0xeb, 0x77, 0xbd, 0xd5,
    0x3a, 0xa6, 0xfc, 0x3a, 0x0e, 0x31, 0x46, 0x22,
    0x70, 0x31, 0x6f, 0xa0, 0x4b, 0x8c, 0x19, 0x11,
    0x4c, 0x87, 0x98, 0x70, 0x6c, 0xd0, 0x2a, 0xc8,
  ]);

  // Create master node
  final masterNode = Slip21Node.newMaster(seed);
  print('Master key: ${masterNode.key}');

  // Derive SLIP-0021 child node
  final slip0021Node = masterNode.deriveChild(
    Uint8List.fromList('SLIP-0021'.codeUnits)
  );
  print('SLIP-0021 key: ${slip0021Node.key}');

  // Derive encryption key
  final encryptionKeyNode = slip0021Node.deriveChild(
    Uint8List.fromList('Master encryption key'.codeUnits)
  );
  print('Encryption key: ${encryptionKeyNode.key}');

  // Derive authentication key
  final authKeyNode = slip0021Node.deriveChild(
    Uint8List.fromList('Authentication key'.codeUnits)
  );
  print('Authentication key: ${authKeyNode.key}');
}
```

## How It Works

SLIP-0021 defines a hierarchical deterministic key derivation scheme for symmetric keys:

1. The master node is created using HMAC-SHA512 with:
   - Key: "Symmetric key seed"
   - Message: The input seed (64 bytes)

2. Child nodes are derived using HMAC-SHA512 with:
   - Key: First 32 bytes of the parent node's data
   - Message: A zero byte followed by the label

3. The symmetric key for any node is the second 32 bytes of its HMAC output.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
