// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class EmergencyContactStruct extends FFFirebaseStruct {
  EmergencyContactStruct({
    String? name,
    String? relationship,
    String? phoneNumber,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _name = name,
        _relationship = relationship,
        _phoneNumber = phoneNumber,
        super(firestoreUtilData);

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  set name(String? val) => _name = val;

  bool hasName() => _name != null;

  // "relationship" field.
  String? _relationship;
  String get relationship => _relationship ?? '';
  set relationship(String? val) => _relationship = val;

  bool hasRelationship() => _relationship != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  set phoneNumber(String? val) => _phoneNumber = val;

  bool hasPhoneNumber() => _phoneNumber != null;

  static EmergencyContactStruct fromMap(Map<String, dynamic> data) =>
      EmergencyContactStruct(
        name: data['name'] as String?,
        relationship: data['relationship'] as String?,
        phoneNumber: data['phone_number'] as String?,
      );

  static EmergencyContactStruct? maybeFromMap(dynamic data) => data is Map
      ? EmergencyContactStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'name': _name,
        'relationship': _relationship,
        'phone_number': _phoneNumber,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'name': serializeParam(
          _name,
          ParamType.String,
        ),
        'relationship': serializeParam(
          _relationship,
          ParamType.String,
        ),
        'phone_number': serializeParam(
          _phoneNumber,
          ParamType.String,
        ),
      }.withoutNulls;

  static EmergencyContactStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      EmergencyContactStruct(
        name: deserializeParam(
          data['name'],
          ParamType.String,
          false,
        ),
        relationship: deserializeParam(
          data['relationship'],
          ParamType.String,
          false,
        ),
        phoneNumber: deserializeParam(
          data['phone_number'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'EmergencyContactStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is EmergencyContactStruct &&
        name == other.name &&
        relationship == other.relationship &&
        phoneNumber == other.phoneNumber;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([name, relationship, phoneNumber]);
}

EmergencyContactStruct createEmergencyContactStruct({
  String? name,
  String? relationship,
  String? phoneNumber,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    EmergencyContactStruct(
      name: name,
      relationship: relationship,
      phoneNumber: phoneNumber,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

EmergencyContactStruct? updateEmergencyContactStruct(
  EmergencyContactStruct? emergencyContact, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    emergencyContact
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addEmergencyContactStructData(
  Map<String, dynamic> firestoreData,
  EmergencyContactStruct? emergencyContact,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (emergencyContact == null) {
    return;
  }
  if (emergencyContact.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && emergencyContact.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final emergencyContactData =
      getEmergencyContactFirestoreData(emergencyContact, forFieldValue);
  final nestedData =
      emergencyContactData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = emergencyContact.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getEmergencyContactFirestoreData(
  EmergencyContactStruct? emergencyContact, [
  bool forFieldValue = false,
]) {
  if (emergencyContact == null) {
    return {};
  }
  final firestoreData = mapToFirestore(emergencyContact.toMap());

  // Add any Firestore field values
  emergencyContact.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getEmergencyContactListFirestoreData(
  List<EmergencyContactStruct>? emergencyContacts,
) =>
    emergencyContacts
        ?.map((e) => getEmergencyContactFirestoreData(e, true))
        .toList() ??
    [];
