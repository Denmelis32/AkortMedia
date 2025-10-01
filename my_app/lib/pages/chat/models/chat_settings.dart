// models/chat_settings.dart
class ChatSettings {
  final bool enableReactions;
  final bool enableVoiceMessages;
  final bool enableTranslations;
  final bool enableStickers;
  final bool enableFileSharing;
  final bool showOnlineStatus;
  final bool showReadReceipts;
  final bool allowMentions;
  final int messageHistoryLimit;
  final int maxFileSizeMB;
  final int maxVoiceDuration;
  final List<String> allowedFileTypes;
  final bool slowModeEnabled;
  final int slowModeDelay; // in seconds

  const ChatSettings({
    this.enableReactions = true,
    this.enableVoiceMessages = true,
    this.enableTranslations = true,
    this.enableStickers = true,
    this.enableFileSharing = true,
    this.showOnlineStatus = true,
    this.showReadReceipts = true,
    this.allowMentions = true,
    this.messageHistoryLimit = 1000,
    this.maxFileSizeMB = 50,
    this.maxVoiceDuration = 120,
    this.allowedFileTypes = const ['jpg', 'png', 'pdf', 'doc', 'docx'],
    this.slowModeEnabled = false,
    this.slowModeDelay = 5,
  });

  ChatSettings copyWith({
    bool? enableReactions,
    bool? enableVoiceMessages,
    bool? enableTranslations,
    bool? enableStickers,
    bool? enableFileSharing,
    bool? showOnlineStatus,
    bool? showReadReceipts,
    bool? allowMentions,
    int? messageHistoryLimit,
    int? maxFileSizeMB,
    int? maxVoiceDuration,
    List<String>? allowedFileTypes,
    bool? slowModeEnabled,
    int? slowModeDelay,
  }) {
    return ChatSettings(
      enableReactions: enableReactions ?? this.enableReactions,
      enableVoiceMessages: enableVoiceMessages ?? this.enableVoiceMessages,
      enableTranslations: enableTranslations ?? this.enableTranslations,
      enableStickers: enableStickers ?? this.enableStickers,
      enableFileSharing: enableFileSharing ?? this.enableFileSharing,
      showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
      showReadReceipts: showReadReceipts ?? this.showReadReceipts,
      allowMentions: allowMentions ?? this.allowMentions,
      messageHistoryLimit: messageHistoryLimit ?? this.messageHistoryLimit,
      maxFileSizeMB: maxFileSizeMB ?? this.maxFileSizeMB,
      maxVoiceDuration: maxVoiceDuration ?? this.maxVoiceDuration,
      allowedFileTypes: allowedFileTypes ?? this.allowedFileTypes,
      slowModeEnabled: slowModeEnabled ?? this.slowModeEnabled,
      slowModeDelay: slowModeDelay ?? this.slowModeDelay,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enableReactions': enableReactions,
      'enableVoiceMessages': enableVoiceMessages,
      'enableTranslations': enableTranslations,
      'enableStickers': enableStickers,
      'enableFileSharing': enableFileSharing,
      'showOnlineStatus': showOnlineStatus,
      'showReadReceipts': showReadReceipts,
      'allowMentions': allowMentions,
      'messageHistoryLimit': messageHistoryLimit,
      'maxFileSizeMB': maxFileSizeMB,
      'maxVoiceDuration': maxVoiceDuration,
      'allowedFileTypes': allowedFileTypes,
      'slowModeEnabled': slowModeEnabled,
      'slowModeDelay': slowModeDelay,
    };
  }

  factory ChatSettings.fromJson(Map<String, dynamic> json) {
    return ChatSettings(
      enableReactions: json['enableReactions'] ?? true,
      enableVoiceMessages: json['enableVoiceMessages'] ?? true,
      enableTranslations: json['enableTranslations'] ?? true,
      enableStickers: json['enableStickers'] ?? true,
      enableFileSharing: json['enableFileSharing'] ?? true,
      showOnlineStatus: json['showOnlineStatus'] ?? true,
      showReadReceipts: json['showReadReceipts'] ?? true,
      allowMentions: json['allowMentions'] ?? true,
      messageHistoryLimit: json['messageHistoryLimit'] ?? 1000,
      maxFileSizeMB: json['maxFileSizeMB'] ?? 50,
      maxVoiceDuration: json['maxVoiceDuration'] ?? 120,
      allowedFileTypes: List<String>.from(json['allowedFileTypes'] ?? ['jpg', 'png', 'pdf', 'doc', 'docx']),
      slowModeEnabled: json['slowModeEnabled'] ?? false,
      slowModeDelay: json['slowModeDelay'] ?? 5,
    );
  }
}