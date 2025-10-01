import 'package:flutter/material.dart';
import '../../models/chat_message.dart';

class StickerMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showAvatar;
  final ThemeData theme;
  final bool isIncognitoMode;
  final Map<String, Color> userColors;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const StickerMessageBubble({
    super.key,
    required this.message,
    required this.showAvatar,
    required this.theme,
    required this.isIncognitoMode,
    required this.userColors,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!message.isMe && showAvatar)
                  _buildUserAvatar(message, theme),
                if (!message.isMe && showAvatar) const SizedBox(width: 8),

                Column(
                  crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (!message.isMe && showAvatar)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6, left: 8),
                        child: Text(
                          message.sender,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        message.text,
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ],
                ),

                if (message.isMe) const SizedBox(width: 8),
                if (message.isMe && showAvatar)
                  _buildUserAvatar(message, theme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar(ChatMessage message, ThemeData theme) {
    if (isIncognitoMode && !message.isMe) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.withOpacity(0.5),
        ),
        child: Icon(
          Icons.visibility_off,
          color: Colors.white,
          size: 18,
        ),
      );
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            message.userColor ?? theme.primaryColor,
            message.userColor?.withOpacity(0.7) ?? theme.primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (message.userColor ?? theme.primaryColor).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          message.sender[0].toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}