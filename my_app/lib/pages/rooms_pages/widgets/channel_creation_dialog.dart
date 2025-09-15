import 'package:flutter/material.dart';
import '../models_room/channel.dart';

class ChannelCreationDialog extends StatefulWidget {
  final String categoryId;
  final String userId;
  final String userName;
  final Function(Channel) onChannelCreated;

  const ChannelCreationDialog({
    super.key,
    required this.categoryId,
    required this.userId,
    required this.userName,
    required this.onChannelCreated,
  });

  @override
  State<ChannelCreationDialog> createState() => _ChannelCreationDialogState();
}

class _ChannelCreationDialogState extends State<ChannelCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<String> _selectedTags = [];

  final List<String> _availableTags = [
    'Футбол', 'Твич', 'Программирование', 'Flutter', 'Dart', 'Игры',
    'Технологии', 'Стримы', 'Обсуждение', 'Ютуб', 'Спорт', 'Киберспорт',
    'Бизнес', 'Стартапы', 'Инвестиции', 'Маркетинг', 'Карьера', 'Общение',
    'Психология', 'Отношения', 'Социум', 'Саморазвитие', 'Книги', 'Мотивация',
    'Здоровье', 'Медитация',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createChannel() {
    if (_formKey.currentState!.validate()) {
      final newChannel = Channel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        ownerId: widget.userId,
        ownerName: widget.userName,
        ownerAvatarUrl: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(widget.userName)}&background=007AFF',
        categoryId: widget.categoryId,
        createdAt: DateTime.now(),
        subscribersCount: 1, // Создатель автоматически подписан
        tags: List.from(_selectedTags),
        recentTopicIds: [],
      );

      widget.onChannelCreated(newChannel);
      Navigator.pop(context);
    }
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else if (_selectedTags.length < 3) {
        _selectedTags.add(tag);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Можно выбрать не более 3 тегов')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Создать новый канал',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Название канала *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите название канала';
                        }
                        if (value.length < 3) {
                          return 'Название должно быть не менее 3 символов';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Описание канала *',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите описание канала';
                        }
                        if (value.length < 10) {
                          return 'Описание должно быть не менее 10 символов';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Выберите теги (максимум 3):',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: _availableTags.map((tag) => FilterChip(
                            label: Text(tag),
                            selected: _selectedTags.contains(tag),
                            onSelected: (_) => _toggleTag(tag),
                            selectedColor: Colors.blue[100],
                            checkmarkColor: Colors.blue,
                          )).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Выбрано: ${_selectedTags.length}/3',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Отмена'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _createChannel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Создать канал'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}