// ================ Message Type ================
// message type: For example, text, image, video, audio, file, location, contact, sticker
enum MessageType {
  text,
  image,
  video,
  audio,
  file,
  location,
  contact,
  sticker,
}

extension MessageTypeExtension on MessageType {
  String get value {
    return toString().split('.').last;
  }

  static MessageType fromString(String? type) {
    if (type == null) return MessageType.text;

    try {
      return MessageType.values.firstWhere(
        (e) => e.value == type,
        orElse: () => MessageType.text,
      );
    } catch (_) {
      return MessageType.text;
    }
  }
}

// =============== Participant Role ===============
// Participant role: For example, admin, moderator, member, guest, restricted
// This enum represents the different roles a participant can have in a chat group.
// Each role has different permissions and capabilities within the group.
enum ParticipantRole {
  admin,
  moderator,
  member,
  guest,
  restricted,
}

extension ParticipantRoleExtension on ParticipantRole {
  String get value {
    return toString().split('.').last;
  }

  static ParticipantRole fromValue(String value) {
    return ParticipantRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => ParticipantRole.member,
    );
  }

  bool canDeleteMessages() {
    return this == ParticipantRole.admin || this == ParticipantRole.moderator;
  }

  bool canModerateUsers() {
    return this == ParticipantRole.admin || this == ParticipantRole.moderator;
  }

  bool canAddUsers() {
    return this == ParticipantRole.admin || this == ParticipantRole.moderator;
  }

  bool canRemoveUsers() {
    return this == ParticipantRole.admin;
  }

  bool canEditGroupInfo() {
    return this == ParticipantRole.admin;
  }

  bool isSendingRestricted() {
    return this == ParticipantRole.restricted || this == ParticipantRole.guest;
  }
}

// =============== Report Type ===============
// Report type: For example, spam, harassment, hate speech, misinformation, other
// This enum represents the different types of reports that can be made against a user or message.
enum ReportType {
  spam,
  harassment,
  hateSpeech,
  misinformation,
  other,
}

extension ReportTypeExtension on ReportType {
  String get value {
    return toString().split('.').last;
  }

  static ReportType fromString(String? type) {
    if (type == null) return ReportType.other;

    try {
      return ReportType.values.firstWhere(
        (e) => e.value == type,
        orElse: () => ReportType.other,
      );
    } catch (_) {
      return ReportType.other;
    }
  }
}

// =============== Report Status ===============
// Report status: For example, pending, reviewed, resolved, rejected
// This enum represents the different statuses a report can have.
enum ReportStatus {
  pending,
  reviewed,
  resolved,
  rejected,
}

extension ReportStatusExtension on ReportStatus {
  String get value {
    return toString().split('.').last;
  }

  static ReportStatus fromString(String? status) {
    if (status == null) return ReportStatus.pending;

    try {
      return ReportStatus.values.firstWhere(
        (e) => e.value == status,
        orElse: () => ReportStatus.pending,
      );
    } catch (_) {
      return ReportStatus.pending;
    }
  }
}
