import 'package:flutter/material.dart';
import '../pages/cards_page/models/channel.dart';
import '../pages/cards_page/models/channel_detail_state.dart';
import '../pages/cards_page/models/chat_message.dart'; // Добавьте этот импорт

class ChannelDetailProvider with ChangeNotifier {
  final Channel _channel;
  ChannelDetailState _state;
  final ScrollController _scrollController = ScrollController();

  // Контроллеры для редактирования
  final TextEditingController _descriptionController = TextEditingController();

  // НОВЫЕ ПОЛЯ ДЛЯ СОХРАНЕНИЯ СОСТОЯНИЯ
  String? _currentAvatarUrl;
  String? _currentCoverUrl;
  List<String> _currentHashtags = [];

  // Дополнительные состояния для секций
  final List<bool> _expandedSections = [false, false, false]; // Для members, playlists и других секций

  ChannelDetailProvider(this._channel)
      : _state = ChannelDetailState.initial() {
    _scrollController.addListener(_handleScroll);

    // ИНИЦИАЛИЗАЦИЯ ИЗ КАНАЛА
    _currentAvatarUrl = _channel.imageUrl;
    _currentCoverUrl = _channel.coverImageUrl;
    _currentHashtags = List.from(_channel.tags);

    // Инициализация контроллера описания
    _descriptionController.text = _channel.description;

    // Загрузка начальных данных
    _loadInitialData();
  }

  // ГЕТТЕРЫ
  Channel get channel => _channel;
  ChannelDetailState get state => _state;
  ScrollController get scrollController => _scrollController;
  TextEditingController get descriptionController => _descriptionController;

  // НОВЫЕ ГЕТТЕРЫ ДЛЯ СОСТОЯНИЯ
  String? get currentAvatarUrl => _currentAvatarUrl;
  String? get currentCoverUrl => _currentCoverUrl;
  List<String> get currentHashtags => _currentHashtags;

  // Геттер для секций
  bool isSectionExpanded(int index) => _expandedSections[index];

  // НОВЫЕ МЕТОДЫ ДЛЯ ИЗМЕНЕНИЯ СОСТОЯНИЯ
  void setAvatarUrl(String? avatarUrl) {
    _currentAvatarUrl = avatarUrl;
    notifyListeners();
  }

  void setCoverUrl(String? coverUrl) {
    _currentCoverUrl = coverUrl;
    notifyListeners();
  }

  void setHashtags(List<String> hashtags) {
    _currentHashtags = hashtags;
    notifyListeners();
  }

  // МЕТОДЫ ДЛЯ РЕДАКТИРОВАНИЯ ОПИСАНИЯ
  void toggleEditDescription() {
    if (_state.isEditingDescription) {
      // Сохраняем описание
      // Здесь можно добавить логику сохранения в базу данных
    }

    _state = _state.copyWith(
      isEditingDescription: !_state.isEditingDescription,
    );
    notifyListeners();
  }

  void toggleDescription() {
    _state = _state.copyWith(
      showFullDescription: !_state.showFullDescription,
    );
    notifyListeners();
  }

  // МЕТОД ДЛЯ ПЕРЕКЛЮЧЕНИЯ СЕКЦИЙ
  void toggleSection(int index) {
    if (index >= 0 && index < _expandedSections.length) {
      _expandedSections[index] = !_expandedSections[index];
      notifyListeners();
    }
  }

  // МЕТОДЫ ДЛЯ ЧАТА - ИСПРАВЛЕННАЯ ВЕРСИЯ
  void addChatMessage(String message) {
    final newMessage = ChatMessage(
      text: message,
      isMe: true,
      timestamp: DateTime.now(),
      senderName: 'Пользователь',
      senderImageUrl: '',
      senderId: 'current_user_id', // Замените на реальный ID пользователя
    );

    final updatedMessages = List<ChatMessage>.from(_state.chatMessages);
    updatedMessages.add(newMessage);

    _state = _state.copyWith(
      chatMessages: updatedMessages,
    );
    notifyListeners();
  }

  // СУЩЕСТВУЮЩИЕ МЕТОДЫ
  void _loadInitialData() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      // Имитация загрузки данных
      await Future.delayed(const Duration(milliseconds: 500));

      _state = _state.copyWith(
        isLoading: false,
        isSubscribed: _channel.isSubscribed,
        isFavorite: _channel.isFavorite,
        notificationsEnabled: true,
      );
    } catch (error) {
      _state = _state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: error.toString(),
      );
    }

    notifyListeners();
  }

  void _handleScroll() {
    final offset = _scrollController.offset;
    final showAppBarTitle = offset > 100;
    final appBarElevation = offset > 50 ? 4.0 : 0.0;
    final showScrollToTop = offset > 300;

    if (showAppBarTitle != _state.showAppBarTitle ||
        appBarElevation != _state.appBarElevation ||
        showScrollToTop != _state.showScrollToTop) {
      _state = _state.copyWith(
        scrollOffset: offset,
        showAppBarTitle: showAppBarTitle,
        appBarElevation: appBarElevation,
        showScrollToTop: showScrollToTop,
      );
      notifyListeners();
    }
  }

  void toggleSubscription() {
    _state = _state.copyWith(
      isSubscribed: !_state.isSubscribed,
    );
    notifyListeners();
  }

  void toggleFavorite() {
    _state = _state.copyWith(
      isFavorite: !_state.isFavorite,
    );
    notifyListeners();
  }

  void toggleNotifications() {
    _state = _state.copyWith(
      notificationsEnabled: !_state.notificationsEnabled,
    );
    notifyListeners();
  }

  void changeContentType(int index) {
    _state = _state.copyWith(
      currentContentType: index,
    );
    notifyListeners();
  }

  void scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void updateChannelInfo({
    String? title,
    String? description,
    String? imageUrl,
  }) {
    // Здесь можно добавить логику обновления информации о канале
    notifyListeners();
  }

  void joinChannel() {
    _state = _state.copyWith(
      isSubscribed: true,
    );
    notifyListeners();
  }

  void leaveChannel() {
    _state = _state.copyWith(
      isSubscribed: false,
    );
    notifyListeners();
  }

  void reportChannel(String reason) {
    // Здесь можно добавить логику жалобы на канал
    notifyListeners();
  }

  void setError(String error) {
    _state = _state.copyWith(
      hasError: true,
      errorMessage: error,
    );
    notifyListeners();
  }

  void clearError() {
    _state = _state.copyWith(
      hasError: false,
      errorMessage: null,
    );
    notifyListeners();
  }

  void refreshData() {
    _state = _state.copyWith(
      isLoading: true,
      hasError: false,
      errorMessage: null,
    );
    notifyListeners();

    _loadInitialData();
  }

  // НОВЫЙ МЕТОД ДЛЯ СБРОСА СОСТОЯНИЯ К ИСХОДНОМУ
  void resetToInitialState() {
    _currentAvatarUrl = _channel.imageUrl;
    _currentCoverUrl = _channel.coverImageUrl;
    _currentHashtags = List.from(_channel.tags);
    _descriptionController.text = _channel.description;

    // Сбрасываем секции
    for (int i = 0; i < _expandedSections.length; i++) {
      _expandedSections[i] = false;
    }

    _state = ChannelDetailState.initial().copyWith(
      isSubscribed: _channel.isSubscribed,
      isFavorite: _channel.isFavorite,
    );

    notifyListeners();
  }

  // НОВЫЙ МЕТОД ДЛЯ ОБНОВЛЕНИЯ КАНАЛА
  void updateChannel(Channel newChannel) {
    if (_channel.id != newChannel.id) {
      return;
    }

    if (_currentAvatarUrl == _channel.imageUrl) {
      _currentAvatarUrl = newChannel.imageUrl;
    }
    if (_currentCoverUrl == _channel.coverImageUrl) {
      _currentCoverUrl = newChannel.coverImageUrl;
    }
    if (_listEquals(_currentHashtags, _channel.tags)) {
      _currentHashtags = List.from(newChannel.tags);
    }

    _state = _state.copyWith(
      isSubscribed: newChannel.isSubscribed,
      isFavorite: newChannel.isFavorite,
    );

    notifyListeners();
  }

  // Вспомогательный метод для сравнения списков
  bool _listEquals(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}