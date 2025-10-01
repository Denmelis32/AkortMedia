import 'package:flutter/material.dart';
import '../../models/chat_message.dart';

class VoiceMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showAvatar;
  final ThemeData theme;
  final bool isIncognitoMode;
  final Map<String, Color> userColors;
  final bool isPlaying;
  final double progress;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onPlay;
  final VoidCallback onStop;

  const VoiceMessageBubble({
    super.key,
    required this.message,
    required this.showAvatar,
    required this.theme,
    required this.isIncognitoMode,
    required this.userColors,
    required this.isPlaying,
    required this.progress,
    required this.onTap,
    required this.onLongPress,
    required this.onPlay,
    required this.onStop,
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
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.6,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: message.isMe ? theme.primaryColor : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: message.isMe ? theme.colorScheme.onPrimary : theme.primaryColor,
                            ),
                            onPressed: isPlaying ? onStop : onPlay,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Голосовое сообщение',
                                  style: TextStyle(
                                    color: message.isMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: isPlaying ? progress : 0.0,
                                  backgroundColor: message.isMe
                                      ? theme.colorScheme.onPrimary.withOpacity(0.3)
                                      : theme.primaryColor.withOpacity(0.3),
                                  valueColor: AlwaysStoppedAnimation(
                                    message.isMe ? theme.colorScheme.onPrimary : theme.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${message.voiceDuration?.toStringAsFixed(1) ?? '0'} сек',
                                  style: TextStyle(
                                    color: message.isMe
                                        ? theme.colorScheme.onPrimary.withOpacity(0.7)
                                        : theme.colorScheme.onSurface.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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