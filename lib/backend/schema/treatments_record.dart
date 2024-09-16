import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class TreatmentsRecord extends FirestoreRecord {
  TreatmentsRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "description" field.
  double? _description;
  double get description => _description ?? 0.0;
  bool hasDescription() => _description != null;

  // "images" field.
  List<String>? _images;
  List<String> get images => _images ?? const [];
  bool hasImages() => _images != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "updated_at" field.
  DateTime? _updatedAt;
  DateTime? get updatedAt => _updatedAt;
  bool hasUpdatedAt() => _updatedAt != null;

  // "created_by" field.
  DocumentReference? _createdBy;
  DocumentReference? get createdBy => _createdBy;
  bool hasCreatedBy() => _createdBy != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _description = castToType<double>(snapshotData['description']);
    _images = getDataList(snapshotData['images']);
    _createdAt = snapshotData['created_at'] as DateTime?;
    _updatedAt = snapshotData['updated_at'] as DateTime?;
    _createdBy = snapshotData['created_by'] as DocumentReference?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('treatments');

  static Stream<TreatmentsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => TreatmentsRecord.fromSnapshot(s));

  static Future<TreatmentsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => TreatmentsRecord.fromSnapshot(s));

  static TreatmentsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      TreatmentsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static TreatmentsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      TreatmentsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'TreatmentsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is TreatmentsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createTreatmentsRecordData({
  String? name,
  double? description,
  DateTime? createdAt,
  DateTime? updatedAt,
  DocumentReference? createdBy,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'created_by': createdBy,
    }.withoutNulls,
  );

  return firestoreData;
}

class TreatmentsRecordDocumentEquality implements Equality<TreatmentsRecord> {
  const TreatmentsRecordDocumentEquality();

  @override
  bool equals(TreatmentsRecord? e1, TreatmentsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.name == e2?.name &&
        e1?.description == e2?.description &&
        listEquality.equals(e1?.images, e2?.images) &&
        e1?.createdAt == e2?.createdAt &&
        e1?.updatedAt == e2?.updatedAt &&
        e1?.createdBy == e2?.createdBy;
  }

  @override
  int hash(TreatmentsRecord? e) => const ListEquality().hash([
        e?.name,
        e?.description,
        e?.images,
        e?.createdAt,
        e?.updatedAt,
        e?.createdBy
      ]);

  @override
  bool isValidKey(Object? o) => o is TreatmentsRecord;
}
