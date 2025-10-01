import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../chat/chat_page.dart';
import 'models/room.dart';
import '../../providers/room_provider.dart';
import '../../providers/user_provider.dart';


class CreateRoomBottomSheet extends StatefulWidget {
  final Function(Room)? onRoomCreated;

  const CreateRoomBottomSheet({super.key, this.onRoomCreated});

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

  RoomCategory _selectedCategory = RoomCategory.technology;
  RoomAccessLevel _accessLevel = RoomAccessLevel.public;
  bool _isLoading = false;
  int _maxParticipants = 100;
  List<String> _tags = [];

  // Новые настройки
  bool _hasMedia = false;
  bool _enableVoiceChat = false;
  bool _enableVideoChat = false;
  Duration? _duration;

  // Для запланированных комнат
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;

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
        bottom: MediaQuery
            .of(context)
            .viewInsets
            .bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme
              .of(context)
              .colorScheme
              .surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery
              .of(context)
              .size
              .height * 0.9,
        ),
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
                      const SizedBox(height: 16),
                      _buildMediaSettingsSection(),
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
        Icon(Icons.add_circle_rounded, color: Theme
            .of(context)
            .primaryColor, size: 28),
        const SizedBox(width: 12),
        Text(
          'Создать новое обсуждение',
          style: Theme
              .of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme
                .of(context)
                .colorScheme
                .onSurface,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Закрыть',
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Основная информация',
              style: Theme
                  .of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Название комнаты *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Введите краткое название',
                prefixIcon: const Icon(Icons.title_rounded),
                filled: true,
                fillColor: Theme
                    .of(context)
                    .colorScheme
                    .surfaceVariant
                    .withOpacity(0.3),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите название обсуждения';
                }
                if (value.length < 3) {
                  return 'Название должно быть не менее 3 символов';
                }
                if (value.length > 100) {
                  return 'Название должно быть не более 100 символов';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Описание *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'О чем будет это обсуждение?',
                prefixIcon: const Icon(Icons.description_rounded),
                filled: true,
                fillColor: Theme
                    .of(context)
                    .colorScheme
                    .surfaceVariant
                    .withOpacity(0.3),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите описание обсуждения';
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
            const SizedBox(height: 12),
            DropdownButtonFormField<RoomCategory>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Категория *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.category_rounded),
                filled: true,
                fillColor: Theme
                    .of(context)
                    .colorScheme
                    .surfaceVariant
                    .withOpacity(0.3),
              ),
              items: RoomCategory.values
                  .where((c) => c != RoomCategory.all)
                  .map((category) {
                return DropdownMenuItem<RoomCategory>(
                  value: category,
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: category.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                            category.icon, color: category.color, size: 18),
                      ),
                      const SizedBox(width: 12),
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
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Настройки доступа',
              style: Theme
                  .of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Уровень доступа
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Уровень доступа *',
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
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
                      avatar: Icon(level.icon, size: 16, color: level.color),
                      backgroundColor: Theme
                          .of(context)
                          .colorScheme
                          .surfaceVariant,
                      selectedColor: level.color.withOpacity(0.2),
                      checkmarkColor: level.color,
                      tooltip: level.description,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme
                        .of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme
                          .of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _accessLevel.icon,
                        color: _accessLevel.color,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _accessLevel.description,
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                            color: Theme
                                .of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Пароль для защищенных комнат
            if (_accessLevel == RoomAccessLevel.protected)
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Пароль для входа *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'Введите пароль (мин. 4 символа)',
                  prefixIcon: const Icon(Icons.lock_rounded),
                  filled: true,
                  fillColor: Theme
                      .of(context)
                      .colorScheme
                      .surfaceVariant
                      .withOpacity(0.3),
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

            if (_accessLevel == RoomAccessLevel.protected) const SizedBox(
                height: 16),

            // Максимум участников
            TextFormField(
              controller: _maxParticipantsController,
              decoration: InputDecoration(
                labelText: 'Максимум участников *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'От 2 до 1000',
                prefixIcon: const Icon(Icons.people_rounded),
                filled: true,
                fillColor: Theme
                    .of(context)
                    .colorScheme
                    .surfaceVariant
                    .withOpacity(0.3),
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
                if (participants == null ||
                    participants < 2 ||
                    participants > 1000) {
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
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Дополнительные настройки',
              style: Theme
                  .of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Правила комнаты
            TextFormField(
              controller: _rulesController,
              decoration: InputDecoration(
                labelText: 'Правила комнаты (необязательно)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Опишите правила поведения в комнате',
                prefixIcon: const Icon(Icons.rule_rounded),
                filled: true,
                fillColor: Theme
                    .of(context)
                    .colorScheme
                    .surfaceVariant
                    .withOpacity(0.3),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 16),

            // Теги
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _tagsController,
                  decoration: InputDecoration(
                    labelText: 'Теги',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: 'Введите теги через запятую',
                    prefixIcon: const Icon(Icons.tag_rounded),
                    filled: true,
                    fillColor: Theme
                        .of(context)
                        .colorScheme
                        .surfaceVariant
                        .withOpacity(0.3),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add_rounded),
                      onPressed: _addTag,
                      tooltip: 'Добавить тег',
                    ),
                  ),
                  onFieldSubmitted: (_) => _addTag(),
                ),
                if (_tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _tags.map((tag) {
                      return Chip(
                        label: Text(tag),
                        onDeleted: () => _removeTag(tag),
                        deleteIcon: const Icon(Icons.close_rounded, size: 16),
                        backgroundColor: Theme
                            .of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // Запланированная комната
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .outline
                      .withOpacity(0.2),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Запланировать комнату',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: _scheduledDate != null
                        ? Text(
                      'На ${_formatDateTime()}',
                      style: TextStyle(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .primary,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                        : const Text('Назначьте дату и время начала'),
                    value: _scheduledDate != null,
                    onChanged: (value) {
                      if (value) {
                        _selectDateTime();
                      } else {
                        setState(() {
                          _scheduledDate = null;
                          _scheduledTime = null;
                          _duration = null;
                        });
                      }
                    },
                    secondary: Icon(
                      Icons.schedule_rounded,
                      color: Theme
                          .of(context)
                          .colorScheme
                          .primary,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_scheduledDate != null) ...[
                    const Divider(),
                    ListTile(
                      leading: Icon(
                        Icons.timer_rounded,
                        color: Theme
                            .of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                        size: 20,
                      ),
                      title: const Text('Продолжительность'),
                      subtitle: _duration != null
                          ? Text(
                        '${_duration!.inHours} ч ${_duration!.inMinutes
                            .remainder(60)} мин',
                      )
                          : const Text('Не установлена'),
                      trailing: FilledButton.tonal(
                        onPressed: _selectDuration,
                        child: const Text('Выбрать'),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaSettingsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Медиа и дополнительные опции',
              style: Theme
                  .of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Медиафайлы
            SwitchListTile(
              title: const Text('Разрешить медиафайлы'),
              subtitle: const Text(
                  'Участники смогут делиться изображениями и видео'),
              value: _hasMedia,
              onChanged: (value) => setState(() => _hasMedia = value),
              secondary: const Icon(Icons.photo_library_rounded),
            ),

            // Голосовой чат
            SwitchListTile(
              title: const Text('Голосовой чат'),
              subtitle: const Text('Включить возможность голосового общения'),
              value: _enableVoiceChat,
              onChanged: (value) => setState(() => _enableVoiceChat = value),
              secondary: const Icon(Icons.mic_rounded),
            ),

            // Видеочат
            SwitchListTile(
              title: const Text('Видеочат'),
              subtitle: const Text('Включить возможность видеообщения'),
              value: _enableVideoChat,
              onChanged: (value) => setState(() => _enableVideoChat = value),
              secondary: const Icon(Icons.videocam_rounded),
            ),

            // Предварительный просмотр
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme
                    .of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_rounded,
                    color: Theme
                        .of(context)
                        .primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'После создания комната будет доступна для участия. Вы сможете изменить настройки позже.',
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme
                .of(context)
                .dividerColor
                .withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.cancel_rounded),
              onPressed: () => Navigator.pop(context),
              label: const Text('Отмена'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              icon: _isLoading
                  ? SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme
                      .of(context)
                      .colorScheme
                      .onPrimary,
                ),
              )
                  : const Icon(Icons.add_rounded),
              onPressed: _isLoading ? null : _createRoom,
              label: _isLoading
                  ? const Text('Создание...')
                  : const Text('Создать комнату'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addTag() {
    final tag = _tagsController.text.trim().toLowerCase();
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme
                  .of(context)
                  .primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Theme
                    .of(context)
                    .primaryColor,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _scheduledDate = date;
          _scheduledTime = time;
        });
        // Автоматически предлагаем выбрать продолжительность
        if (_duration == null) {
          _selectDuration();
        }
      }
    }
  }

  Future<void> _selectDuration() async {
    final selectedHours = await showModalBottomSheet<int>(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Продолжительность комнаты',
                style: Theme
                    .of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Выберите продолжительность в часах:'),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: _duration?.inHours ?? 1,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
                items: List.generate(24, (index) => index + 1)
                    .map(
                      (hours) =>
                      DropdownMenuItem<int>(
                        value: hours,
                        child: Text('$hours ${_getHoursText(hours)}'),
                      ),
                )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    Navigator.pop(context, value);
                  }
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () =>
                          Navigator.pop(context, _duration?.inHours ?? 1),
                      child: const Text('Сохранить'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (selectedHours != null) {
      setState(() {
        _duration = Duration(hours: selectedHours);
      });
    }
  }

  String _getHoursText(int hours) {
    if (hours % 10 == 1 && hours % 100 != 11) return 'час';
    if (hours % 10 >= 2 &&
        hours % 10 <= 4 &&
        (hours % 100 < 10 || hours % 100 >= 20)) {
      return 'часа';
    }
    return 'часов';
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

    return DateFormat('dd.MM.yyyy в HH:mm').format(scheduledDateTime);
  }

  Future<void> _createRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final roomProvider = context.read<RoomProvider>();
      final userProvider = context.read<UserProvider>();

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

      // УБИРАЕМ локальное создание комнаты - создаем только через provider
      // final newRoom = Room(...); // УДАЛИТЬ ЭТОТ БЛОК

      // Создаем комнату ТОЛЬКО через provider
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
        hasMedia: _hasMedia,
        enableVoiceChat: _enableVoiceChat,
        enableVideoChat: _enableVideoChat,
      );

      if (mounted) {
        Navigator.pop(context);

        // Получаем последнюю созданную комнату для показа уведомления
        final createdRoom = roomProvider.rooms.firstWhere(
              (room) => room.title == _titleController.text,
          orElse: () => Room(
            id: '',
            title: '',
            description: '',
            imageUrl: '',
            currentParticipants: 0,
            messageCount: 0,
            isJoined: false,
            createdAt: DateTime.now(),
            lastActivity: DateTime.now(),
            category: RoomCategory.all,
            creatorId: '',
            creatorName: '',
          ),// Запасной вариант
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Комната "${_titleController.text}" успешно создана! 🎉',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 4),
            action: createdRoom.id.isNotEmpty ? SnackBarAction(
              label: 'Открыть',
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        ChatPage(
                          room: createdRoom,
                          userName: userProvider.userName,
                        ),
                    transitionsBuilder: (context, animation, secondaryAnimation,
                        child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOutQuart;
                      var tween = Tween(begin: begin, end: end).chain(
                          CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);
                      return SlideTransition(
                          position: offsetAnimation, child: child);
                    },
                  ),
                );
              },
            ) : null,
          ),
        );

        // Вызываем колбэк если он передан
        if (widget.onRoomCreated != null && createdRoom.id.isNotEmpty) {
          widget.onRoomCreated!(createdRoom);
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ошибка при создании комнаты: ${error.toString()}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
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