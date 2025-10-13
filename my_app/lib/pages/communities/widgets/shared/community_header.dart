import 'package:flutter/material.dart';
import '../../models/community.dart';

class CommunityHeader extends StatefulWidget {
  final Community community;
  final bool editable;
  final Function(String) onAvatarChanged;
  final Function(String) onCoverChanged;
  final Function(List<String>) onHashtagsChanged;

  const CommunityHeader({
    super.key,
    required this.community,
    required this.editable,
    required this.onAvatarChanged,
    required this.onCoverChanged,
    required this.onHashtagsChanged,
  });

  @override
  State<CommunityHeader> createState() => _CommunityHeaderState();
}

class _CommunityHeaderState extends State<CommunityHeader> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Обложка
        Container(
          height: 280,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(widget.community.coverImageUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),
        ),

        // Аватар и информация
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Аватар
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(widget.community.imageUrl),
                  backgroundColor: widget.community.cardColor,
                ),
              ),

              const SizedBox(width: 16),

              // Информация
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.community.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.community.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatChip(
                          '${widget.community.membersCount} участников',
                        ),
                        const SizedBox(width: 8),
                        if (widget.community.isPrivate)
                          _buildStatChip(
                            'Приватное',
                            icon: Icons.lock,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Кнопка редактирования (если доступно)
        if (widget.editable)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                onPressed: () {
                  _showEditOptions();
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatChip(String text, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Изменить обложку'),
                onTap: () {
                  Navigator.pop(context);
                  _changeCoverImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Изменить аватар'),
                onTap: () {
                  Navigator.pop(context);
                  _changeAvatarImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.tag),
                title: const Text('Изменить теги'),
                onTap: () {
                  Navigator.pop(context);
                  _changeHashtags();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _changeCoverImage() {
    // Реализация изменения обложки
    debugPrint('Change cover image');
  }

  void _changeAvatarImage() {
    // Реализация изменения аватара
    debugPrint('Change avatar image');
  }

  void _changeHashtags() {
    // Реализация изменения тегов
    debugPrint('Change hashtags');
  }
}