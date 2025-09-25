// lib/pages/cards_page/widgets/chat_dialog.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/chat_message.dart';
import '../models/channel.dart';

class ChatDialog extends StatefulWidget {
  final List<ChatMessage> messages;
  final Channel channel;
  final ValueChanged<String> onSendMessage;
  final VoidCallback? onClose;

  const ChatDialog({
    super.key,
    required this.messages,
    required this.channel,
    required this.onSendMessage,
    this.onClose,
  });

  @override
  State<ChatDialog> createState() => _ChatDialogState();
}

class _ChatDialogState extends State<ChatDialog> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(animated: false);
      _messageFocusNode.requestFocus();
    });
  }

  @override
  void didUpdateWidget(covariant ChatDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length > oldWidget.messages.length) {
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;

    if (animated) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    widget.onSendMessage(message);
    _messageController.clear();
    _scrollToBottom();
  }

  void _handleClose() {
    widget.onClose?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 700,
          minHeight: 400,
        ),
        child: Material(
          borderRadius: BorderRadius.circular(24),
          color: colorScheme.surface,
          elevation: 24,
          shadowColor: Colors.black.withOpacity(0.3),
          child: Column(
            children: [
              // Header
              _ChatHeader(
                channel: widget.channel,
                messageCount: widget.messages.length,
                onClose: _handleClose,
              ),

              // Messages List
              Expanded(
                child: _MessagesList(
                  messages: widget.messages,
                  scrollController: _scrollController,
                  channelColor: widget.channel.cardColor,
                ),
              ),

              // Input Section
              _MessageInput(
                controller: _messageController,
                focusNode: _messageFocusNode,
                channelColor: widget.channel.cardColor,
                onSendMessage: _sendMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  final Channel channel;
  final int messageCount;
  final VoidCallback onClose;

  const _ChatHeader({
    required this.channel,
    required this.messageCount,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: channel.cardColor.withOpacity(0.08),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          // Channel Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: channel.cardColor.withOpacity(0.2),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: channel.imageUrl,
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Icon(
                  Icons.chat,
                  color: channel.cardColor,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Channel Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Чат канала ${channel.title}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _getMessageCountText(messageCount),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Close Button
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey.shade600),
            onPressed: onClose,
            tooltip: 'Закрыть',
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  String _getMessageCountText(int count) {
    if (count % 10 == 1 && count % 100 != 11) return '$count сообщение';
    if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)) {
      return '$count сообщения';
    }
    return '$count сообщений';
  }
}

class _MessagesList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final Color channelColor;

  const _MessagesList({
    required this.messages,
    required this.scrollController,
    required this.channelColor,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const _EmptyChatState();
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final showAvatar = index == 0 ||
            messages[index - 1].isMe != message.isMe ||
            messages[index - 1].senderId != message.senderId;

        return _MessageBubble(
          message: message,
          channelColor: channelColor,
          showAvatar: showAvatar,
          isLastInGroup: index == messages.length - 1 ||
              messages[index + 1].isMe != message.isMe ||
              messages[index + 1].senderId != message.senderId,
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Color channelColor;
  final bool showAvatar;
  final bool isLastInGroup;

  const _MessageBubble({
    required this.message,
    required this.channelColor,
    required this.showAvatar,
    required this.isLastInGroup,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: isLastInGroup ? 12 : 4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isMe && showAvatar)
            _MessageAvatar(imageUrl: message.senderImageUrl),
          if (!message.isMe && !showAvatar) const SizedBox(width: 40),

          Expanded(
            child: Column(
              crossAxisAlignment: message.isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!message.isMe && showAvatar)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 2),
                    child: Text(
                      message.senderName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: message.isMe ? channelColor : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: message.isMe ? [
                      BoxShadow(
                        color: channelColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isMe ? Colors.white : Colors.grey.shade800,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                ),

                if (isLastInGroup)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, right: 8, left: 8),
                    child: Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          if (message.isMe && showAvatar)
            _UserAvatar(),
          if (message.isMe && !showAvatar) const SizedBox(width: 40),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Вчера ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day.toString().padLeft(2, '0')}.${timestamp.month.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

class _MessageAvatar extends StatelessWidget {
  final String imageUrl;

  const _MessageAvatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: Colors.grey.shade300,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => Icon(
              Icons.person,
              size: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: Colors.grey.shade400,
        child: const Icon(
          Icons.person,
          size: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Color channelColor;
  final VoidCallback onSendMessage;

  const _MessageInput({
    required this.controller,
    required this.focusNode,
    required this.channelColor,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'Напишите сообщение...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: controller.text.trim().isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.close, size: 16, color: Colors.grey.shade500),
                  onPressed: () => controller.clear(),
                  splashRadius: 16,
                )
                    : null,
              ),
              maxLines: 3,
              minLines: 1,
              onSubmitted: (_) => onSendMessage(),
              textInputAction: TextInputAction.send,
            ),
          ),

          const SizedBox(width: 8),

          // Send Button
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: controller.text.trim().isNotEmpty
                  ? channelColor
                  : Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: controller.text.trim().isNotEmpty ? onSendMessage : null,
              splashRadius: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  const _EmptyChatState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Пока нет сообщений',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Напишите первое сообщение в чат',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}