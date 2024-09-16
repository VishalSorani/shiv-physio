import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class DoctorProfileRecord extends FirestoreRecord {
  DoctorProfileRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "userId" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "specialization" field.
  String? _specialization;
  String get specialization => _specialization ?? '';
  bool hasSpecialization() => _specialization != null;

  // "years_of_experience" field.
  int? _yearsOfExperience;
  int get yearsOfExperience => _yearsOfExperience ?? 0;
  bool hasYearsOfExperience() => _yearsOfExperience != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _userId = snapshotData['userId'] as String?;
    _specialization = snapshotData['specialization'] as String?;
    _yearsOfExperience = castToType<int>(snapshotData['years_of_experience']);
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('doctorProfile')
          : FirebaseFirestore.instance.collectionGroup('doctorProfile');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('doctorProfile').doc(id);

  static Stream<DoctorProfileRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => DoctorProfileRecord.fromSnapshot(s));

  static Future<DoctorProfileRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => DoctorProfileRecord.fromSnapshot(s));

  static DoctorProfileRecord fromSnapshot(DocumentSnapshot snapshot) =>
      DoctorProfileRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static DoctorProfileRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      DoctorProfileRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'DoctorProfileRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is DoctorProfileRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createDoctorProfileRecordData({
  String? userId,
  String? specialization,
  int? yearsOfExperience,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'userId': userId,
      'specialization': specialization,
      'years_of_experience': yearsOfExperience,
    }.withoutNulls,
  );

  return firestoreData;
}

class DoctorProfileRecordDocumentEquality
    implements Equality<DoctorProfileRecord> {
  const DoctorProfileRecordDocumentEquality();

  @override
  bool equals(DoctorProfileRecord? e1, DoctorProfileRecord? e2) {
    return e1?.userId == e2?.userId &&
        e1?.specialization == e2?.specialization &&
        e1?.yearsOfExperience == e2?.yearsOfExperience;
  }

  @override
  int hash(DoctorProfileRecord? e) => const ListEquality()
      .hash([e?.userId, e?.specialization, e?.yearsOfExperience]);

  @override
  bool isValidKey(Object? o) => o is DoctorProfileRecord;
}
