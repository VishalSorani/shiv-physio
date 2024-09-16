import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PatientProfileRecord extends FirestoreRecord {
  PatientProfileRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "userId" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "date_of_birth" field.
  DateTime? _dateOfBirth;
  DateTime? get dateOfBirth => _dateOfBirth;
  bool hasDateOfBirth() => _dateOfBirth != null;

  // "medical_history" field.
  String? _medicalHistory;
  String get medicalHistory => _medicalHistory ?? '';
  bool hasMedicalHistory() => _medicalHistory != null;

  // "current_medications" field.
  List<String>? _currentMedications;
  List<String> get currentMedications => _currentMedications ?? const [];
  bool hasCurrentMedications() => _currentMedications != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _userId = snapshotData['userId'] as String?;
    _dateOfBirth = snapshotData['date_of_birth'] as DateTime?;
    _medicalHistory = snapshotData['medical_history'] as String?;
    _currentMedications = getDataList(snapshotData['current_medications']);
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('patientProfile')
          : FirebaseFirestore.instance.collectionGroup('patientProfile');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('patientProfile').doc(id);

  static Stream<PatientProfileRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PatientProfileRecord.fromSnapshot(s));

  static Future<PatientProfileRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PatientProfileRecord.fromSnapshot(s));

  static PatientProfileRecord fromSnapshot(DocumentSnapshot snapshot) =>
      PatientProfileRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PatientProfileRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PatientProfileRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PatientProfileRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PatientProfileRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPatientProfileRecordData({
  String? userId,
  DateTime? dateOfBirth,
  String? medicalHistory,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'userId': userId,
      'date_of_birth': dateOfBirth,
      'medical_history': medicalHistory,
    }.withoutNulls,
  );

  return firestoreData;
}

class PatientProfileRecordDocumentEquality
    implements Equality<PatientProfileRecord> {
  const PatientProfileRecordDocumentEquality();

  @override
  bool equals(PatientProfileRecord? e1, PatientProfileRecord? e2) {
    const listEquality = ListEquality();
    return e1?.userId == e2?.userId &&
        e1?.dateOfBirth == e2?.dateOfBirth &&
        e1?.medicalHistory == e2?.medicalHistory &&
        listEquality.equals(e1?.currentMedications, e2?.currentMedications);
  }

  @override
  int hash(PatientProfileRecord? e) => const ListEquality().hash(
      [e?.userId, e?.dateOfBirth, e?.medicalHistory, e?.currentMedications]);

  @override
  bool isValidKey(Object? o) => o is PatientProfileRecord;
}
