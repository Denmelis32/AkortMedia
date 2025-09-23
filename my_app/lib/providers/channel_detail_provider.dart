import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../pages/cards_page/models/channel.dart';
import '../pages/cards_page/models/chat_message.dart';
import '../pages/cards_page/models/discussion.dart';

class ChannelDetailProvider with ChangeNotifier {
  final Channel channel;

  // Состояние UI
  ChannelDetailState _state = const ChannelDetailState();
  ChannelDetailState get state => _state;

  // Контроллеры
  final ScrollController scrollController = ScrollController();
  final TextEditingController descriptionController = TextEditingController();

  // Таймеры и подписки
  Timer? _scrollTimer;
  final List<StreamSubscription> _subscriptions = [];

  ChannelDetailProvider(this.channel) {
    _initialize();
  }

  void _initialize() {
    // Инициализация контроллеров
    descriptionController.text = channel.description;

    // Настройка слушателей скролла
    scrollController.addListener(_handleScroll);

    // Загрузка начальных данных
    _loadInitialData();

    // Добавление приветственного сообщения
    _addWelcomeMessage();
    _loadDiscussions();
  }

  void _handleScroll() {
    // Оптимизация: обновляем состояние скролла не чаще чем раз в 100ms
    _scrollTimer?.cancel();
    _scrollTimer = Timer(const Duration(milliseconds: 100), () {
      final offset = scrollController.offset;
      _updateState(_state.copyWith(
        scrollOffset: offset,
        showAppBarTitle: offset > 100,
        showScrollToTop: offset > 500,
        appBarElevation: offset > 50 ? 4.0 : 0.0,
      ));
    });
  }

  void _updateState(ChannelDetailState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  Future<void> _loadInitialData() async {
    _updateState(_state.copyWith(isLoading: true));

    try {
      // Имитация загрузки данных
      await Future.delayed(const Duration(milliseconds: 800));

      _updateState(_state.copyWith(
        isLoading: false,
        isSubscribed: channel.isSubscribed,
        isFavorite: channel.isFavorite,
      ));

    } catch (e) {
      _updateState(_state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Ошибка загрузки данных: $e',
      ));
    }
  }

  // === ОСНОВНЫЕ МЕТОДЫ УПРАВЛЕНИЯ СОСТОЯНИЕМ ===

  void changeContentType(int index) {
    _updateState(_state.copyWith(currentContentType: index));

    // Прокрутка к началу контента
    if (scrollController.hasClients) {
      scrollController.animateTo(
        280,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // Метод для ChannelHeader (без параметров)
  void toggleSubscription() {
    final newValue = !_state.isSubscribed;
    _updateState(_state.copyWith(isSubscribed: newValue));

    if (newValue) {
      _showSubscriptionSuccess();
    }
  }

  void toggleFavorite() {
    _updateState(_state.copyWith(isFavorite: !_state.isFavorite));
  }

  void toggleNotifications() {
    _updateState(_state.copyWith(
        notificationsEnabled: !_state.notificationsEnabled
    ));
  }

  void toggleDescription() {
    _updateState(_state.copyWith(
        showFullDescription: !_state.showFullDescription
    ));
  }

  void toggleEditDescription() {
    final newEditingState = !_state.isEditingDescription;
    _updateState(_state.copyWith(isEditingDescription: newEditingState));

    if (!newEditingState) {
      _saveDescription();
    }
  }

  void toggleSection(int sectionId) {
    final newSections = Map<int, bool>.from(_state.expandedSections);
    newSections[sectionId] = !(newSections[sectionId] ?? false);

    _updateState(_state.copyWith(expandedSections: newSections));
  }

  void _saveDescription() {
    // Логика сохранения описания
    channel.description = descriptionController.text;
    // Здесь можно добавить вызов API для сохранения
  }

  void _showSubscriptionSuccess() {
    // Успешная подписка - можно показать SnackBar через BuildContext
    // или использовать глобальный ключ для показа уведомлений
  }

  // === ЧАТ И ОБСУЖДЕНИЯ ===

  void _addWelcomeMessage() {
    final messages = List<ChatMessage>.from(_state.chatMessages);
    messages.add(ChatMessage(
      text: 'Добро пожаловать в чат канала "${channel.title}"! 🎉\nЗдесь вы можете общаться с другими участниками сообщества.',
      isMe: false,
      timestamp: DateTime.now(),
      senderName: 'Система',
      senderId: 'system_welcome',
    ));

    _updateState(_state.copyWith(chatMessages: messages));
  }

  void _loadDiscussions() {
    final discussions = [
      Discussion(
        id: '1',
        title: 'Обсуждение нового функционала',
        author: 'Алексей Петров',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        commentsCount: 15,
        likes: 42,
        isPinned: true,
      ),
      Discussion(
        id: '2',
        title: 'Идеи для улучшения платформы',
        author: 'Мария Иванова',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        commentsCount: 8,
        likes: 27,
      ),
      Discussion(
        id: '3',
        title: 'Вопросы по использованию API',
        author: 'Дмитрий Сидоров',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        commentsCount: 23,
        likes: 19,
      ),
    ];

    _updateState(_state.copyWith(discussions: discussions));
  }

  void addChatMessage(String message) {
    if (message.trim().isEmpty) return;

    final messages = List<ChatMessage>.from(_state.chatMessages);
    messages.add(ChatMessage(
      text: message,
      isMe: true,
      timestamp: DateTime.now(),
      senderName: 'Вы',
      senderId: 'current_user',
    ));

    _updateState(_state.copyWith(chatMessages: messages));
    _simulateResponse();
  }

  void _simulateResponse() {
    Future.delayed(const Duration(seconds: 1), () {
      final responses = [
        'Отличное сообщение! 👍',
        'Спасибо за участие в обсуждении! 💬',
        'Интересная мысль! 🤔',
        'Рады видеть вас в нашем чате! 🎯',
        'Продолжайте в том же духе! 🔥'
      ];

      final randomResponse = responses[DateTime.now().millisecond % responses.length];
      final messages = List<ChatMessage>.from(_state.chatMessages);

      messages.add(ChatMessage(
        text: randomResponse,
        isMe: false,
        timestamp: DateTime.now(),
        senderName: 'Модератор',
        senderId: 'moderator_id',
      ));

      _updateState(_state.copyWith(chatMessages: messages));
    });
  }

  void addDiscussion(Discussion discussion) {
    final discussions = List<Discussion>.from(_state.discussions);
    discussions.insert(0, discussion);

    _updateState(_state.copyWith(
      discussions: discussions,
      currentContentType: 2, // Переключить на вкладку обсуждений
    ));
  }

  // === ДОПОЛНИТЕЛЬНЫЕ МЕТОДЫ ===

  void scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void updateDescription(String newDescription) {
    descriptionController.text = newDescription;
    _saveDescription();
  }

  void retryLoading() {
    _updateState(_state.copyWith(hasError: false, errorMessage: ''));
    _loadInitialData();
  }

  void clearError() {
    _updateState(_state.copyWith(hasError: false, errorMessage: ''));
  }

  // === ДИСПОЗ И ОЧИСТКА РЕСУРСОВ ===

  @override
  void dispose() {
    // Отмена таймеров
    _scrollTimer?.cancel();

    // Отмена всех подписок
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }

    // Диспоз контроллеров
    scrollController.dispose();
    descriptionController.dispose();

    super.dispose();
  }
}

// === МОДЕЛЬ СОСТОЯНИЯ ===

class ChannelDetailState {
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasError;
  final String errorMessage;
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
    this.errorMessage = '',
    this.currentContentType = 0,
    this.isSubscribed = false,
    this.notificationsEnabled = true,
    this.isFavorite = false,
    this.scrollOffset = 0,
    this.showAppBarTitle = false,
    this.appBarElevation = 0,
    this.showFullDescription = false,
    this.isEditingDescription = false,
    this.showScrollToTop = false,
    this.expandedSections = const {0: false, 1: false},
    this.chatMessages = const [],
    this.discussions = const [],
  });

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
}