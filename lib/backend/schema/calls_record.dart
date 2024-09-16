import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CallsRecord extends FirestoreRecord {
  CallsRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "patient_ref" field.
  DocumentReference? _patientRef;
  DocumentReference? get patientRef => _patientRef;
  bool hasPatientRef() => _patientRef != null;

  // "doctor_ref" field.
  DocumentReference? _doctorRef;
  DocumentReference? get doctorRef => _doctorRef;
  bool hasDoctorRef() => _doctorRef != null;

  // "start_time" field.
  DateTime? _startTime;
  DateTime? get startTime => _startTime;
  bool hasStartTime() => _startTime != null;

  // "end_time" field.
  DateTime? _endTime;
  DateTime? get endTime => _endTime;
  bool hasEndTime() => _endTime != null;

  // "duration" field.
  int? _duration;
  int get duration => _duration ?? 0;
  bool hasDuration() => _duration != null;

  // "status" field.
  CallStatus? _status;
  CallStatus? get status => _status;
  bool hasStatus() => _status != null;

  void _initializeFields() {
    _patientRef = snapshotData['patient_ref'] as DocumentReference?;
    _doctorRef = snapshotData['doctor_ref'] as DocumentReference?;
    _startTime = snapshotData['start_time'] as DateTime?;
    _endTime = snapshotData['end_time'] as DateTime?;
    _duration = castToType<int>(snapshotData['duration']);
    _status = deserializeEnum<CallStatus>(snapshotData['status']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('calls');

  static Stream<CallsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => CallsRecord.fromSnapshot(s));

  static Future<CallsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => CallsRecord.fromSnapshot(s));

  static CallsRecord fromSnapshot(DocumentSnapshot snapshot) => CallsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static CallsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      CallsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'CallsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is CallsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createCallsRecordData({
  DocumentReference? patientRef,
  DocumentReference? doctorRef,
  DateTime? startTime,
  DateTime? endTime,
  int? duration,
  CallStatus? status,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'patient_ref': patientRef,
      'doctor_ref': doctorRef,
      'start_time': startTime,
      'end_time': endTime,
      'duration': duration,
      'status': status,
    }.withoutNulls,
  );

  return firestoreData;
}

class CallsRecordDocumentEquality implements Equality<CallsRecord> {
  const CallsRecordDocumentEquality();

  @override
  bool equals(CallsRecord? e1, CallsRecord? e2) {
    return e1?.patientRef == e2?.patientRef &&
        e1?.doctorRef == e2?.doctorRef &&
        e1?.startTime == e2?.startTime &&
        e1?.endTime == e2?.endTime &&
        e1?.duration == e2?.duration &&
        e1?.status == e2?.status;
  }

  @override
  int hash(CallsRecord? e) => const ListEquality().hash([
        e?.patientRef,
        e?.doctorRef,
        e?.startTime,
        e?.endTime,
        e?.duration,
        e?.status
      ]);

  @override
  bool isValidKey(Object? o) => o is CallsRecord;
}
