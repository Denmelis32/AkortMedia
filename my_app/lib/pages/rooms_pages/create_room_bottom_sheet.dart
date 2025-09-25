import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final _rulesController = TextEditingController();
  final _passwordController = TextEditingController();
  final _maxParticipantsController = TextEditingController(text: '100');
  final _tagsController = TextEditingController();

  RoomCategory _selectedCategory = RoomCategory.tech;
  RoomAccessLevel _accessLevel = RoomAccessLevel.public;
  bool _isLoading = false;
  int _maxParticipants = 100;
  List<String> _tags = [];

  // Для запланированных комнат
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  Duration? _duration;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rulesController.dispose();
    _passwordController.dispose();
    _maxParticipantsController.dispose();
    _tagsController.dispose();
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
              _buildHeader(),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildBasicInfoSection(),
                      const SizedBox(height: 16),
                      _buildAccessSettingsSection(),
                      const SizedBox(height: 16),
                      _buildAdvancedSettingsSection(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.add_circle, color: Theme.of(context).primaryColor, size: 28),
        const SizedBox(width: 12),
        Text(
          'Создать новое обсуждение',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Основная информация',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Название комнаты *',
                border: OutlineInputBorder(),
                hintText: 'Введите краткое название',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите название обсуждения';
                }
                if (value.length < 3) {
                  return 'Название должно быть не менее 3 символов';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание *',
                border: OutlineInputBorder(),
                hintText: 'О чем будет это обсуждение?',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите описание обсуждения';
                }
                if (value.length < 10) {
                  return 'Описание должно быть не менее 10 символов';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<RoomCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Категория *',
                border: OutlineInputBorder(),
              ),
              items: RoomCategory.values.where((c) => c != RoomCategory.all).map((category) {
                return DropdownMenuItem<RoomCategory>(
                  value: category,
                  child: Row(
                    children: [
                      Icon(category.icon, color: category.color, size: 20),
                      const SizedBox(width: 8),
                      Text(category.title),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (category) {
                if (category != null) {
                  setState(() {
                    _selectedCategory = category;
                  });
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Выберите категорию';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Настройки доступа',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Уровень доступа', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: RoomAccessLevel.values.map((level) {
                    return FilterChip(
                      label: Text(level.title),
                      selected: _accessLevel == level,
                      onSelected: (selected) {
                        setState(() {
                          _accessLevel = level;
                          if (level != RoomAccessLevel.protected) {
                            _passwordController.clear();
                          }
                        });
                      },
                      avatar: Icon(level.icon, size: 16),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_accessLevel == RoomAccessLevel.protected)
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Пароль для входа *',
                  border: OutlineInputBorder(),
                  hintText: 'Введите пароль',
                ),
                validator: (value) {
                  if (_accessLevel == RoomAccessLevel.protected &&
                      (value == null || value.isEmpty)) {
                    return 'Введите пароль для защищенной комнаты';
                  }
                  if (value != null && value.length < 4) {
                    return 'Пароль должен быть не менее 4 символов';
                  }
                  return null;
                },
              ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _maxParticipantsController,
              decoration: const InputDecoration(
                labelText: 'Максимум участников',
                border: OutlineInputBorder(),
                hintText: 'От 2 до 1000',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final participants = int.tryParse(value) ?? 100;
                setState(() {
                  _maxParticipants = participants.clamp(2, 1000);
                });
              },
              validator: (value) {
                final participants = int.tryParse(value ?? '');
                if (participants == null || participants < 2 || participants > 1000) {
                  return 'Введите число от 2 до 1000';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Дополнительные настройки',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _rulesController,
              decoration: const InputDecoration(
                labelText: 'Правила комнаты (необязательно)',
                border: OutlineInputBorder(),
                hintText: 'Опишите правила поведения в комнате',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tagsController,
              decoration: InputDecoration(
                labelText: 'Теги',
                border: const OutlineInputBorder(),
                hintText: 'Введите теги через запятую',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTag,
                ),
              ),
              onFieldSubmitted: (_) => _addTag(),
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    onDeleted: () => _removeTag(tag),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Запланировать комнату'),
              subtitle: _scheduledDate != null
                  ? Text('На ${_formatDateTime()}')
                  : null,
              value: _scheduledDate != null,
              onChanged: (value) {
                if (value) {
                  _selectDateTime();
                } else {
                  setState(() {
                    _scheduledDate = null;
                    _scheduledTime = null;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _createRoom,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('Создать комнату'),
          ),
        ),
      ],
    );
  }

  void _addTag() {
    final tag = _tagsController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagsController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _scheduledDate = date;
          _scheduledTime = time;
        });
      }
    }
  }

  String _formatDateTime() {
    if (_scheduledDate == null || _scheduledTime == null) return '';

    final scheduledDateTime = DateTime(
      _scheduledDate!.year,
      _scheduledDate!.month,
      _scheduledDate!.day,
      _scheduledTime!.hour,
      _scheduledTime!.minute,
    );

    return DateFormat('dd.MM.yyyy HH:mm').format(scheduledDateTime);
  }

  Future<void> _createRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final roomProvider = context.read<RoomProvider>();

      DateTime? scheduledStart;
      if (_scheduledDate != null && _scheduledTime != null) {
        scheduledStart = DateTime(
          _scheduledDate!.year,
          _scheduledDate!.month,
          _scheduledDate!.day,
          _scheduledTime!.hour,
          _scheduledTime!.minute,
        );
      }

      await roomProvider.createRoom(
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        isPrivate: _accessLevel == RoomAccessLevel.private,
        tags: _tags,
        maxParticipants: _maxParticipants,
        rules: _rulesController.text,
        accessLevel: _accessLevel,
        password: _passwordController.text,
        scheduledStart: scheduledStart,
        duration: _duration,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Комната "${_titleController.text}" создана!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при создании комнаты: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

