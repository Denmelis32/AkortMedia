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
            // Содержимое шагов
            Expanded(
              child: Stepper(
                currentStep: _currentStep,
                onStepContinue: _nextStep,
                onStepCancel: _previousStep,
                onStepTapped: (step) => setState(() => _currentStep = step),
                controlsBuilder: (context, details) {
                  return const SizedBox.shrink(); // Скрываем стандартные кнопки
                },
                steps: [
                  Step(
                    title: const Text('Основная информация'),
                    content: _buildBasicInfoStep(),
                    isActive: _currentStep >= 0,
                    state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                  ),
                  Step(
                    title: const Text('Настройки'),
                    content: _buildSettingsStep(),
                    isActive: _currentStep >= 1,
                    state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                  ),
                  Step(
                    title: const Text('Дополнительно'),
                    content: _buildAdvancedStep(),
                    isActive: _currentStep >= 2,
                    state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                  ),
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            Text(
              'Создать сообщество',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.help_outline_rounded),
              onPressed: _showHelpDialog,
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (_currentStep + 1) / 3,
          backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
        ),
      ],
    );
  }

  Widget _buildBasicInfoStep() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Название сообщества',
              hintText: 'Введите название...',
              prefixIcon: Icon(Icons.people_rounded),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введите название сообщества';
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
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Описание',
              hintText: 'Опишите ваше сообщество...',
              prefixIcon: Icon(Icons.description_rounded),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введите описание сообщества';
              }
              if (value.length < 10) {
                return 'Описание должно быть не менее 10 символов';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Категория',
              prefixIcon: Icon(Icons.category_rounded),
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
            controller: _tagsController,
            decoration: const InputDecoration(
              labelText: 'Теги (через запятую)',
              hintText: 'программирование, flutter, dart...',
              prefixIcon: Icon(Icons.tag_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsStep() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Приватное сообщество'),
          subtitle: const Text('Новые участники требуют одобрения'),
          value: _isPrivate,
          onChanged: (value) => setState(() => _isPrivate = value),
        ),
        SwitchListTile(
          title: const Text('Разрешить создание комнат пользователями'),
          subtitle: const Text('Участники могут создавать свои комнаты'),
          value: _allowUserRooms,
          onChanged: (value) => setState(() => _allowUserRooms = value),
        ),
        SwitchListTile(
          title: const Text('Модерация контента'),
          subtitle: const Text('Все сообщения проверяются модераторами'),
          value: _requireApproval,
          onChanged: (value) => setState(() => _requireApproval = value),
        ),
        const SizedBox(height: 16),
        const Text(
          'Настройки можно изменить позже в разделе управления сообществом',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAdvancedStep() {
    return Column(
      children: [
        TextFormField(
          controller: _welcomeMessageController,
          decoration: const InputDecoration(
            labelText: 'Приветственное сообщение',
            hintText: 'Напишите приветствие для новых участников...',
            prefixIcon: Icon(Icons.waving_hand_rounded),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _rulesController,
          decoration: const InputDecoration(
            labelText: 'Правила сообщества',
            hintText: 'Опишите основные правила...',
            prefixIcon: Icon(Icons.rule_rounded),
          ),
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.blue.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.info_rounded, color: Colors.blue.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Эти настройки помогут новым участникам быстрее освоиться в вашем сообществе',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Назад'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentStep == 2 ? _createCommunity : _nextStep,
              child: Text(_currentStep == 2 ? 'Создать' : 'Далее'),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_formKey.currentState!.validate()) {
        return;
      }
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _createCommunity() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newCommunity = Community(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      description: _descriptionController.text,
      imageUrl: '', // TODO: Добавить загрузку изображения
      category: _selectedCategory,
      memberCount: 1,
      onlineCount: 1,
      tags: _tagsController.text.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList(),
      isUserMember: true,
      isPrivate: _isPrivate,
      creatorId: 'current_user_id', // TODO: Заменить на реальный ID пользователя
      creatorName: 'Текущий пользователь', // TODO: Заменить на реальное имя
      createdAt: DateTime.now(),
      rooms: [],
      rules: _rulesController.text.isNotEmpty ? _rulesController.text : null,
      welcomeMessage: _welcomeMessageController.text.isNotEmpty ? _welcomeMessageController.text : null,
      moderators: ['current_user_id'],
      roomCount: 0,
      stats: const CommunityStats(),
      settings: CommunitySettings(
        allowUserRooms: _allowUserRooms,
        requireApproval: _requireApproval,
        enableModeration: _requireApproval,
      ),
      events: [],
      level: CommunityLevel.beginner,
      isVerified: false,
      featuredTags: [],
    );

    widget.onCommunityCreated(newCommunity);
    Navigator.pop(context);
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Создание сообщества'),
        content: const Text(
          'Создайте уникальное сообщество по вашим интересам! '
              'Заполните основную информацию, настройте параметры и добавьте дополнительные детали для привлечения участников.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
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