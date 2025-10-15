import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../chat_controller.dart';
import '../models/chat_message.dart';
import 'message_bubble.dart';
import 'pagination_loader.dart';
import 'typing_indicator.dart';

class MessageListView extends StatefulWidget {
  final String roomId;
  final ScrollController? scrollController;
  final Function(ChatMessage)? onReply;
  final Function(ChatMessage)? onReact;
  final Function(ChatMessage)? onLongPress;
  final String? avatarUrl; // Добавлен параметр для URL аватарки

  const MessageListView({
    super.key,
    required this.roomId,
    this.scrollController,
    this.onReply,
    this.onReact,
    this.onLongPress,
    this.avatarUrl, // Добавлен в конструктор
  });

  @override
  State<MessageListView> createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView> {
  final ScrollController _defaultScrollController = ScrollController();
  bool _isScrolling = false;

  ScrollController get _effectiveScrollController =>
      widget.scrollController ?? _defaultScrollController;

  @override
  void initState() {
    super.initState();
    _effectiveScrollController.addListener(_onScroll);

    // Загружаем комнату при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatController>().loadRoom(widget.roomId);
    });
  }

  @override
  void dispose() {
    _effectiveScrollController.removeListener(_onScroll);
    if (widget.scrollController == null) {
      _defaultScrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _effectiveScrollController.position.maxScrollExtent;
    final currentScroll = _effectiveScrollController.position.pixels;

    // Автоподгрузка при接近 конца
    if (maxScroll - currentScroll < 200 && !_isScrolling) {
      _loadMoreMessages();
    }

    // Отслеживаем состояние скролла для оптимизаций
    _isScrolling = _effectiveScrollController.position.isScrollingNotifier.value;
  }

  void _loadMoreMessages() {
    final controller = context.read<ChatController>();
    if (controller.paginationState.canLoadMore) {
      controller.loadMoreMessages();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_effectiveScrollController.hasClients) {
        _effectiveScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatController>(
      builder: (context, controller, child) {
        final messages = controller.visibleMessages;
        final isLoading = controller.isLoading;
        final hasError = controller.error != null;
        final isTyping = controller.isTyping;

        // Автоскролл к низу при новых сообщениях
        if (messages.isNotEmpty && !_isScrolling) {
          _scrollToBottom();
        }

        return Stack(
          children: [
            // Основной список сообщений
            CustomScrollView(
              controller: _effectiveScrollController,
              reverse: true, // Новые сообщения внизу
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Индикатор набора текста
                if (isTyping)
                  const SliverToBoxAdapter(
                    child: TypingIndicator(),
                  ),

                // Сообщения
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      if (index < messages.length) {
                        final message = messages[index];
                        final showAvatar = _shouldShowAvatar(messages, index);
                        final showTimestamp = _shouldShowTimestamp(messages, index);

                        return MessageBubble(
                          message: message,
                          showAvatar: showAvatar,
                          showTimestamp: showTimestamp,
                          onReply: widget.onReply,
                          onReact: widget.onReact,
                          onLongPress: widget.onLongPress,
                          avatarUrl: widget.avatarUrl, // Передаем URL аватарки
                        );
                      }
                      return null;
                    },
                    childCount: messages.length,
                  ),
                ),

                // Индикатор загрузки истории
                if (controller.paginationState.isLoading)
                  const SliverToBoxAdapter(
                    child: PaginationLoader(),
                  ),

                // Сообщение об ошибке
                if (hasError)
                  SliverToBoxAdapter(
                    child: _buildErrorWidget(controller.error!),
                  ),

                // Пустое состояние
                if (messages.isEmpty && !isLoading && !hasError)
                  SliverFillRemaining(
                    child: _buildEmptyState(),
                  ),

                // Отступ снизу
                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),
              ],
            ),

            // Индикатор загрузки при первоначальной загрузке
            if (isLoading && messages.isEmpty)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        );
      },
    );
  }

  bool _shouldShowAvatar(List<ChatMessage> messages, int index) {
    if (index == messages.length - 1) return true;

    final current = messages[index];
    final next = messages[index + 1];

    // Показываем аватар если:
    // 1. Следующее сообщение от другого пользователя
    // 2. Прошло больше 5 минут
    // 3. Это ответ на другое сообщение
    return current.author.id != next.author.id ||
        next.timestamp.difference(current.timestamp).inMinutes > 5 ||
        next.isReply;
  }

  bool _shouldShowTimestamp(List<ChatMessage> messages, int index) {
    if (index == 0) return true;

    final current = messages[index];
    final previous = messages[index - 1];

    // Показываем timestamp если:
    // 1. Прошло больше 2 минут
    // 2. Это первое сообщение дня
    // 3. Сообщение от другого пользователя
    return current.timestamp.difference(previous.timestamp).inMinutes > 2 ||
        current.timestamp.day != previous.timestamp.day ||
        current.author.id != previous.author.id;
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.red[400]),
            onPressed: () => context.read<ChatController>().loadRoom(widget.roomId, forceRefresh: true),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.chat_bubble_outline,
          size: 64,
          color: Colors.grey,
        ),
        SizedBox(height: 16),
        Text(
          'Чат пуст',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Начните общение первым сообщением',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}