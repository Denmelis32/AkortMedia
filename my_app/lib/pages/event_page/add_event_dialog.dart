import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'event_model.dart';

class AddEventDialog extends StatefulWidget {
  final Function(Event) onAdd;
  final String? initialCategory;
  final Event? initialEvent;
  final bool isEditing;

  const AddEventDialog({
    Key? key,
    required this.onAdd,
    this.initialCategory,
    this.initialEvent,
    this.isEditing = false,
  }) : super(key: key);

  @override
  _AddEventDialogState createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _organizerController = TextEditingController();
  final _priceController = TextEditingController();
  final _websiteController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _onlineLinkController = TextEditingController();

  late DateTime _selectedDate;
  late DateTime _selectedEndDate;
  late TimeOfDay _selectedStartTime;
  late TimeOfDay _selectedEndTime;
  late String _selectedCategory;
  late Color _selectedColor;
  late bool _isOnline;
  late bool _isFree;
  late int _maxAttendees;
  late List<String> _selectedTags;

  // Анимации
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Текущий шаг формы
  int _currentStep = 0;

  final List<EventCategory> _categories = [
    EventCategory(
      id: 'meeting',
      title: 'Встречи',
      icon: Icons.people_alt_rounded,
      color: Colors.blue,
      description: 'Деловые и личные встречи',
    ),
    EventCategory(
      id: 'birthday',
      title: 'Дни рождения',
      icon: Icons.cake_rounded,
      color: Colors.pink,
      description: 'Праздники и поздравления',
    ),
    EventCategory(
      id: 'business',
      title: 'Бизнес',
      icon: Icons.business_center_rounded,
      color: Colors.orange,
      description: 'Совещания и переговоры',
    ),
    EventCategory(
      id: 'travel',
      title: 'Путешествия',
      icon: Icons.travel_explore_rounded,
      color: Colors.green,
      description: 'Поездки и командировки',
    ),
    EventCategory(
      id: 'education',
      title: 'Обучение',
      icon: Icons.school_rounded,
      color: Colors.purple,
      description: 'Лекции и мастер-классы',
    ),
    EventCategory(
      id: 'health',
      title: 'Здоровье',
      icon: Icons.favorite_rounded,
      color: Colors.red,
      description: 'Спорт и wellness',
    ),
    EventCategory(
      id: 'entertainment',
      title: 'Развлечения',
      icon: Icons.music_note_rounded,
      color: Colors.amber,
      description: 'Концерты и мероприятия',
    ),
    EventCategory(
      id: 'conference',
      title: 'Конференции',
      icon: Icons.record_voice_over_rounded,
      color: Colors.indigo,
      description: 'Профессиональные мероприятия',
    ),
    EventCategory(
      id: 'workshop',
      title: 'Воркшопы',
      icon: Icons.work_rounded,
      color: Colors.teal,
      description: 'Практические занятия',
    ),
    EventCategory(
      id: 'networking',
      title: 'Нетворкинг',
      icon: Icons.handshake_rounded,
      color: Colors.cyan,
      description: 'Деловые знакомства',
    ),
  ];

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.deepOrange,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.deepPurple,
  ];

  final List<String> _availableTags = [
    'бесплатно',
    'премиум',
    'онлайн',
    'офлайн',
    'для детей',
    '18+',
    'бизнес',
    'образование',
    'развлечения',
    'спорт',
    'искусство',
    'музыка',
    'еда',
    'технологии',
    'стартапы',
    'благотворительность',
    'мастер-класс',
    'лекция',
    'концерт',
    'выставка',
  ];

  // Доступность
  bool _isWheelchairAccessible = false;
  bool _isChildFriendly = false;
  bool _isPetFriendly = false;

  @override
  void initState() {
    super.initState();

    // Инициализация анимаций
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    // Инициализация данных
    if (widget.isEditing && widget.initialEvent != null) {
      _initializeFromEvent(widget.initialEvent!);
    } else {
      _initializeDefaults();
    }
  }

  void _initializeFromEvent(Event event) {
    _titleController.text = event.title;
    _descriptionController.text = event.description;
    _locationController.text = event.location ?? '';
    _organizerController.text = event.organizer;
    _priceController.text = event.price?.toString() ?? '';
    _websiteController.text = event.website ?? '';
    _phoneController.text = event.phone ?? '';
    _emailController.text = event.email ?? '';
    _onlineLinkController.text = event.onlineLink ?? '';

    _selectedDate = event.date;
    _selectedEndDate = event.endDate;
    _selectedStartTime = TimeOfDay.fromDateTime(event.date);
    _selectedEndTime = TimeOfDay.fromDateTime(event.endDate);
    _selectedCategory = event.category;
    _selectedColor = event.color;
    _isOnline = event.isOnline;
    _isFree = event.isFree;
    _maxAttendees = event.maxAttendees;
    _selectedTags = List.from(event.tags);

    // Доступность
    if (event.accessibility != null) {
      _isWheelchairAccessible = event.accessibility!.isWheelchairAccessible;
      _isChildFriendly = event.accessibility!.isChildFriendly;
      _isPetFriendly = event.accessibility!.isPetFriendly;
    }
  }

  void _initializeDefaults() {
    final now = DateTime.now();
    _selectedDate = now;
    _selectedEndDate = now.add(const Duration(hours: 2));
    _selectedStartTime = TimeOfDay.now();
    _selectedEndTime = TimeOfDay.fromDateTime(now.add(const Duration(hours: 2)));
    _selectedCategory = widget.initialCategory ?? _categories.first.title;
    _selectedColor = _getColorFromCategory(_selectedCategory);
    _isOnline = false;
    _isFree = true;
    _maxAttendees = 50;
    _selectedTags = [];
    _organizerController.text = 'Я';
  }

  Color _getColorFromCategory(String category) {
    final categoryObj = _categories.firstWhere(
          (cat) => cat.title == category,
      orElse: () => _categories.first,
    );
    return categoryObj.color;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: _selectedColor),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedEndDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedEndTime.hour,
          _selectedEndTime.minute,
        );
      });
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: _selectedColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedStartTime = picked;
        _updateEventDateTime();
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: _selectedColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedEndTime = picked;
        _updateEventDateTime();
      });
    }
  }

  void _updateEventDateTime() {
    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedStartTime.hour,
      _selectedStartTime.minute,
    );

    final endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedEndTime.hour,
      _selectedEndTime.minute,
    );

    // Если конечное время раньше начального, добавляем день
    if (endDateTime.isBefore(startDateTime)) {
      _selectedEndDate = endDateTime.add(const Duration(days: 1));
    } else {
      _selectedEndDate = endDateTime;
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _selectedColor = _getColorFromCategory(category);
    });
  }

  void _onColorSelected(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  void _onTagSelected(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      final startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedStartTime.hour,
        _selectedStartTime.minute,
      );

      final event = Event(
        id: widget.isEditing && widget.initialEvent != null
            ? widget.initialEvent!.id
            : 'event-${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text,
        description: _descriptionController.text,
        date: startDateTime,
        endDate: _selectedEndDate,
        color: _selectedColor,
        category: _selectedCategory,
        location: _locationController.text.isNotEmpty ? _locationController.text : null,
        address: _locationController.text,
        price: _isFree ? 0 : double.tryParse(_priceController.text),
        organizer: _organizerController.text,
        tags: _selectedTags,
        maxAttendees: _maxAttendees,
        currentAttendees: widget.isEditing && widget.initialEvent != null
            ? widget.initialEvent!.currentAttendees
            : 0,
        rating: widget.isEditing && widget.initialEvent != null
            ? widget.initialEvent!.rating
            : 0.0,
        reviewCount: widget.isEditing && widget.initialEvent != null
            ? widget.initialEvent!.reviewCount
            : 0,
        isOnline: _isOnline,
        onlineLink: _isOnline && _onlineLinkController.text.isNotEmpty
            ? _onlineLinkController.text
            : null,
        isFeatured: widget.isEditing && widget.initialEvent != null
            ? widget.initialEvent!.isFeatured
            : false,
        createdAt: widget.isEditing && widget.initialEvent != null
            ? widget.initialEvent!.createdAt
            : DateTime.now(),
        updatedAt: DateTime.now(),
        website: _websiteController.text.isNotEmpty ? _websiteController.text : null,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        accessibility: EventAccessibility(
          isWheelchairAccessible: _isWheelchairAccessible,
          isChildFriendly: _isChildFriendly,
          isPetFriendly: _isPetFriendly,
        ),
        social: EventSocial(),
        statistics: widget.isEditing && widget.initialEvent != null
            ? widget.initialEvent!.statistics
            : const EventStatistics(),
      );

      widget.onAdd(event);
      Navigator.of(context).pop();

      _showSuccessSnackbar();
    }
  }

  void _showSuccessSnackbar() {
    final message = widget.isEditing ? 'Событие успешно обновлено!' : 'Событие успешно создано!';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepCircle(0, 'Основное'),
          _buildStepConnector(),
          _buildStepCircle(1, 'Детали'),
          _buildStepConnector(),
          _buildStepCircle(2, 'Дополнительно'),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;

    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive || isCompleted ? _selectedColor : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: isCompleted
              ? Icon(Icons.check, size: 16, color: Colors.white)
              : isActive
              ? Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          )
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? _selectedColor : Colors.grey[500],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector() {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: Colors.grey[300],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((category) {
        final isSelected = _selectedCategory == category.title;
        return _buildCategoryCard(category, isSelected);
      }).toList(),
    );
  }

  Widget _buildCategoryCard(EventCategory category, bool isSelected) {
    return GestureDetector(
      onTap: () => _onCategorySelected(category.title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? category.color.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? category.color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(category.icon, size: 24, color: isSelected ? category.color : Colors.grey[600]),
            const SizedBox(height: 8),
            Text(
              category.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? category.color : Colors.grey[700],
              ),
            ),
            if (category.description != null) ...[
              const SizedBox(height: 4),
              Text(
                category.description!,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? category.color.withOpacity(0.8) : Colors.grey[500],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableColors.map((color) {
        final isSelected = _selectedColor == color;
        return GestureDetector(
          onTap: () => _onColorSelected(color),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : Border.all(color: Colors.grey[300]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isSelected ? 0.3 : 0.1),
                  blurRadius: isSelected ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: isSelected
                ? Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTagChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableTags.map((tag) {
        final isSelected = _selectedTags.contains(tag);
        return FilterChip(
          label: Text(tag),
          selected: isSelected,
          onSelected: (selected) => _onTagSelected(tag),
          backgroundColor: Colors.grey[100],
          selectedColor: _selectedColor.withOpacity(0.2),
          checkmarkColor: _selectedColor,
          labelStyle: TextStyle(
            color: isSelected ? _selectedColor : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAccessibilityOptions() {
    return Column(
      children: [
        _buildAccessibilitySwitch(
          'Доступно для инвалидных колясок',
          _isWheelchairAccessible,
              (value) => setState(() => _isWheelchairAccessible = value),
          Icons.accessible_rounded,
        ),
        _buildAccessibilitySwitch(
          'Дружелюбно к детям',
          _isChildFriendly,
              (value) => setState(() => _isChildFriendly = value),
          Icons.child_care_rounded,
        ),
        _buildAccessibilitySwitch(
          'Разрешены животные',
          _isPetFriendly,
              (value) => setState(() => _isPetFriendly = value),
          Icons.pets_rounded,
        ),
      ],
    );
  }

  Widget _buildAccessibilitySwitch(String title, bool value, ValueChanged<bool> onChanged, IconData icon) {
    return SwitchListTile(
      title: Row(
        children: [
          Icon(icon, color: _selectedColor),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 14)),
        ],
      ),
      value: value,
      onChanged: onChanged,
      activeColor: _selectedColor,
    );
  }

  // АДАПТИВНЫЕ МЕТОДЫ
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 200;
    if (width > 800) return 100;
    if (width > 600) return 60;
    return 16;
  }

  double _getDialogWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 800) return 700;
    if (width > 600) return 600;
    return width - 32;
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = _getHorizontalPadding(context);
    final dialogWidth = _getDialogWidth(context);

    return Dialog(
      insetPadding: EdgeInsets.all(horizontalPadding),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: dialogWidth,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _selectedColor.withOpacity(0.9),
                      _selectedColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                widget.isEditing ? Icons.edit_rounded : Icons.add_circle_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              widget.isEditing ? 'Редактировать событие' : 'Создать событие',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getStepSubtitle(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 20),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),

              // Step indicator
              _buildStepIndicator(),

              // Form content
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildCurrentStep(),
                    ),
                  ),
                ),
              ),

              // Navigation buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousStep,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _selectedColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back, size: 18),
                              SizedBox(width: 8),
                              Text('Назад'),
                            ],
                          ),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _currentStep == 2 ? _saveEvent : _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_currentStep == 2
                                ? (widget.isEditing ? 'Обновить' : 'Создать')
                                : 'Далее'
                            ),
                            if (_currentStep < 2) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 18),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStepSubtitle() {
    switch (_currentStep) {
      case 0:
        return 'Основная информация о событии';
      case 1:
        return 'Детали и настройки';
      case 2:
        return 'Дополнительные параметры';
      default:
        return '';
    }
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1() {
    return Column(
      children: [
        // Заголовок
        _buildFormField(
          controller: _titleController,
          label: 'Название события',
          hintText: 'Введите название события',
          icon: Icons.title_rounded,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Введите название события';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Описание
        _buildFormField(
          controller: _descriptionController,
          label: 'Описание',
          hintText: 'Опишите ваше событие...',
          icon: Icons.description_rounded,
          maxLines: 4,
        ),

        const SizedBox(height: 20),

        // Категория
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Категория',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _buildCategoryGrid(),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Цвет
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Цвет события',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _buildColorPicker(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        // Дата и время
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Дата и время',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateTimeButton(
                        icon: Icons.calendar_today_rounded,
                        label: 'Дата',
                        value: DateFormat('dd.MM.yyyy').format(_selectedDate),
                        onTap: _selectDate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDateTimeButton(
                        icon: Icons.access_time_rounded,
                        label: 'Начало',
                        value: _selectedStartTime.format(context),
                        onTap: _selectStartTime,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDateTimeButton(
                        icon: Icons.timer_off_rounded,
                        label: 'Конец',
                        value: _selectedEndTime.format(context),
                        onTap: _selectEndTime,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Местоположение и тип
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Местоположение',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildFormField(
                        controller: _locationController,
                        label: 'Место проведения',
                        hintText: 'Адрес или название места',
                        icon: Icons.location_on_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        const Text('Тип события', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 8),
                        SegmentedButton(
                          segments: const [
                            ButtonSegment(value: false, label: Text('Офлайн'), icon: Icon(Icons.location_on)),
                            ButtonSegment(value: true, label: Text('Онлайн'), icon: Icon(Icons.online_prediction)),
                          ],
                          selected: {_isOnline},
                          onSelectionChanged: (Set newSelection) {
                            setState(() => _isOnline = newSelection.first);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                if (_isOnline) ...[
                  const SizedBox(height: 12),
                  _buildFormField(
                    controller: _onlineLinkController,
                    label: 'Ссылка для подключения',
                    hintText: 'https://...',
                    icon: Icons.link_rounded,
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Организатор и цена
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Организатор и цена',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildFormField(
                        controller: _organizerController,
                        label: 'Организатор',
                        hintText: 'Ваше имя или организация',
                        icon: Icons.person_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        const Text('Стоимость', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 8),
                        SegmentedButton(
                          segments: const [
                            ButtonSegment(value: true, label: Text('Бесплатно')),
                            ButtonSegment(value: false, label: Text('Платно')),
                          ],
                          selected: {_isFree},
                          onSelectionChanged: (Set newSelection) {
                            setState(() => _isFree = newSelection.first);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                if (!_isFree) ...[
                  const SizedBox(height: 12),
                  _buildFormField(
                    controller: _priceController,
                    label: 'Стоимость (₽)',
                    hintText: '0',
                    icon: Icons.attach_money_rounded,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        // Теги
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Теги',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _buildTagChips(),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Участники
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Участники',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.people_alt_rounded, color: Colors.grey),
                    const SizedBox(width: 12),
                    const Text('Максимум участников:'),
                    const Spacer(),
                    DropdownButton<int>(
                      value: _maxAttendees,
                      items: [10, 25, 50, 100, 200, 500].map((value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value человек'),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _maxAttendees = value!),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Доступность
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Доступность',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _buildAccessibilityOptions(),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Контактная информация
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Контактная информация',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _buildFormField(
                  controller: _websiteController,
                  label: 'Веб-сайт',
                  hintText: 'https://...',
                  icon: Icons.language_rounded,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildFormField(
                        controller: _phoneController,
                        label: 'Телефон',
                        hintText: '+7 ...',
                        icon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFormField(
                        controller: _emailController,
                        label: 'Email',
                        hintText: 'email@example.com',
                        icon: Icons.email_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              prefixIcon: Icon(icon, color: _selectedColor),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeButton({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _selectedColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _selectedColor.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: _selectedColor),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: _selectedColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: _selectedColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _organizerController.dispose();
    _priceController.dispose();
    _websiteController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _onlineLinkController.dispose();
    super.dispose();
  }
}