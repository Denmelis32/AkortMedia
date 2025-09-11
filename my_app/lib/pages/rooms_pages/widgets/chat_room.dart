
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models_room/discussion_topic.dart';
import '../models_room/access_level.dart';
import '../models_room/message.dart';
import 'message_bubble.dart';

class ChatRoom extends StatelessWidget {
  final DiscussionTopic topic;
  final TextEditingController messageController;
  final VoidCallback onSendMessage;
  final VoidCallback onBack;
  final String userName;
  final String? userAvatarUrl;

  const ChatRoom({
    super.key,
    required this.topic,
    required this.messageController,
    required this.onSendMessage,
    required this.onBack,
    required this.userName,
    this.userAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = topic.gradient.colors.first;
    final textColor = _getTextColorForBackground(primaryColor);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            gradient: topic.gradient,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: textColor),
                  onPressed: onBack,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${topic.messages.length} сообщений',
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                if (topic.accessLevel != AccessLevel.everyone)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      topic.accessLevel.icon,
                      color: textColor,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (topic.description.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.05),
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: primaryColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    topic.description,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: Container(
            color: Colors.grey[50],
            child: topic.messages.isNotEmpty
                ? ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: false,
              itemCount: topic.messages.length,
              itemBuilder: (context, index) {
                final message = topic.messages[index];
                final isCurrentUser = message.author == userName;
                return MessageBubble(
                  message: message,
                  isCurrentUser: isCurrentUser,
                  primaryColor: primaryColor,
                );
              },
            )
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Пока нет сообщений',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Будьте первым, кто напишет!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Напишите сообщение...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send, color: primaryColor),
                        onPressed: onSendMessage,
                      ),
                    ),
                    onSubmitted: (_) => onSendMessage(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getTextColorForBackground(Color backgroundColor) {
    final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }
}