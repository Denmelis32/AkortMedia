// widgets/bottom_sheets/create_community_bottom_sheet.dart
import 'package:flutter/material.dart';
import '../models/community.dart';

class CreateCommunityBottomSheet extends StatefulWidget {
  final Function(Community) onCommunityCreated;

  const CreateCommunityBottomSheet({
    super.key,
    required this.onCommunityCreated,
  });

  @override
  State<CreateCommunityBottomSheet> createState() => _CreateCommunityBottomSheetState();
}

class _CreateCommunityBottomSheetState extends State<CreateCommunityBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _welcomeMessageController = TextEditingController();
  final _rulesController = TextEditingController();

  String _selectedCategory = 'Технологии';
  bool _isPrivate = false;
  bool _allowUserRooms = true;
  bool _requireApproval = false;
  int _currentStep = 0;

  final List<String> _categories = [
    'Технологии',
    'Игры',
    'Социальное',
    'Путешествия',
    'Образование',
    'Бизнес',
    'Искусство',
    'Музыка',
    'Наука',
    'Спорт',
    'Программирование',
    'Дизайн',
    'Фотография',
    'Кулинария',
    'Здоровье'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Заголовок и прогресс
          _buildHeader(context),
          const SizedBox(height: 16),

          // Индикатор прогресса
          _buildProgressIndicator(),
          const SizedBox(height: 24),

          // Контент шагов
          Expanded(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: PageController(initialPage: _currentStep),
              children: [
                _buildBasicInfoStep(),
                _buildSettingsStep(),
                _buildAppearanceStep(),
                _buildPreviewStep(),
              ],
            ),
          ),

          // Кнопки навигации
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 8),
        Text(
          'Создать сообщество',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Text(
          '${_currentStep + 1}/4',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(4, (index) {
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
            decoration: BoxDecoration(
              color: index <= _currentStep
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBasicInfoStep() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Основная информация',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Расскажите о вашем сообществе',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),

            // Название
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Название сообщества',
                hintText: 'Например: Крутые бобры',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.people_alt_rounded),
                filled: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите название';
                }
                if (value.length < 3) {
                  return 'Название должно быть не менее 3 символов';
                }
                if (value.length > 50) {
                  return 'Название должно быть не более 50 символов';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Категория
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Категория',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.category_rounded),
                filled: true,
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

            // Описание
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Описание',
                hintText: 'Опишите тематику и цели вашего сообщества...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true,
                filled: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите описание';
                }
                if (value.length < 10) {
                  return 'Описание должно быть не менее 10 символов';
                }
                if (value.length > 500) {
                  return 'Описание должно быть не более 500 символов';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Теги
            TextFormField(
              controller: _tagsController,
              decoration: InputDecoration(
                labelText: 'Теги (через запятую)',
                hintText: 'технологии, программирование, IT, разработка',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.tag_rounded),
                filled: true,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Теги помогут пользователям найти ваше сообщество',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Настройки сообщества',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Настройте приватность и правила',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),

          // Приватность
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lock_rounded, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 12),
                      Text(
                        'Приватность',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Switch(
                        value: _isPrivate,
                        onChanged: (value) {
                          setState(() {
                            _isPrivate = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isPrivate
                        ? 'Сообщество будет видно только участникам по приглашению'
                        : 'Сообщество будет публичным и видно всем пользователям',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Настройки комнат
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.chat_rounded, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 12),
                      Text(
                        'Создание комнат',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Switch(
                        value: _allowUserRooms,
                        onChanged: (value) {
                          setState(() {
                            _allowUserRooms = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _allowUserRooms
                        ? 'Участники могут создавать свои комнаты'
                        : 'Только модераторы могут создавать комнаты',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Одобрение участников
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_user_rounded, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 12),
                      Text(
                        'Одобрение участников',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Switch(
                        value: _requireApproval,
                        onChanged: (value) {
                          setState(() {
                            _requireApproval = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _requireApproval
                        ? 'Новые участники требуют одобрения модераторов'
                        : 'Пользователи могут присоединяться свободно',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Приветственное сообщение
          TextFormField(
            controller: _welcomeMessageController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Приветственное сообщение',
              hintText: 'Напишите приветствие для новых участников...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
            ),
          ),
          const SizedBox(height: 16),

          // Правила
          TextFormField(
            controller: _rulesController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Правила сообщества (опционально)',
              hintText: 'Опишите основные правила поведения...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Внешний вид',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Настройте внешний вид сообщества',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),

          // Цвет сообщества
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Цвет сообщества',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // Здесь можно добавить выбор цвета
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _getCategoryColor().withOpacity(0.8),
                          _getCategoryColor().withOpacity(0.4),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        _getCategoryIcon(),
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Предпросмотр
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Предпросмотр',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildCommunityPreview(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewStep() {
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Предпросмотр сообщества',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Проверьте информацию перед созданием',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),

          // Карточка предпросмотра
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Аватар и название
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getCategoryColor().withOpacity(0.8),
                              _getCategoryColor().withOpacity(0.4),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getCategoryIcon(),
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nameController.text.isEmpty ? 'Название сообщества' : _nameController.text,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedCategory,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Описание
                  if (_descriptionController.text.isNotEmpty) ...[
                    Text(
                      _descriptionController.text,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Теги
                  if (tags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      children: tags.take(3).map((tag) => Chip(
                        label: Text('#$tag'),
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Настройки
                  Row(
                    children: [
                      _buildPreviewBadge(
                        _isPrivate ? 'Приватное' : 'Публичное',
                        _isPrivate ? Icons.lock_rounded : Icons.public_rounded,
                      ),
                      const SizedBox(width: 8),
                      _buildPreviewBadge(
                        _allowUserRooms ? 'Открытые комнаты' : 'Закрытые комнаты',
                        Icons.chat_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Информация о создании
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_rounded, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'После создания вы станете владельцем сообщества и сможете приглашать участников, создавать комнаты и настраивать дополнительные параметры.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getCategoryColor().withOpacity(0.8),
                  _getCategoryColor().withOpacity(0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameController.text.isEmpty ? 'Название сообщества' : _nameController.text,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _selectedCategory,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewBadge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Theme.of(context).primaryColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: _goToPreviousStep,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Назад'),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _goToNextStep,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              _currentStep == 3 ? 'Создать сообщество' : 'Продолжить',
            ),
          ),
        ),
      ],
    );
  }

  void _goToNextStep() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _currentStep++;
        });
      }
    } else if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    } else {
      _createCommunity();
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _createCommunity() {
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final newCommunity = Community(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      description: _descriptionController.text,
      imageUrl: '',
      category: _selectedCategory,
      memberCount: 1,
      onlineCount: 1,
      tags: tags,
      isUserMember: true,
      isPrivate: _isPrivate,
      creatorId: 'current_user_id',
      creatorName: 'Текущий пользователь',
      createdAt: DateTime.now(),
      rooms: [],
      rules: _rulesController.text.isNotEmpty ? _rulesController.text : null,
      welcomeMessage: _welcomeMessageController.text.isNotEmpty ? _welcomeMessageController.text : null,
      stats: const CommunityStats(),
      settings: CommunitySettings(
        allowUserRooms: _allowUserRooms,
        requireApproval: _requireApproval,
      ),
    );

    widget.onCommunityCreated(newCommunity);
    Navigator.pop(context);
  }

  Color _getCategoryColor() {
    switch (_selectedCategory.toLowerCase()) {
      case 'технологии':
        return Colors.blue;
      case 'игры':
        return Colors.purple;
      case 'социальное':
        return Colors.green;
      case 'путешествия':
        return Colors.orange;
      case 'образование':
        return Colors.teal;
      case 'бизнес':
        return Colors.indigo;
      case 'искусство':
        return Colors.pink;
      case 'музыка':
        return Colors.deepPurple;
      case 'наука':
        return Colors.blueGrey;
      case 'спорт':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon() {
    switch (_selectedCategory.toLowerCase()) {
      case 'технологии':
        return Icons.smartphone_rounded;
      case 'игры':
        return Icons.sports_esports_rounded;
      case 'социальное':
        return Icons.people_alt_rounded;
      case 'путешествия':
        return Icons.travel_explore_rounded;
      case 'образование':
        return Icons.school_rounded;
      case 'бизнес':
        return Icons.business_center_rounded;
      case 'искусство':
        return Icons.palette_rounded;
      case 'музыка':
        return Icons.music_note_rounded;
      case 'наука':
        return Icons.science_rounded;
      case 'спорт':
        return Icons.sports_soccer_rounded;
      default:
        return Icons.room_rounded;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _welcomeMessageController.dispose();
    _rulesController.dispose();
    super.dispose();
  }
}