// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class AvailableHoursStruct extends FFFirebaseStruct {
  AvailableHoursStruct({
    DateTime? start,
    DateTime? end,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _start = start,
        _end = end,
        super(firestoreUtilData);

  // "start" field.
  DateTime? _start;
  DateTime? get start => _start;
  set start(DateTime? val) => _start = val;

  bool hasStart() => _start != null;

  // "end" field.
  DateTime? _end;
  DateTime? get end => _end;
  set end(DateTime? val) => _end = val;

  bool hasEnd() => _end != null;

  static AvailableHoursStruct fromMap(Map<String, dynamic> data) =>
      AvailableHoursStruct(
        start: data['start'] as DateTime?,
        end: data['end'] as DateTime?,
      );

  static AvailableHoursStruct? maybeFromMap(dynamic data) => data is Map
      ? AvailableHoursStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'start': _start,
        'end': _end,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'start': serializeParam(
          _start,
          ParamType.DateTime,
        ),
        'end': serializeParam(
          _end,
          ParamType.DateTime,
        ),
      }.withoutNulls;

  static AvailableHoursStruct fromSerializableMap(Map<String, dynamic> data) =>
      AvailableHoursStruct(
        start: deserializeParam(
          data['start'],
          ParamType.DateTime,
          false,
        ),
        end: deserializeParam(
          data['end'],
          ParamType.DateTime,
          false,
        ),
      );

  @override
  String toString() => 'AvailableHoursStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is AvailableHoursStruct &&
        start == other.start &&
        end == other.end;
  }

  @override
  int get hashCode => const ListEquality().hash([start, end]);
}

AvailableHoursStruct createAvailableHoursStruct({
  DateTime? start,
  DateTime? end,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    AvailableHoursStruct(
      start: start,
      end: end,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

AvailableHoursStruct? updateAvailableHoursStruct(
  AvailableHoursStruct? availableHours, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    availableHours
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addAvailableHoursStructData(
  Map<String, dynamic> firestoreData,
  AvailableHoursStruct? availableHours,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (availableHours == null) {
    return;
  }
  if (availableHours.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && availableHours.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final availableHoursData =
      getAvailableHoursFirestoreData(availableHours, forFieldValue);
  final nestedData =
      availableHoursData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = availableHours.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getAvailableHoursFirestoreData(
  AvailableHoursStruct? availableHours, [
  bool forFieldValue = false,
]) {
  if (availableHours == null) {
    return {};
  }
  final firestoreData = mapToFirestore(availableHours.toMap());

  // Add any Firestore field values
  availableHours.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getAvailableHoursListFirestoreData(
  List<AvailableHoursStruct>? availableHourss,
) =>
    availableHourss
        ?.map((e) => getAvailableHoursFirestoreData(e, true))
        .toList() ??
    [];
