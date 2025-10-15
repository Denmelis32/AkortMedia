import 'package:flutter/material.dart';
import 'package:my_app/pages/rooms_pages/models/room.dart';
import 'package:my_app/pages/rooms_pages/models/room_category.dart';

class CreateRoomButton extends StatefulWidget {
  final Function(Room) onRoomCreated;

  const CreateRoomButton({
    super.key,
    required this.onRoomCreated,
  });

  @override
  State<CreateRoomButton> createState() => _CreateRoomButtonState();
}

class _CreateRoomButtonState extends State<CreateRoomButton> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedImageUrl;
  bool _isPrivate = false;
  bool _isLoading = false;

  // Категории для комнат
  final List<Map<String, dynamic>> _categories = [
    {'id': 'technology', 'title': 'Технологии', 'icon': Icons.memory, 'color': Colors.orange},
    {'id': 'business', 'title': 'Бизнес', 'icon': Icons.business_center, 'color': Colors.purple},
    {'id': 'education', 'title': 'Образование', 'icon': Icons.school, 'color': Colors.teal},
    {'id': 'entertainment', 'title': 'Развлечения', 'icon': Icons.movie, 'color': Colors.pink},
    {'id': 'sports', 'title': 'Спорт', 'icon': Icons.sports_soccer, 'color': Colors.red},
    {'id': 'music', 'title': 'Музыка', 'icon': Icons.music_note, 'color': Colors.green},
  ];

  // Предустановленные изображения
  final List<String> _presetImages = [
    'https://images.unsplash.com/photo-1511376777868-611b54f68947?w=400&h=200&fit=crop',
    'https://images.unsplash.com/photo-1531403009284-440f080d1e12?w=400&h=200&fit=crop',
    'https://images.unsplash.com/photo-1556761175-b413da4baf72?w=400&h=200&fit=crop',
    'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=400&h=200&fit=crop',
    'https://images.unsplash.com/photo-1542744173-8e7e53415bb0?w=400&h=200&fit=crop',
    'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400&h=200&fit=crop',
  ];

  void _showCreateRoomDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
                maxHeight: 700,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Заголовок
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add, color: Colors.blue, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Создать комнату',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Форма
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Поле названия
                            TextFormField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                labelText: 'Название комнаты',
                                prefixIcon: const Icon(Icons.title, size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              style: const TextStyle(fontSize: 14),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Введите название комнаты';
                                }
                                if (value.trim().length < 3) {
                                  return 'Название должно быть не менее 3 символов';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Поле описания
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: 'Описание комнаты',
                                alignLabelWithHint: true,
                                prefixIcon: const Icon(Icons.description, size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              style: const TextStyle(fontSize: 14),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Введите описание комнаты';
                                }
                                if (value.trim().length < 10) {
                                  return 'Описание должно быть не менее 10 символов';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Выбор категории
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Категория',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 50,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: _categories.map((category) {
                                      final isSelected = _selectedCategoryId == category['id'];
                                      return Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        child: ChoiceChip(
                                          label: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(category['icon'], size: 16, color: isSelected ? Colors.white : category['color']),
                                              const SizedBox(width: 4),
                                              Text(
                                                category['title'],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isSelected ? Colors.white : Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                          selected: isSelected,
                                          onSelected: (selected) {
                                            setState(() {
                                              _selectedCategoryId = selected ? category['id'] : null;
                                            });
                                          },
                                          backgroundColor: Colors.grey[100],
                                          selectedColor: category['color'],
                                          shape: StadiumBorder(
                                            side: BorderSide(
                                              color: isSelected ? category['color'] : Colors.grey[300]!,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Выбор изображения
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Обложка комнаты',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 80,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: _presetImages.map((imageUrl) {
                                      final isSelected = _selectedImageUrl == imageUrl;
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedImageUrl = imageUrl;
                                          });
                                        },
                                        child: Container(
                                          width: 120,
                                          height: 70,
                                          margin: const EdgeInsets.only(right: 8),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isSelected ? Colors.blue : Colors.grey[300]!,
                                              width: isSelected ? 3 : 1,
                                            ),
                                            image: DecorationImage(
                                              image: NetworkImage(imageUrl),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          child: isSelected
                                              ? Container(
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withOpacity(0.3),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(Icons.check, color: Colors.white, size: 24),
                                          )
                                              : null,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Поле тегов
                            TextFormField(
                              controller: _tagsController,
                              decoration: InputDecoration(
                                labelText: 'Теги (через запятую)',
                                prefixIcon: const Icon(Icons.local_offer, size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 16),

                            // Настройки приватности
                            Row(
                              children: [
                                Switch(
                                  value: _isPrivate,
                                  onChanged: (value) {
                                    setState(() {
                                      _isPrivate = value;
                                    });
                                  },
                                  activeColor: Colors.blue,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Приватная комната',
                                  style: TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Кнопки действий
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _resetForm();
                                  },
                                  child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: _isLoading ? null : () => _createRoom(setState),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                      : const Text('Создать комнату'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _createRoom(StateSetter setState) async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Выберите категорию для комнаты'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Имитация создания комнаты
      await Future.delayed(const Duration(seconds: 1));

      final selectedCategoryData = _categories.firstWhere((cat) => cat['id'] == _selectedCategoryId);

      // Создаем RoomCategory из данных
      final selectedCategory = RoomCategory(
        id: selectedCategoryData['id'],
        title: selectedCategoryData['title'],
        icon: selectedCategoryData['icon'],
        color: selectedCategoryData['color'],
      );

      final newRoom = Room(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _selectedImageUrl ?? _presetImages.first,
        currentParticipants: 1,
        messageCount: 0,
        isJoined: true,
        createdAt: DateTime.now(),
        lastActivity: DateTime.now(),
        category: selectedCategory,
        creatorId: 'current_user',
        creatorName: 'Вы',
        creatorAvatarUrl: null,
        moderators: const [],
        isPrivate: _isPrivate,
        tags: _tagsController.text
            .trim()
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList(),
        language: 'ru',
        isPinned: false,
        maxParticipants: _isPrivate ? 50 : 100,
        rules: '',
        bannedUsers: const [],
        isActive: true,
        rating: 0.0,
        ratingCount: 0,
        allowedUsers: const [],
        password: '',
        accessLevel: _isPrivate ? RoomAccessLevel.private : RoomAccessLevel.public,
        scheduledStart: null,
        duration: null,
        hasMedia: false,
        isVerified: false,
        viewCount: 0,
        favoriteCount: 0,
        customIcon: null,
        hasPendingInvite: false,
        communityId: null,
      );

      widget.onRoomCreated(newRoom);

      if (mounted) {
        Navigator.pop(context);
        _resetForm();
        _showSuccessSnackBar(context, newRoom.title);
      }
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _tagsController.clear();
    _selectedCategoryId = null;
    _selectedImageUrl = null;
    _isPrivate = false;
    _isLoading = false;
  }

  void _showSuccessSnackBar(BuildContext context, String roomTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.green, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Комната "$roomTitle" создана!',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _showCreateRoomDialog,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 4,
      child: const Icon(Icons.add, size: 24),
    );
  }
}