import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'event_model.dart';
import 'event_categories.dart';

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

class _AddEventDialogState extends State<AddEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late String? _selectedCategory;
  late Color _selectedColor;

  final List<EventCategory> _categories = [
    EventCategory(
      id: 'meeting',
      title: 'Встречи',
      icon: Icons.people_alt_rounded,
      color: Colors.blue,
    ),
    EventCategory(
      id: 'birthday',
      title: 'Дни рождения',
      icon: Icons.cake_rounded,
      color: Colors.pink,
    ),
    EventCategory(
      id: 'business',
      title: 'Бизнес',
      icon: Icons.business_center_rounded,
      color: Colors.orange,
    ),
    EventCategory(
      id: 'travel',
      title: 'Путешествия',
      icon: Icons.travel_explore_rounded,
      color: Colors.green,
    ),
    EventCategory(
      id: 'education',
      title: 'Обучение',
      icon: Icons.school_rounded,
      color: Colors.purple,
    ),
    EventCategory(
      id: 'health',
      title: 'Здоровье',
      icon: Icons.favorite_rounded,
      color: Colors.red,
    ),
    EventCategory(
      id: 'entertainment',
      title: 'Развлечения',
      icon: Icons.music_note_rounded,
      color: Colors.amber,
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
  ];

  @override
  void initState() {
    super.initState();

    // Инициализация значений в зависимости от режима (редактирование или создание)
    if (widget.isEditing && widget.initialEvent != null) {
      // Режим редактирования
      _titleController.text = widget.initialEvent!.title;
      _descriptionController.text = widget.initialEvent!.description;
      _selectedDate = widget.initialEvent!.date;
      _selectedTime = TimeOfDay.fromDateTime(widget.initialEvent!.date);
      _selectedCategory = widget.initialEvent!.category;
      _selectedColor = widget.initialEvent!.color;
    } else {
      // Режим создания нового события
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
      _selectedCategory = widget.initialCategory;
      _selectedColor = _getColorFromCategory(_selectedCategory);
    }
  }

  Color _getColorFromCategory(String? category) {
    if (category == null) return Colors.blue;

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
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: _selectedColor,
              onPrimary: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: _selectedColor,
              onPrimary: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      final selectedCat = _categories.firstWhere(
            (cat) => cat.title == category,
        orElse: () => _categories.first,
      );
      _selectedColor = selectedCat.color;
    });
  }

  void _onColorSelected(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      final eventDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final event = Event(
        title: _titleController.text,
        description: _descriptionController.text,
        date: eventDate,
        category: _selectedCategory,
        color: _selectedColor,
      );

      widget.onAdd(event);
      Navigator.of(context).pop();

      // Показываем подтверждение
      _showSuccessSnackbar();
    }
  }

  void _showSuccessSnackbar() {
    final message = widget.isEditing ? 'Событие успешно обновлено!' : 'Событие успешно добавлено!';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((category) {
        final isSelected = _selectedCategory == category.title;
        return FilterChip(
          selected: isSelected,
          label: Text(category.title),
          avatar: Icon(category.icon, size: 16),
          backgroundColor: isSelected ? category.color.withOpacity(0.1) : Colors.grey[100],
          selectedColor: category.color.withOpacity(0.3),
          checkmarkColor: category.color,
          labelStyle: TextStyle(
            color: isSelected ? category.color : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          onSelected: (selected) {
            if (selected) {
              _onCategorySelected(category.title);
            }
          },
        );
      }).toList(),
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
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : Border.all(color: Colors.grey[300]!, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_selectedColor, _selectedColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event_rounded, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text(
                        widget.isEditing ? 'Редактировать событие' : 'Новое событие',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Заголовок
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Название события',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon: Icon(Icons.title, color: _selectedColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _selectedColor, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите название события';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16),

                      // Описание
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Описание',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon: Icon(Icons.description, color: _selectedColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _selectedColor, width: 2),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Дата и время
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _selectDate,
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today, color: _selectedColor),
                                    SizedBox(width: 12),
                                    Text(
                                      DateFormat('dd.MM.yyyy').format(_selectedDate),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 12),

                          Expanded(
                            child: InkWell(
                              onTap: _selectTime,
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.access_time, color: _selectedColor),
                                    SizedBox(width: 12),
                                    Text(
                                      _selectedTime.format(context),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      // Категории
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Категория',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildCategoryChips(),
                        ],
                      ),

                      SizedBox(height: 20),

                      // Цвет
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Цвет события',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildColorPicker(),
                        ],
                      ),

                      SizedBox(height: 30),

                      // Кнопки
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Colors.grey),
                              ),
                              child: Text(
                                'Отмена',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                          ),

                          SizedBox(width: 16),

                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveEvent,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedColor,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              child: Text(
                                widget.isEditing ? 'Обновить' : 'Сохранить',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
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
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}