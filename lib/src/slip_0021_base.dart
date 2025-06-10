import 'dart:typed_data';
import 'package:crypto/crypto.dart' show Hmac, sha512;

const String masterNodeKey = "Symmetric key seed";

class Slip21Node {
  static const String _hmacMasterNodeKey = "Symmetric key seed";
  final Uint8List _data;

  Slip21Node._(this._data);

  /// Create a new master node from a BIP-39 or SLIP-39 seed.
  /// This seed is expected to be 64 bytes long.
  Slip21Node.newMaster(Uint8List seed)
    : _data = _computeHmac(seed, _hmacMasterNodeKey.codeUnits);

  static Uint8List _computeHmac(Uint8List data, List<int> key) {
    final hmac = Hmac(sha512, key);
    return Uint8List.fromList(hmac.convert(data).bytes);
  }

  /// Derive the child node of this node
  Slip21Node deriveChild(Uint8List label) {
    // ChildNode(N, label) = HMAC-SHA512(key = N[0:32], msg = b"\x00" + label)
    final key = _data.sublist(0, 32);
    final message = Uint8List.fromList([0, ...label]);
    return Slip21Node._(_computeHmac(message, key));
  }

  /// Get the symmetric key of a child node
  Uint8List get key => _data.sublist(32, 64);
}
