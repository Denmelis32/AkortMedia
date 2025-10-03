// widgets/bottom_sheets/create_community_discussion_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/user_provider.dart';

class CreateCommunityDiscussionBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onDiscussionCreated;
  final String userName;

  const CreateCommunityDiscussionBottomSheet({
    super.key,
    required this.onDiscussionCreated,
    required this.userName,
  });

  @override
  State<CreateCommunityDiscussionBottomSheet> createState() => _CreateCommunityDiscussionBottomSheetState();
}

class _CreateCommunityDiscussionBottomSheetState extends State<CreateCommunityDiscussionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCategory = 'Общее';

  final List<String> _categories = [
    'Общее',
    'Технологии',
    'Программирование',
    'Новости',
    'Проекты',
    'Вопросы',
    'Идеи'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Новое обсуждение',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Заголовок обсуждения',
                border: OutlineInputBorder(),
                hintText: 'Введите заголовок...',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите заголовок';
                }
                if (value.length < 5) {
                  return 'Заголовок должен быть не менее 5 символов';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Категория',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Содержание',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
                hintText: 'Опишите ваше обсуждение...',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите содержание обсуждения';
                }
                if (value.length < 10) {
                  return 'Содержание должно быть не менее 10 символов';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createDiscussion,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Создать обсуждение'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _createDiscussion() {
    if (_formKey.currentState!.validate()) {
      final discussion = {
        'title': _titleController.text,
        'content': _contentController.text,
        'category': _selectedCategory,
        'createdAt': DateTime.now(),
        'author': widget.userName,
        'replies': 0,
      };

      widget.onDiscussionCreated(discussion);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}