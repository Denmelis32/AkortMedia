import 'package:flutter/material.dart';
import '../../models/chat_message.dart';

class PinnedMessagesPanel extends StatelessWidget {
  final ThemeData theme;
  final Animation<double> animation;
  final List<ChatMessage> messages;
  final List<String> pinnedMessages;
  final VoidCallback onClose;
  final Function(ChatMessage) onMessageTap;

  const PinnedMessagesPanel({
    super.key,
    required this.theme,
    required this.animation,
    required this.messages,
    required this.pinnedMessages,
    required this.onClose,
    required this.onMessageTap,
  });

  @override
  Widget build(BuildContext context) {
    final pinnedMessagesList = messages.where((msg) => pinnedMessages.contains(msg.id)).toList();

    return SizeTransition(
      sizeFactor: animation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          border: Border(
            bottom: BorderSide(color: theme.dividerColor.withOpacity(0.3)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.push_pin, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Закрепленные сообщения',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  onPressed: onClose,
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: pinnedMessagesList.length,
                itemBuilder: (context, index) {
                  final message = pinnedMessagesList[index];
                  return GestureDetector(
                    onTap: () => onMessageTap(message),
                    child: Container(
                      width: 220,
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      message.userColor ?? theme.primaryColor,
                                      message.userColor?.withOpacity(0.7) ?? theme.primaryColor.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    message.sender[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  message.sender,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Text(
                              message.text,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.8),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}