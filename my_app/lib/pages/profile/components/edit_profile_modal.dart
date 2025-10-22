import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditProfileModal extends StatefulWidget {
  final String currentBio;
  final String currentLocation;
  final String currentWebsite;
  final Function(String, String, String) onSave;
  final String userName;
  final String userEmail;

  const EditProfileModal({
    super.key,
    required this.currentBio,
    required this.currentLocation,
    required this.currentWebsite,
    required this.onSave,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal>
    with SingleTickerProviderStateMixin {
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  late TextEditingController _websiteController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // НОВОЕ: Состояние валидации
  final Map<String, bool> _fieldValidity = {
    'bio': true,
    'location': true,
    'website': true,
  };

  final Map<String, String> _fieldErrors = {
    'bio': '',
    'location': '',
    'website': '',
  };

  // НОВОЕ: Счетчик символов
  int _bioCharCount = 0;
  final int _bioMaxChars = 200;

  // НОВОЕ: Состояние загрузки
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.currentBio);
    _locationController = TextEditingController(text: widget.currentLocation);
    _websiteController = TextEditingController(text: widget.currentWebsite);

    _bioCharCount = widget.currentBio.length;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();

    // НОВОЕ: Слушатели для валидации в реальном времени
    _bioController.addListener(_validateBio);
    _websiteController.addListener(_validateWebsite);
  }

  void _validateBio() {
    setState(() {
      _bioCharCount = _bioController.text.length;
      _fieldValidity['bio'] = _bioCharCount <= _bioMaxChars;
      _fieldErrors['bio'] = _bioCharCount > _bioMaxChars
          ? 'Максимум $_bioMaxChars символов'
          : '';
    });
  }

  void _validateWebsite() {
    final text = _websiteController.text.trim();
    setState(() {
      if (text.isEmpty) {
        _fieldValidity['website'] = true;
        _fieldErrors['website'] = '';
      } else {
        final isValid = _isValidUrl(text);
        _fieldValidity['website'] = isValid;
        _fieldErrors['website'] = isValid ? '' : 'Введите корректный URL';
      }
    });
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                // НОВОЕ: Улучшенный заголовок
                _buildHeader(),
                // НОВОЕ: Предпросмотр профиля
                _buildProfilePreview(),
                // НОВОЕ: Улучшенная форма
                _buildForm(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.close_rounded, color: Colors.grey[700]),
            onPressed: _isSaving ? null : () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Редактировать профиль',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          // НОВОЕ: Умная кнопка сохранения
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getSaveButtonColor(),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          elevation: 2,
        ),
        child: _isSaving
            ? SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Colors.white.withOpacity(0.8)),
          ),
        )
            : const Text(
          'Сохранить',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Color _getSaveButtonColor() {
    if (_isSaving) return Colors.grey;
    if (!_fieldValidity.values.every((valid) => valid)) return Colors.grey;
    return Colors.blue;
  }

  // НОВОЕ: Предпросмотр профиля
  Widget _buildProfilePreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '@${widget.userName.toLowerCase().replaceAll(' ', '_')}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                if (_bioController.text.isNotEmpty &&
                    _bioController.text != 'Расскажите о себе...')
                  Text(
                    _bioController.text.length > 60
                        ? '${_bioController.text.substring(0, 60)}...'
                        : _bioController.text,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Expanded(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // НОВОЕ: Улучшенное поле био с счетчиком
            _buildBioField(),
            const SizedBox(height: 24),
            // НОВОЕ: Поле местоположения с геолокацией
            _buildLocationField(),
            const SizedBox(height: 24),
            // НОВОЕ: Умное поле веб-сайта
            _buildWebsiteField(),
            const SizedBox(height: 30),
            // НОВОЕ: Улучшенные подсказки
            _buildEnhancedTips(),
          ],
        ),
      ),
    );
  }

  Widget _buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Биография', Icons.description_rounded),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _fieldValidity['bio']! ? Colors.grey[300]! : Colors.red,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: _bioController,
            maxLines: 4,
            maxLength: _bioMaxChars,
            decoration: InputDecoration(
              hintText: 'Расскажите о себе, своих интересах и увлечениях...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              counterText: '',
            ),
            style: const TextStyle(fontSize: 15),
          ),
        ),
        // НОВОЕ: Счетчик символов и ошибка
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _fieldErrors['bio']!,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$_bioCharCount/$_bioMaxChars',
                style: TextStyle(
                  color: _bioCharCount > _bioMaxChars
                      ? Colors.red
                      : Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Местоположение', Icons.location_on_rounded),
        const SizedBox(height: 8),
        TextField(
          controller: _locationController,
          decoration: InputDecoration(
            hintText: 'Город, страна',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[500]),
            suffixIcon: IconButton(
              icon: Icon(Icons.my_location_rounded, color: Colors.blue),
              onPressed: _getCurrentLocation,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebsiteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Веб-сайт', Icons.link_rounded),
        const SizedBox(height: 8),
        TextField(
          controller: _websiteController,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            hintText: 'https://example.com',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: _fieldValidity['website']! ? Colors.grey[300]! : Colors.red,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: _fieldValidity['website']! ? Colors.blue : Colors.red,
              ),
            ),
            prefixIcon: Icon(Icons.link_rounded, color: Colors.grey[500]),
            errorText: _fieldErrors['website']!.isNotEmpty
                ? _fieldErrors['website']
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedTips() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.lightBlue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Как заполнить профиль',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.blue,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem('🎯 Будьте конкретны в биографии'),
          _buildTipItem('📍 Укажите реальное местоположение'),
          _buildTipItem('🔗 Добавьте ссылки на проекты'),
          _buildTipItem('💫 Покажите свою уникальность'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.blue.shade800,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _getCurrentLocation() {
    // Заглушка для геолокации
    _locationController.text = 'Москва, Россия';
    _showSuccessMessage('Местоположение определено');
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;

    // Финальная валидация
    if (!_fieldValidity.values.every((valid) => valid)) {
      _showErrorMessage('Исправьте ошибки в форме');
      return;
    }

    setState(() => _isSaving = true);

    // Имитация задержки сети
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      final bio = _bioController.text.trim();
      final location = _locationController.text.trim();
      final website = _websiteController.text.trim();

      widget.onSave(
        bio.isEmpty ? 'Расскажите о себе...' : bio,
        location.isEmpty ? 'Город не указан' : location,
        website,
      );

      _showSuccessMessage('Профиль обновлен!');
      Navigator.pop(context);
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}