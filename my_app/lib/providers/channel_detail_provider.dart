import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../pages/cards_page/models/channel.dart';
import '../pages/cards_page/models/chat_message.dart';
import '../pages/cards_page/models/discussion.dart';
import '../pages/cards_page/models/channel_detail_state.dart'; // Новый импорт

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
    // Успешная подписка
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

  // Новые методы для улучшенного управления состоянием
  void startLoading() {
    _updateState(_state.copyWith(isLoading: true, hasError: false));
  }

  void finishLoading() {
    _updateState(_state.copyWith(isLoading: false));
  }

  void setError(String error) {
    _updateState(_state.copyWith(
      hasError: true,
      errorMessage: error,
      isLoading: false,
    ));
  }

  // === ДИСПОЗ И ОЧИСТКА РЕСУРСОВ ===

  @override
  void dispose() {
    _scrollTimer?.cancel();

    for (final subscription in _subscriptions) {
      subscription.cancel();
    }

    scrollController.dispose();
    descriptionController.dispose();

    super.dispose();
  }
}