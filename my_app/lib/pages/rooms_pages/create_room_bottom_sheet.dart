import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/room.dart';
import '../../providers/room_provider.dart';

class CreateRoomBottomSheet extends StatefulWidget {
  const CreateRoomBottomSheet({super.key});

  @override
  State<CreateRoomBottomSheet> createState() => _CreateRoomBottomSheetState();
}

class _CreateRoomBottomSheetState extends State<CreateRoomBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  RoomCategory _selectedCategory = RoomCategory.all;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Создать новое обсуждение',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Название',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите название обсуждения';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите описание обсуждения';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RoomCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Категория',
                  border: OutlineInputBorder(),
                ),
                items: RoomCategory.values.map((category) {
                  return DropdownMenuItem<RoomCategory>(
                    value: category,
                    child: Text(category.title),
                  );
                }).toList(),
                onChanged: (category) {
                  if (category != null) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createRoom,
                  child: const Text('Создать обсуждение'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createRoom() {
    if (_formKey.currentState!.validate()) {
      final roomProvider = context.read<RoomProvider>();
      final newRoom = Room(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        imageUrl: '', // URL изображения по умолчанию
        participants: 1, // Вы создатель, поэтому 1 участник
        messages: 0, // Пока нет сообщений
        isJoined: true, // Вы автоматически присоединяетесь к созданной комнате
        createdAt: DateTime.now(),
        lastActivity: DateTime.now(), // Текущее время как последняя активность
        category: _selectedCategory,
        creatorId: 'current_user_id', // ID текущего пользователя
        moderators: const [], // Пустой список модераторов
        isPrivate: false, // По умолчанию публичная комната
        tags: const [], // Пустой список тегов
      );

      roomProvider.addRoom(newRoom);
      Navigator.pop(context);
    }
  }
}