import 'package:flutter/material.dart';
import '../models/channel.dart';

class ContentTypeDialog extends StatelessWidget {
  final Channel channel;
  final VoidCallback onAddPost;
  final VoidCallback onAddArticle;
  final VoidCallback onAddDiscussion;

  const ContentTypeDialog({
    super.key,
    required this.channel,
    required this.onAddPost,
    required this.onAddArticle,
    required this.onAddDiscussion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            const SizedBox(height: 24),
            _buildTitle(context),
            const SizedBox(height: 24),
            _buildContentTypeOption(
              context,
              icon: Icons.article_outlined,
              title: 'Создать новость',
              subtitle: 'Поделитесь новостями с сообществом',
              onTap: () {
                Navigator.pop(context);
                onAddPost();
              },
              color: channel.cardColor,
            ),
            const SizedBox(height: 16),
            _buildContentTypeOption(
              context,
              icon: Icons.library_books_outlined,
              title: 'Создать статью',
              subtitle: 'Напишите подробный материал',
              onTap: () {
                Navigator.pop(context);
                onAddArticle();
              },
              color: Colors.purple,
            ),
            const SizedBox(height: 16),
            _buildContentTypeOption(
              context,
              icon: Icons.forum_outlined,
              title: 'Создать обсуждение',
              subtitle: 'Начните новую дискуссию',
              onTap: () {
                Navigator.pop(context);
                onAddDiscussion();
              },
              color: Colors.orange,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 48,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'Создать контент',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildContentTypeOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
        required Color color,
      }) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}