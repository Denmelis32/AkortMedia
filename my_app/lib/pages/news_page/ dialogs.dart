import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/news_theme.dart';

class AddNewsDialog extends StatefulWidget {
  final Function(String, String, String) onAddNews;

  const AddNewsDialog({super.key, required this.onAddNews});

  @override
  State<AddNewsDialog> createState() => _AddNewsDialogState();
}

class _AddNewsDialogState extends State<AddNewsDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _hashtagsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: NewsTheme.cardColor,
            surfaceTintColor: Colors.transparent,
            title: const Text(
              'Создать новость',
              style: TextStyle(color: NewsTheme.textColor, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Заголовок * (до 20 символов)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      counterText: '${_titleController.text.length}/20',
                    ),
                    maxLength: 20,
                    onChanged: (value) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Описание * (до 240 символов)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      counterText: '${_descriptionController.text.length}/240',
                    ),
                    maxLength: 240,
                    onChanged: (value) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _hashtagsController,
                    decoration: InputDecoration(
                      labelText: 'Хештеги (через пробел)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      hintText: 'спорт новости технологии',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена', style: TextStyle(color: NewsTheme.secondaryTextColor)),
              ),
              ElevatedButton(
                onPressed: _titleController.text.isNotEmpty && _descriptionController.text.isNotEmpty
                    ? () {
                  widget.onAddNews(
                    _titleController.text,
                    _descriptionController.text,
                    _hashtagsController.text,
                  );
                  Navigator.pop(context);
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: NewsTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Создать'),
              ),
            ],
          );
        }
    );
  }
}

class EditNewsDialog extends StatefulWidget {
  final Map<String, dynamic> news;
  final Function(String, String, String) onEditNews;

  const EditNewsDialog({super.key, required this.news, required this.onEditNews});

  @override
  State<EditNewsDialog> createState() => _EditNewsDialogState();
}

class _EditNewsDialogState extends State<EditNewsDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _hashtagsController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.news['title'] ?? '');
    _descriptionController = TextEditingController(text: widget.news['description'] ?? '');
    _hashtagsController = TextEditingController(
        text: (widget.news['hashtags'] is List
            ? (widget.news['hashtags'] as List).join(' ')
            : '')
    );
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: NewsTheme.cardColor,
            surfaceTintColor: Colors.transparent,
            title: const Text(
              'Редактировать новость',
              style: TextStyle(color: NewsTheme.textColor, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Заголовок (до 20 символов)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      counterText: '${_titleController.text.length}/20',
                    ),
                    maxLength: 20,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    onChanged: (value) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Описание (до 240 символов)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      counterText: '${_descriptionController.text.length}/240',
                      alignLabelWithHint: true,
                    ),
                    maxLength: 240,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    onChanged: (value) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _hashtagsController,
                    decoration: InputDecoration(
                      labelText: 'Хештеги (через пробел, например: #спорт #новости)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена', style: TextStyle(color: NewsTheme.secondaryTextColor)),
              ),
              ElevatedButton(
                onPressed: _titleController.text.isNotEmpty && _descriptionController.text.isNotEmpty
                    ? () {
                  widget.onEditNews(
                    _titleController.text,
                    _descriptionController.text,
                    _hashtagsController.text,
                  );
                  Navigator.pop(context);
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: NewsTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Сохранить'),
              ),
            ],
          );
        }
    );
  }
}

class DeleteConfirmationDialog extends StatelessWidget {
  final VoidCallback onDelete;

  const DeleteConfirmationDialog({super.key, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: NewsTheme.cardColor,
      surfaceTintColor: Colors.transparent,
      title: const Text(
        'Удалить новость?',
        style: TextStyle(color: NewsTheme.textColor, fontWeight: FontWeight.bold),
      ),
      content: const Text(
        'Вы уверены, что хотите удалить эту новость? Это действие нельзя отменить.',
        style: TextStyle(color: NewsTheme.secondaryTextColor),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена', style: TextStyle(color: NewsTheme.secondaryTextColor)),
        ),
        ElevatedButton(
          onPressed: () {
            onDelete();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: NewsTheme.errorColor),
          child: const Text('Удалить'),
        ),
      ],
    );
  }
}

class ProfileMenu extends StatelessWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const ProfileMenu({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  Widget _buildMenuButton(IconData icon, String text, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: NewsTheme.primaryColor),
      title: Text(text, style: const TextStyle(color: NewsTheme.textColor)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 40,
            backgroundColor: NewsTheme.primaryColor,
            child: Text(
              userName[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            userName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: NewsTheme.textColor,
            ),
          ),
          Text(
            userEmail,
            style: const TextStyle(
              fontSize: 14,
              color: NewsTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 24),
          _buildMenuButton(Icons.settings, 'Настройки', () => Navigator.pop(context)),
          _buildMenuButton(Icons.help, 'Помощь', () => Navigator.pop(context)),
          _buildMenuButton(Icons.info, 'О приложении', () => Navigator.pop(context)),
          _buildMenuButton(Icons.logout, 'Выйти', () {
            Navigator.pop(context);
            onLogout();
          }),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}