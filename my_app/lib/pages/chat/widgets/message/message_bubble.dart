import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showAvatar;
  final ThemeData theme;
  final bool isSelectionMode;
  final bool isSelected;
  final bool isExpanded;
  final bool isIncognitoMode;
  final bool showTranslation;
  final String? translation;
  final Map<String, Color> userColors;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onToggleExpansion;

  const MessageBubble({
    super.key,
    required this.message,
    required this.showAvatar,
    required this.theme,
    required this.isSelectionMode,
    required this.isSelected,
    required this.isExpanded,
    required this.isIncognitoMode,
    required this.showTranslation,
    this.translation,
    required this.userColors,
    required this.onTap,
    required this.onLongPress,
    required this.onToggleExpansion,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: theme.primaryColor) : null,
        ),
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

                Flexible(
                  child: Column(
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

                      // Message content
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: message.isMe
                              ? theme.primaryColor
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          gradient: message.isMe
                              ? LinearGradient(
                            colors: [
                              theme.primaryColor,
                              theme.primaryColor.withOpacity(0.9),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Reply indicator
                            if (message.replyTo != null) _buildReplyIndicator(),

                            // Message text
                            Text(
                              message.text,
                              style: TextStyle(
                                color: message.isMe
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurface,
                                height: 1.4,
                              ),
                              maxLines: isExpanded ? null : 10,
                              overflow: isExpanded ? null : TextOverflow.ellipsis,
                            ),

                            // Translation
                            if (showTranslation && translation != null)
                              _buildTranslation(),

                            // Expand button for long messages
                            if (message.text.length > 200 && !isExpanded)
                              _buildExpandButton(),
                          ],
                        ),
                      ),

                      // Reactions
                      if (message.reactions != null && message.reactions!.isNotEmpty)
                        _buildReactions(),

                      // Time and edit status
                      _buildMessageMeta(),
                    ],
                  ),
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

    if (message.userAvatar?.isNotEmpty == true) {
      return CachedNetworkImage(
        imageUrl: message.userAvatar!,
        imageBuilder: (context, imageProvider) => Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        placeholder: (context, url) => Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.background,
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => _buildDefaultAvatar(message, theme),
      );
    } else {
      return _buildDefaultAvatar(message, theme);
    }
  }

  Widget _buildDefaultAvatar(ChatMessage message, ThemeData theme) {
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

  Widget _buildReplyIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 20,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.replyTo!.sender,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  message.replyTo!.text,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslation() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        translation!,
        style: TextStyle(
          color: theme.colorScheme.onSurface.withOpacity(0.8),
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildExpandButton() {
    return GestureDetector(
      onTap: onToggleExpansion,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          'Развернуть...',
          style: TextStyle(
            color: message.isMe
                ? theme.colorScheme.onPrimary.withOpacity(0.8)
                : theme.primaryColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildReactions() {
    return Container(
      margin: const EdgeInsets.only(top: 6, left: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: message.reactions!.entries.map((entry) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              '${entry.key} ${entry.value}',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessageMeta() {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateFormat.Hm().format(message.time),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          if (message.isEdited) ...[
            const SizedBox(width: 6),
            Text(
              'ред.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (message.isPinned) ...[
            const SizedBox(width: 6),
            Icon(Icons.push_pin, size: 12, color: Colors.orange),
          ],
        ],
      ),
    );
  }
}