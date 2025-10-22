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
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _maxParticipantsController = TextEditingController(text: '50');

  String? _selectedCategoryId;
  String? _selectedImageUrl;
  bool _isLoading = false;

  // Типы доступа к комнате
  RoomAccessType _selectedAccessType = RoomAccessType.public;

  // Настройки планирования
  DateTime? _scheduledStart;
  TimeOfDay? _scheduledTime;
  int _selectedDuration = 60; // минуты

  // Категории для комнат
  final List<Map<String, dynamic>> _categories = [
    {'id': 'technology', 'title': 'Технологии', 'icon': Icons.memory, 'color': Colors.orange},
    {'id': 'business', 'title': 'Бизнес', 'icon': Icons.business_center, 'color': Colors.purple},
    {'id': 'education', 'title': 'Образование', 'icon': Icons.school, 'color': Colors.teal},
    {'id': 'entertainment', 'title': 'Развлечения', 'icon': Icons.movie, 'color': Colors.pink},
    {'id': 'sports', 'title': 'Спорт', 'icon': Icons.sports_soccer, 'color': Colors.red},
    {'id': 'music', 'title': 'Музыка', 'icon': Icons.music_note, 'color': Colors.green},
    {'id': 'art', 'title': 'Искусство', 'icon': Icons.palette, 'color': Colors.deepOrange},
    {'id': 'science', 'title': 'Наука', 'icon': Icons.science, 'color': Colors.indigo},
  ];

  // Предустановленные изображения
  final List<String> _presetImages = [
    'https://avatars.mds.yandex.net/i?id=2f85de17ce3e2246fd9d3814d3fd4ecb_l-10099509-images-thumbs&n=13',
    'https://avatars.mds.yandex.net/i?id=add7485d4ee3bab4d02f65cb6a2af84d_l-10507506-images-thumbs&n=13',
    'https://avatars.mds.yandex.net/i?id=64e305545175ee32bf9f64b582ba9cb27e01c36d-8186184-images-thumbs&ref=rim&n=33&w=480&h=270',
    'https://avatars.mds.yandex.net/i?id=caab725e53c871925c986a916afeebda_l-13734741-images-thumbs&n=13',
    'https://avatars.mds.yandex.net/i?id=397878960b95f979b9048b782d714ead_l-5336169-images-thumbs&n=13',
    'https://avatars.mds.yandex.net/i?id=afbd7642e852a1eb5203048042bb5fe0_l-10702804-images-thumbs&n=13',
  ];

  // Типы доступа
  final List<Map<String, dynamic>> _accessTypes = [
    {
      'type': RoomAccessType.public,
      'title': 'Публичная',
      'description': 'Видна всем пользователям',
      'icon': Icons.public,
      'color': Colors.green
    },
    {
      'type': RoomAccessType.private,
      'title': 'Закрытая',
      'description': 'Только по приглашению',
      'icon': Icons.lock,
      'color': Colors.orange
    },
    {
      'type': RoomAccessType.password,
      'title': 'С паролем',
      'description': 'Доступ по паролю',
      'icon': Icons.password,
      'color': Colors.blue
    },
  ];

  void _showCreateRoomDialog() {
    // Сброс формы при открытии диалога
    _resetForm();

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
                maxWidth: 550,
                maxHeight: 800,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Заголовок
                      _buildDialogHeader(),
                      const SizedBox(height: 20),

                      // Форма
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Основная информация
                            _buildBasicInfoSection(setState),
                            const SizedBox(height: 20),

                            // Настройки доступа
                            _buildAccessSettingsSection(setState),
                            const SizedBox(height: 20),

                            // Дополнительные настройки
                            _buildAdditionalSettingsSection(setState),
                            const SizedBox(height: 24),

                            // Кнопки действий
                            _buildActionButtons(setState),
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

  Widget _buildDialogHeader() {
    return Row(
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
    );
  }

  Widget _buildBasicInfoSection(StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Основная информация',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 16),

        // Поле названия
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Название комнаты',
            hintText: 'Введите интересное название',
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
            hintText: 'Опишите тему и цели вашей комнаты',
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
              'Категория *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((category) {
                final isSelected = _selectedCategoryId == category['id'];
                return ChoiceChip(
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
                );
              }).toList(),
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
            hintText: 'технологии, программирование, flutter',
            prefixIcon: const Icon(Icons.local_offer, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildAccessSettingsSection(StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Настройки доступа',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 16),

        // Типы доступа
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _accessTypes.map((accessType) {
            final isSelected = _selectedAccessType == accessType['type'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAccessType = accessType['type'];
                  if (_selectedAccessType != RoomAccessType.password) {
                    _passwordController.clear();
                  }
                });
              },
              child: Container(
                width: 160,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? accessType['color'] : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected ? accessType['color'].withOpacity(0.1) : Colors.grey[50],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(accessType['icon'], color: accessType['color'], size: 24),
                    const SizedBox(height: 8),
                    Text(
                      accessType['title'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: accessType['color'],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      accessType['description'],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Поле пароля (только для комнат с паролем)
        if (_selectedAccessType == RoomAccessType.password) ...[
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Пароль для входа',
              hintText: 'Введите пароль',
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: const TextStyle(fontSize: 14),
            validator: (value) {
              if (_selectedAccessType == RoomAccessType.password && (value == null || value.trim().isEmpty)) {
                return 'Введите пароль для комнаты';
              }
              if (_selectedAccessType == RoomAccessType.password && value!.trim().length < 4) {
                return 'Пароль должен быть не менее 4 символов';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Пользователям нужно будет ввести этот пароль для входа в комнату',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
        ],

        // Максимальное количество участников
        TextFormField(
          controller: _maxParticipantsController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Максимальное количество участников',
            prefixIcon: const Icon(Icons.people_outline, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: const TextStyle(fontSize: 14),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Введите количество участников';
            }
            final count = int.tryParse(value);
            if (count == null || count < 2 || count > 500) {
              return 'Введите число от 2 до 500';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAdditionalSettingsSection(StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Дополнительные настройки',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 16),

        // Планирование начала
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Запланировать начало',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _scheduledStart = date;
                        });
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _scheduledStart == null
                          ? 'Выберите дату'
                          : '${_scheduledStart!.day}.${_scheduledStart!.month}.${_scheduledStart!.year}',
                      style: TextStyle(
                        color: _scheduledStart == null ? Colors.grey : Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          _scheduledTime = time;
                        });
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _scheduledTime == null
                          ? 'Выберите время'
                          : _scheduledTime!.format(context),
                      style: TextStyle(
                        color: _scheduledTime == null ? Colors.grey : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Длительность комнаты
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Планируемая длительность',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _selectedDuration,
              items: const [
                DropdownMenuItem(value: 30, child: Text('30 минут')),
                DropdownMenuItem(value: 60, child: Text('1 час')),
                DropdownMenuItem(value: 120, child: Text('2 часа')),
                DropdownMenuItem(value: 180, child: Text('3 часа')),
                DropdownMenuItem(value: -1, child: Text('Не ограничено')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedDuration = value!;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(StateSetter setState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _resetForm();
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
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
              : const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 18),
              SizedBox(width: 8),
              Text('Создать комнату'),
            ],
          ),
        ),
      ],
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

      // Формируем scheduledDateTime
      DateTime? scheduledDateTime;
      if (_scheduledStart != null && _scheduledTime != null) {
        scheduledDateTime = DateTime(
          _scheduledStart!.year,
          _scheduledStart!.month,
          _scheduledStart!.day,
          _scheduledTime!.hour,
          _scheduledTime!.minute,
        );
      }

      // Получаем соответствующий RoomAccessLevel
      final RoomAccessLevel accessLevel;
      switch (_selectedAccessType) {
        case RoomAccessType.public:
          accessLevel = RoomAccessLevel.public;
          break;
        case RoomAccessType.private:
          accessLevel = RoomAccessLevel.private;
          break;
        case RoomAccessType.password:
          accessLevel = RoomAccessLevel.protected;
          break;
      }

      // Для приватных комнат добавляем текущего пользователя в allowedUsers
      final List<String> allowedUsers = _selectedAccessType == RoomAccessType.private
          ? ['current_user']
          : [];

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
        isPrivate: _selectedAccessType != RoomAccessType.public,
        tags: _tagsController.text
            .trim()
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList(),
        language: 'ru',
        isPinned: false,
        maxParticipants: int.parse(_maxParticipantsController.text),
        rules: '',
        bannedUsers: const [],
        isActive: true,
        rating: 0.0,
        ratingCount: 0,
        allowedUsers: allowedUsers,
        password: _passwordController.text.trim(),
        accessLevel: accessLevel,
        scheduledStart: scheduledDateTime,
        duration: _selectedDuration == -1 ? null : Duration(minutes: _selectedDuration),
        hasMedia: false,
        isVerified: false,
        viewCount: 0,
        favoriteCount: 0,
        customIcon: null,
        hasPendingInvite: false,
        communityId: null,
        accessType: _selectedAccessType,
      );

      widget.onRoomCreated(newRoom);

      if (mounted) {
        Navigator.pop(context); // Закрываем диалог
        _resetForm();
        _showSuccessSnackBar(context, newRoom.title, newRoom.accessType);
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _tagsController.clear();
    _passwordController.clear();
    _maxParticipantsController.text = '50';
    _selectedCategoryId = null;
    _selectedImageUrl = null;
    _selectedAccessType = RoomAccessType.public;
    _isLoading = false;
    _scheduledStart = null;
    _scheduledTime = null;
    _selectedDuration = 60;
  }

  void _showSuccessSnackBar(BuildContext context, String roomTitle, RoomAccessType accessType) {
    String message;
    Color color;
    IconData icon;

    switch (accessType) {
      case RoomAccessType.public:
        message = 'Публичная комната "$roomTitle" создана!';
        color = Colors.green;
        icon = Icons.public;
      case RoomAccessType.private:
        message = 'Закрытая комната "$roomTitle" создана! Приглашайте участников.';
        color = Colors.orange;
        icon = Icons.lock;
      case RoomAccessType.password:
        message = 'Комната "$roomTitle" с паролем создана!';
        color = Colors.blue;
        icon = Icons.password;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _passwordController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _showCreateRoomDialog,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 4,
      tooltip: 'Создать комнату',
      child: const Icon(Icons.add, size: 24),
    );
  }
}