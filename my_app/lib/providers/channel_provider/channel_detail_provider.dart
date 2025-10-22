import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../pages/channel_page/cards_detail_page/models/channel.dart';
import '../../pages/channel_page/cards_detail_page/models/channel_detail_state.dart';
import '../../pages/channel_page/cards_detail_page/models/chat_message.dart';
import 'channel_state_provider.dart';

class ChannelDetailProvider with ChangeNotifier {
  final Channel _channel;
  ChannelDetailState _state;
  final ScrollController _scrollController = ScrollController();

  // Контроллеры для редактирования
  final TextEditingController _descriptionController = TextEditingController();

  // ССЫЛКА НА ChannelStateProvider
  ChannelStateProvider? _channelStateProvider;

  ChannelDetailProvider(this._channel)
      : _state = ChannelDetailState.initial() {
    _scrollController.addListener(_handleScroll);

    // Инициализация контроллера описания
    _descriptionController.text = _channel.description;

    // Загрузка начальных данных
    _loadInitialData();
  }

  // Метод для установки ChannelStateProvider
  void setChannelStateProvider(ChannelStateProvider provider) {
    _channelStateProvider = provider;
    // Инициализируем канал в состоянии если нужно
    _channelStateProvider!.initializeChannelIfNeeded(
      _channel.id.toString(),
      defaultAvatar: _channel.imageUrl,
      defaultCover: _channel.coverImageUrl,
      defaultTags: _channel.tags,
      defaultSubscribers: _channel.subscribers,
    );
    notifyListeners();
  }

  // ГЕТТЕРЫ
  Channel get channel => _channel;
  ChannelDetailState get state => _state;
  ScrollController get scrollController => _scrollController;
  TextEditingController get descriptionController => _descriptionController;

  // НОВЫЕ ГЕТТЕРЫ ДЛЯ СОСТОЯНИЯ - ИСПОЛЬЗУЕМ ChannelStateProvider
  String? get currentAvatarUrl => _channelStateProvider?.getAvatarForChannel(_channel.id.toString()) ?? _channel.imageUrl;

  String? get currentCoverUrl => _channelStateProvider?.getCoverForChannel(_channel.id.toString()) ?? _channel.coverImageUrl;

  List<String> get currentHashtags => _channelStateProvider?.getHashtagsForChannel(_channel.id.toString()).isNotEmpty ?? false
      ? _channelStateProvider!.getHashtagsForChannel(_channel.id.toString())
      : _channel.tags;

  // Геттер для подписки
  bool get isSubscribed => _channelStateProvider?.isSubscribed(_channel.id.toString()) ?? _channel.isSubscribed;

  // Геттер для количества подписчиков
  int get subscribersCount => _channelStateProvider?.getSubscribers(_channel.id.toString()) ?? _channel.subscribers;

  // Геттер для секций - ИСПРАВЛЕНО
  bool isSectionExpanded(int index) => _state.expandedSections[index] ?? false;

  // НОВЫЕ МЕТОДЫ ДЛЯ ИЗМЕНЕНИЯ СОСТОЯНИЯ - ЧЕРЕЗ ChannelStateProvider
  void setAvatarUrl(String? avatarUrl) {
    _channelStateProvider?.setAvatarForChannel(_channel.id.toString(), avatarUrl);
    notifyListeners();
  }

  void setCoverUrl(String? coverUrl) {
    _channelStateProvider?.setCoverForChannel(_channel.id.toString(), coverUrl);
    notifyListeners();
  }

  void setHashtags(List<String> hashtags) {
    _channelStateProvider?.setHashtagsForChannel(_channel.id.toString(), hashtags);
    notifyListeners();
  }

  void addHashtag(String hashtag) {
    _channelStateProvider?.addHashtagToChannel(_channel.id.toString(), hashtag);
    notifyListeners();
  }

  void removeHashtag(String hashtag) {
    _channelStateProvider?.removeHashtagFromChannel(_channel.id.toString(), hashtag);
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

  // МЕТОД ДЛЯ ПЕРЕКЛЮЧЕНИЯ СЕКЦИЙ - ИСПРАВЛЕНО
  void toggleSection(int index) {
    final newSections = Map<int, bool>.from(_state.expandedSections);
    newSections[index] = !(newSections[index] ?? false);
    _state = _state.copyWith(expandedSections: newSections);
    notifyListeners();
  }

  // МЕТОДЫ ДЛЯ ЧАТА
  void addChatMessage(String message) {
    final newMessage = ChatMessage(
      text: message,
      isMe: true,
      timestamp: DateTime.now(),
      senderName: 'Пользователь',
      senderImageUrl: '',
      senderId: 'current_user_id',
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
        isSubscribed: isSubscribed,
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
    if (_channelStateProvider != null) {
      _channelStateProvider!.toggleSubscription(_channel.id.toString(), subscribersCount);
    } else {
      _state = _state.copyWith(
        isSubscribed: !_state.isSubscribed,
      );
    }
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
    if (_channelStateProvider != null) {
      _channelStateProvider!.updateChannelSubscription(
          _channel.id.toString(),
          true,
          subscribersCount + 1
      );
    } else {
      _state = _state.copyWith(isSubscribed: true);
    }
    notifyListeners();
  }

  void leaveChannel() {
    if (_channelStateProvider != null) {
      _channelStateProvider!.updateChannelSubscription(
          _channel.id.toString(),
          false,
          subscribersCount - 1
      );
    } else {
      _state = _state.copyWith(isSubscribed: false);
    }
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

  // НОВЫЙ МЕТОД ДЛЯ СБРОСА СОСТОЯНИЯ К ИСХОДНОМУ - ИСПРАВЛЕНО
  void resetToInitialState() {
    // Сбрасываем кастомные данные в ChannelStateProvider
    _channelStateProvider?.setAvatarForChannel(_channel.id.toString(), _channel.imageUrl);
    _channelStateProvider?.setCoverForChannel(_channel.id.toString(), _channel.coverImageUrl);
    _channelStateProvider?.setHashtagsForChannel(_channel.id.toString(), _channel.tags);

    _descriptionController.text = _channel.description;

    // Сбрасываем секции
    final newSections = <int, bool>{};

    _state = ChannelDetailState.initial().copyWith(
      expandedSections: newSections,
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

    // Обновляем данные только если они не были изменены пользователем
    if (_channelStateProvider != null) {
      final currentAvatar = _channelStateProvider!.getAvatarForChannel(_channel.id.toString());
      final currentCover = _channelStateProvider!.getCoverForChannel(_channel.id.toString());
      final currentHashtags = _channelStateProvider!.getHashtagsForChannel(_channel.id.toString());

      // Обновляем аватар только если он равен исходному (не был изменен пользователем)
      if (currentAvatar == null || currentAvatar == _channel.imageUrl) {
        _channelStateProvider!.setAvatarForChannel(_channel.id.toString(), newChannel.imageUrl);
      }

      // Обновляем обложку только если она равна исходной (не была изменена пользователем)
      if (currentCover == null || currentCover == _channel.coverImageUrl) {
        _channelStateProvider!.setCoverForChannel(_channel.id.toString(), newChannel.coverImageUrl);
      }

      // Обновляем хештеги только если они равны исходным (не были изменены пользователем)
      if (currentHashtags.isEmpty || _listEquals(currentHashtags, _channel.tags)) {
        _channelStateProvider!.setHashtagsForChannel(_channel.id.toString(), newChannel.tags);
      }
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