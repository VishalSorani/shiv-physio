import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AppointmentsRecord extends FirestoreRecord {
  AppointmentsRecord._(
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

  // "date_time" field.
  DateTime? _dateTime;
  DateTime? get dateTime => _dateTime;
  bool hasDateTime() => _dateTime != null;

  void _initializeFields() {
    _patientRef = snapshotData['patient_ref'] as DocumentReference?;
    _doctorRef = snapshotData['doctor_ref'] as DocumentReference?;
    _dateTime = snapshotData['date_time'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('appointments');

  static Stream<AppointmentsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => AppointmentsRecord.fromSnapshot(s));

  static Future<AppointmentsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => AppointmentsRecord.fromSnapshot(s));

  static AppointmentsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      AppointmentsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static AppointmentsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      AppointmentsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'AppointmentsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is AppointmentsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createAppointmentsRecordData({
  DocumentReference? patientRef,
  DocumentReference? doctorRef,
  DateTime? dateTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'patient_ref': patientRef,
      'doctor_ref': doctorRef,
      'date_time': dateTime,
    }.withoutNulls,
  );

  return firestoreData;
}

class AppointmentsRecordDocumentEquality
    implements Equality<AppointmentsRecord> {
  const AppointmentsRecordDocumentEquality();

  @override
  bool equals(AppointmentsRecord? e1, AppointmentsRecord? e2) {
    return e1?.patientRef == e2?.patientRef &&
        e1?.doctorRef == e2?.doctorRef &&
        e1?.dateTime == e2?.dateTime;
  }

  @override
  int hash(AppointmentsRecord? e) =>
      const ListEquality().hash([e?.patientRef, e?.doctorRef, e?.dateTime]);

  @override
  bool isValidKey(Object? o) => o is AppointmentsRecord;
}
