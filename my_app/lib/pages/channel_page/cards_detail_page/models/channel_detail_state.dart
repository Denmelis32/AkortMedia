import 'chat_message.dart';
import 'discussion.dart';

class ChannelDetailState {
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasError;
  final String? errorMessage;
  final int currentContentType;
  final bool isSubscribed;
  final bool notificationsEnabled;
  final bool isFavorite;
  final double scrollOffset;
  final bool showAppBarTitle;
  final double appBarElevation;
  final bool showFullDescription;
  final bool isEditingDescription;
  final bool showScrollToTop;
  final Map<int, bool> expandedSections;
  final List<ChatMessage> chatMessages;
  final List<Discussion> discussions;

  const ChannelDetailState({
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasError = false,
    this.errorMessage,
    this.currentContentType = 0,
    this.isSubscribed = false,
    this.notificationsEnabled = true,
    this.isFavorite = false,
    this.scrollOffset = 0.0,
    this.showAppBarTitle = false,
    this.appBarElevation = 0.0,
    this.showFullDescription = false,
    this.isEditingDescription = false,
    this.showScrollToTop = false,
    this.expandedSections = const {0: false, 1: false},
    this.chatMessages = const [],
    this.discussions = const [],
  });

  factory ChannelDetailState.initial() {
    return ChannelDetailState(
      isLoading: false,
      isLoadingMore: false,
      hasError: false,
      errorMessage: null,
      currentContentType: 0,
      isSubscribed: false,
      notificationsEnabled: true,
      isFavorite: false,
      scrollOffset: 0.0,
      showAppBarTitle: false,
      appBarElevation: 0.0,
      showFullDescription: false,
      isEditingDescription: false,
      showScrollToTop: false,
      expandedSections: const {0: false, 1: false},
      chatMessages: const [],
      discussions: const [],
    );
  }

  ChannelDetailState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasError,
    String? errorMessage,
    int? currentContentType,
    bool? isSubscribed,
    bool? notificationsEnabled,
    bool? isFavorite,
    double? scrollOffset,
    bool? showAppBarTitle,
    double? appBarElevation,
    bool? showFullDescription,
    bool? isEditingDescription,
    bool? showScrollToTop,
    Map<int, bool>? expandedSections,
    List<ChatMessage>? chatMessages,
    List<Discussion>? discussions,
  }) {
    return ChannelDetailState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      currentContentType: currentContentType ?? this.currentContentType,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isFavorite: isFavorite ?? this.isFavorite,
      scrollOffset: scrollOffset ?? this.scrollOffset,
      showAppBarTitle: showAppBarTitle ?? this.showAppBarTitle,
      appBarElevation: appBarElevation ?? this.appBarElevation,
      showFullDescription: showFullDescription ?? this.showFullDescription,
      isEditingDescription: isEditingDescription ?? this.isEditingDescription,
      showScrollToTop: showScrollToTop ?? this.showScrollToTop,
      expandedSections: expandedSections ?? this.expandedSections,
      chatMessages: chatMessages ?? this.chatMessages,
      discussions: discussions ?? this.discussions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChannelDetailState &&
        other.isLoading == isLoading &&
        other.isLoadingMore == isLoadingMore &&
        other.hasError == hasError &&
        other.errorMessage == errorMessage &&
        other.currentContentType == currentContentType &&
        other.isSubscribed == isSubscribed &&
        other.notificationsEnabled == notificationsEnabled &&
        other.isFavorite == isFavorite &&
        other.scrollOffset == scrollOffset &&
        other.showAppBarTitle == showAppBarTitle &&
        other.appBarElevation == appBarElevation &&
        other.showFullDescription == showFullDescription &&
        other.isEditingDescription == isEditingDescription &&
        other.showScrollToTop == showScrollToTop &&
        _mapEquals(other.expandedSections, expandedSections) &&
        _listEquals(other.chatMessages, chatMessages) &&
        _listEquals(other.discussions, discussions);
  }

  @override
  int get hashCode {
    return Object.hash(
      isLoading,
      isLoadingMore,
      hasError,
      errorMessage,
      currentContentType,
      isSubscribed,
      notificationsEnabled,
      isFavorite,
      scrollOffset,
      showAppBarTitle,
      appBarElevation,
      showFullDescription,
      isEditingDescription,
      showScrollToTop,
      Object.hashAll(expandedSections.entries),
      Object.hashAll(chatMessages),
      Object.hashAll(discussions),
    );
  }

  // Вспомогательные методы для сравнения коллекций
  bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) {
        return false;
      }
    }
    return true;
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // Дополнительные полезные методы
  bool get canLoadMore => !isLoading && !isLoadingMore && !hasError;

  bool get shouldShowLoading => isLoading && chatMessages.isEmpty;

  bool get hasDiscussions => discussions.isNotEmpty;

  bool get hasChatMessages => chatMessages.length > 1; // Больше 1, т.к. есть welcome message

  bool isSectionExpanded(int sectionId) => expandedSections[sectionId] ?? false;
}

// Extension методы для удобства
extension ChannelDetailStateExtensions on ChannelDetailState {
  bool get isWallContent => currentContentType == 0;
  bool get isAkorContent => currentContentType == 1;
  bool get isArticlesContent => currentContentType == 2;
  bool get isDiscussionsContent => currentContentType == 3;

  String get currentContentTypeName {
    switch (currentContentType) {
      case 0: return 'Стена';
      case 1: return 'Акорта';
      case 2: return 'Статьи';
      case 3: return 'Обсуждения';
      default: return 'Контент';
    }
  }
}