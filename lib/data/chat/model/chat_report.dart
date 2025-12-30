import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shiv_physio_app/data/chat/enum/chat_enums.dart';


class ChatReport {
  final String id;
  final String conversationId;
  final String reportedBy;
  final String? messageId; // Optional - might be reporting the conversation not a specific message
  final ReportType type;
  final String reason;
  final DateTime createdAt;
  final ReportStatus status;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? resolution;
  final List<String>? attachments; // URLs to screenshots or other evidence

  ChatReport({
    required this.id,
    required this.conversationId,
    required this.reportedBy,
    this.messageId,
    required this.type,
    required this.reason,
    required this.createdAt,
    this.status = ReportStatus.pending,
    this.reviewedBy,
    this.reviewedAt,
    this.resolution,
    this.attachments,
  });

  factory ChatReport.fromJson(Map<String, dynamic> json) {
    return ChatReport(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      reportedBy: json['reportedBy'] as String,
      messageId: json['messageId'] as String?,
      type: ReportType.values.firstWhere(
        (e) => e.toString() == 'ReportType.${json['type']}',
        orElse: () => ReportType.other,
      ),
      reason: json['reason'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      status: ReportStatus.values.firstWhere(
        (e) => e.toString() == 'ReportStatus.${json['status']}',
        orElse: () => ReportStatus.pending,
      ),
      reviewedBy: json['reviewedBy'] as String?,
      reviewedAt: (json['reviewedAt'] as Timestamp?)?.toDate(),
      resolution: json['resolution'] as String?,
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'reportedBy': reportedBy,
      'messageId': messageId,
      'type': type.toString().split('.').last,
      'reason': reason,
      'createdAt': createdAt,
      'status': status.toString().split('.').last,
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt,
      'resolution': resolution,
      'attachments': attachments,
    };
  }

  ChatReport copyWith({
    String? id,
    String? conversationId,
    String? reportedBy,
    String? messageId,
    ReportType? type,
    String? reason,
    DateTime? createdAt,
    ReportStatus? status,
    String? reviewedBy,
    DateTime? reviewedAt,
    String? resolution,
    List<String>? attachments,
  }) {
    return ChatReport(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      reportedBy: reportedBy ?? this.reportedBy,
      messageId: messageId ?? this.messageId,
      type: type ?? this.type,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      resolution: resolution ?? this.resolution,
      attachments: attachments ?? this.attachments,
    );
  }
}