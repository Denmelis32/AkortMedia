import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class MessageUtils {
  static Color getUserColor(String userName, Map<String, Color> userColors) {
    if (!userColors.containsKey(userName)) {
      userColors[userName] = Colors.primaries[userName.hashCode % Colors.primaries.length].shade600;
    }
    return userColors[userName]!;
  }

  static String formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'только что';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} мин';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ч';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} д';
    } else {
      return '${time.day}.${time.month}.${time.year}';
    }
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1048576) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    }
  }

  static bool shouldShowAvatar(int index, List<ChatMessage> messages) {
    if (index == 0) return true;

    final currentMessage = messages[index];
    final previousMessage = messages[index - 1];

    return previousMessage.sender != currentMessage.sender ||
        currentMessage.time.difference(previousMessage.time).inMinutes > 5;
  }

  static String getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name.substring(0, 1).toUpperCase();
    }
    return '?';
  }
}