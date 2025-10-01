import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import '../../models/enums.dart';
import 'message_bubble.dart';
import 'voice_message_bubble.dart';
import 'sticker_message_bubble.dart';
import 'system_message_bubble.dart';
import '../panels/typing_indicator.dart';

class MessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final String typingUser;
  final bool isSelectionMode;
  final Map<String, bool> selectedMessages;
  final Map<String, bool> expandedMessages;
  final bool isIncognitoMode;
  final bool showMessageTranslation;
  final Map<String, String> messageTranslations;
  final Map<String, Color> userColors;
  final Function(ChatMessage) onMessageTap;
  final Function(ChatMessage) onMessageLongPress;
  final Function(String) onToggleExpansion;
  final Function(ChatMessage) onPlayVoiceMessage;
  final Function() onStopVoiceMessage;
  final bool isVoiceMessagePlaying;
  final String playingVoiceMessageId; // ИСПРАВЛЕНО: теперь String
  final double voiceMessageProgress;

  const MessageList({
    super.key,
    required this.messages,
    required this.scrollController,
    required this.typingUser,
    required this.isSelectionMode,
    required this.selectedMessages,
    required this.expandedMessages,
    required this.isIncognitoMode,
    required this.showMessageTranslation,
    required this.messageTranslations,
    required this.userColors,
    required this.onMessageTap,
    required this.onMessageLongPress,
    required this.onToggleExpansion,
    required this.onPlayVoiceMessage,
    required this.onStopVoiceMessage,
    required this.isVoiceMessagePlaying,
    required this.playingVoiceMessageId, // ИСПРАВЛЕНО: теперь String
    required this.voiceMessageProgress,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length + (typingUser.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < messages.length) {
          final message = messages[index];
          final showAvatar = _shouldShowAvatar(index, messages);

          return _buildMessageBubble(message, showAvatar, context);
        } else {
          return TypingIndicator(
            theme: Theme.of(context),
            typingUser: typingUser,
            animationController: AnimationController(
              duration: const Duration(milliseconds: 1500),
              vsync: Navigator.of(context),
            )..repeat(reverse: true),
          );
        }
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool showAvatar, BuildContext context) {
    final theme = Theme.of(context);

    switch (message.messageType) {
      case MessageType.system:
        return SystemMessageBubble(
          message: message,
          theme: theme,
        );
      case MessageType.sticker:
        return StickerMessageBubble(
          message: message,
          showAvatar: showAvatar,
          theme: theme,
          isIncognitoMode: isIncognitoMode,
          userColors: userColors,
          onTap: () => onMessageTap(message),
          onLongPress: () => onMessageLongPress(message),
        );
      case MessageType.voice:
        return VoiceMessageBubble(
          message: message,
          showAvatar: showAvatar,
          theme: theme,
          isIncognitoMode: isIncognitoMode,
          userColors: userColors,
          // ИСПРАВЛЕНИЕ: Сравниваем строки, а не преобразуем в int
          isPlaying: isVoiceMessagePlaying && playingVoiceMessageId == message.id,
          progress: voiceMessageProgress,
          onTap: () => onMessageTap(message),
          onLongPress: () => onMessageLongPress(message),
          onPlay: () => onPlayVoiceMessage(message),
          onStop: onStopVoiceMessage,
        );
      default:
        return MessageBubble(
          message: message,
          showAvatar: showAvatar,
          theme: theme,
          isSelectionMode: isSelectionMode,
          isSelected: selectedMessages[message.id] ?? false,
          isExpanded: expandedMessages[message.id] ?? false,
          isIncognitoMode: isIncognitoMode,
          showTranslation: showMessageTranslation,
          translation: messageTranslations[message.id],
          userColors: userColors,
          onTap: () => onMessageTap(message),
          onLongPress: () => onMessageLongPress(message),
          onToggleExpansion: () => onToggleExpansion(message.id),
        );
    }
  }

  bool _shouldShowAvatar(int index, List<ChatMessage> messages) {
    if (index == 0) return true;

    final currentMessage = messages[index];
    final previousMessage = messages[index - 1];

    return previousMessage.sender != currentMessage.sender ||
        currentMessage.time.difference(previousMessage.time).inMinutes > 5;
  }
}