import 'package:flutter/material.dart';

class AttachmentMenuDialog extends StatelessWidget {
  final ThemeData theme;
  final VoidCallback onPhotoSelected;
  final VoidCallback onVideoSelected;
  final VoidCallback onFileSelected;
  final VoidCallback onLocationSelected;
  final VoidCallback onPollSelected;
  final VoidCallback onEventSelected;
  final VoidCallback onContactSelected;
  final VoidCallback onAudioSelected;

  const AttachmentMenuDialog({
    super.key,
    required this.theme,
    required this.onPhotoSelected,
    required this.onVideoSelected,
    required this.onFileSelected,
    required this.onLocationSelected,
    required this.onPollSelected,
    required this.onEventSelected,
    required this.onContactSelected,
    required this.onAudioSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Прикрепить файл',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAttachmentOption(
                    context: context,
                    icon: Icons.photo,
                    text: 'Фото',
                    color: Colors.green,
                    onTap: onPhotoSelected,
                  ),
                  _buildAttachmentOption(
                    context: context,
                    icon: Icons.videocam,
                    text: 'Видео',
                    color: Colors.blue,
                    onTap: onVideoSelected,
                  ),
                  _buildAttachmentOption(
                    context: context,
                    icon: Icons.attach_file,
                    text: 'Файл',
                    color: Colors.orange,
                    onTap: onFileSelected,
                  ),
                  _buildAttachmentOption(
                    context: context,
                    icon: Icons.location_on,
                    text: 'Местоположение',
                    color: Colors.red,
                    onTap: onLocationSelected,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAttachmentOption(
                    context: context,
                    icon: Icons.poll,
                    text: 'Опрос',
                    color: Colors.purple,
                    onTap: onPollSelected,
                  ),
                  _buildAttachmentOption(
                    context: context,
                    icon: Icons.event,
                    text: 'Событие',
                    color: Colors.teal,
                    onTap: onEventSelected,
                  ),
                  _buildAttachmentOption(
                    context: context,
                    icon: Icons.contact_page,
                    text: 'Контакты',
                    color: Colors.brown,
                    onTap: onContactSelected,
                  ),
                  _buildAttachmentOption(
                    context: context,
                    icon: Icons.music_note,
                    text: 'Аудио',
                    color: Colors.pink,
                    onTap: onAudioSelected,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurface,
                  side: BorderSide(color: theme.dividerColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Отмена'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required BuildContext context,
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // Теперь context доступен
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}