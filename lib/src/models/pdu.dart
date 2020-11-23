import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:dart_snmp/src/models/varbind.dart';

/// An SNMP Protocol Data Unit which contains a list of [Varbind]s and
/// may (when received as a response) contain error information from an
/// snmp device
class Pdu {
  Pdu(this.type, this.requestId, this.varbinds,
      {this.error = PduError.NoError, this.errorIndex = 0});

  /// Parses a list of bytes into a Pdu object
  Pdu.fromBytes(Uint8List bytes) {
    var sequence = ASN1Sequence.fromBytes(bytes);
    assert(sequence.tag > 159 && sequence.tag < 169); // PDU tags
    type = PduType._internal(sequence.tag);
    requestId = (sequence.elements[0] as ASN1Integer).intValue;
    error = PduError.fromInt((sequence.elements[1] as ASN1Integer).intValue);
    errorIndex = (sequence.elements[2] as ASN1Integer).intValue;
    varbinds = [];
    for (var v in (sequence.elements[3] as ASN1Sequence).elements) {
      varbinds.add(Varbind.fromBytes(v.encodedBytes));
    }
  }

  /// The type of snmp request/response for which this Pdu contains data
  PduType type;

  /// Unique identifier used to match response PDUs to request PDUs
  int requestId;

  /// The type of snmp error (if any) which occured at the target
  PduError error;

  /// Indicates the presence (1) or lack of an error (0)
  int errorIndex;

  /// List of variable bindings [Varbind] which contain an [Oid] and data
  List<Varbind> varbinds;

  /// Converts the Pdu to a (transmittable) list of bytes
  Uint8List get encodedBytes => asAsn1Sequence.encodedBytes;

  /// Converts the Pdu to an [ASN1Sequence] object
  ASN1Sequence get asAsn1Sequence {
    var sequence = ASN1Sequence(tag: type.value);
    sequence.add(ASN1Integer.fromInt(requestId));
    sequence.add(ASN1Integer.fromInt(error.value));
    sequence.add(ASN1Integer.fromInt(errorIndex));
    sequence.add(_varbindListSequence(varbinds));
    return sequence;
  }

  ASN1Sequence _varbindListSequence(List<Varbind> varbinds) {
    var sequence = ASN1Sequence();
    for (var v in varbinds) {
      sequence.add(v.asAsn1Sequence);
    }
    return sequence;
  }
}

/// The type of snmp request which is sent to or received from the target device
class PduType {
  const PduType._internal(this.value);

  final int value;

  static const Map<int, String> _types = <int, String>{
    160: 'GetRequest',
    161: 'GetNextRequest',
    162: 'GetResponse',
    163: 'SetRequest',
    164: 'Trap',
    165: 'GetBulkRequest',
    166: 'InformRequest',
    167: 'TrapV2',
    168: 'Report'
  };

  @override
  String toString() => 'PduType.$name ($value)';

  String get name => _types[value];

  static bool contains(int i) => _types.containsKey(i);

  static const GetRequest = PduType._internal(160);
  static const GetNextRequest = PduType._internal(161);
  static const GetResponse = PduType._internal(162);
  static const SetRequest = PduType._internal(163);
  static const Trap = PduType._internal(164);
  static const GetBulkRequest = PduType._internal(165);
  static const InformRequest = PduType._internal(166);
  static const TrapV2 = PduType._internal(167);
  static const Report = PduType._internal(168);

  @override
  bool operator ==(Object other) =>
      other is PduType && (identical(this, other) || value == other.value);
}

/// The type of error which occurred while the target device was
/// attempting to respond to the snmp request
class PduError {
  const PduError._internal(this.value);

  PduError.fromInt(this.value);

  final int value;

  static const Map<int, String> _errors = <int, String>{
    0: 'NoError',
    1: 'TooBig',
    2: 'NoSuchName',
    3: 'BadValue',
    4: 'ReadOnly',
    5: 'GeneralError',
    6: 'NoAccess',
    7: 'WrongType',
    8: 'WrongLength',
    9: 'WrongEncoding',
    10: 'WrongValue',
    11: 'NoCreation',
    12: 'InconsistentValue',
    13: 'ResourceUnavailable',
    14: 'CommitFailed',
    15: 'UndoFailed',
    16: 'AuthorizationError',
    17: 'NotWritable',
    18: 'InconsistentName'
  };

  @override
  String toString() => 'PduError.$name ($value)';

  String get name => _errors[value];

  static const NoError = PduError._internal(0);
  static const TooBig = PduError._internal(1);
  static const NoSuchName = PduError._internal(2);
  static const BadValue = PduError._internal(3);
  static const ReadOnly = PduError._internal(4);
  static const GeneralError = PduError._internal(5);
  static const NoAccess = PduError._internal(6);
  static const WrongType = PduError._internal(7);
  static const WrongLength = PduError._internal(8);
  static const WrongEncoding = PduError._internal(9);
  static const WrongValue = PduError._internal(10);
  static const NoCreation = PduError._internal(11);
  static const InconsistentValue = PduError._internal(12);
  static const ResourceUnavailable = PduError._internal(13);
  static const CommitFailed = PduError._internal(14);
  static const UndoFailed = PduError._internal(15);
  static const AuthorizationError = PduError._internal(16);
  static const NotWritable = PduError._internal(17);
  static const InconsistentNam = PduError._internal(18);

  @override
  bool operator ==(Object other) =>
      other is PduError && (identical(this, other) || value == other.value);
}
