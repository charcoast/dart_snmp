import 'package:dart_snmp/src/models/authentication.dart';
import 'package:dart_snmp/src/models/encryption.dart';

/// A user credential for authenticating, encrypting, and decrypting
/// SNMP v3 [Message]s
class User {
  User(this.name, this.level,
      {this.authProtocol = AuthProtocol.usmHMACSHA,
      this.authKey,
      this.privProtocol = PrivProtocol.des,
      this.privKey});

  /// Username
  String name;

  /// Specifies whether the credential requires auth, privacy, or both
  SecurityLevel level = SecurityLevel.authNoPriv;

  /// The type of authorization security to use (md5 or sha)
  AuthProtocol authProtocol = AuthProtocol.usmHMACSHA;

  /// The key used to authenticate the user
  String authKey;

  /// The type of privacy (encryption) to use (des or aes)
  PrivProtocol privProtocol = PrivProtocol.des;

  /// The key used to encrypt messages
  String privKey;
}

/// The level of security which the snmp v3 credential requires
enum SecurityLevel {
  noAuthNoPriv,
  authNoPriv,
  authPriv,
}
