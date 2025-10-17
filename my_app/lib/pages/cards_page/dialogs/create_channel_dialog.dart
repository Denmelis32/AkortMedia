import 'package:flutter/material.dart';
import '../../rooms_pages/models/room_category.dart';

class CreateChannelDialog extends StatefulWidget {
  final String userName;
  final String userAvatarUrl;
  final List<RoomCategory> categories;
  final Function(String title, String description, String categoryId, String? avatarUrl, String? coverUrl) onCreateChannel;

  const CreateChannelDialog({
    super.key,
    required this.userName,
    required this.userAvatarUrl,
    required this.categories,
    required this.onCreateChannel,
  });

  @override
  State<CreateChannelDialog> createState() => _CreateChannelDialogState();
}

class _CreateChannelDialogState extends State<CreateChannelDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategoryId;
  String? _selectedAvatarUrl;
  String? _selectedCoverUrl;

  // Список доступных аватарок
  final List<String> _availableAvatars = [
    'https://avatars.mds.yandex.net/i?id=856af239789ab3f5f7962897c9a69647_l-12422990-images-thumbs&n=13',
    'https://avatars.mds.yandex.net/get-yapic/43978/i5F2TxqvHEddRcAEUmpIFyO2tL0-1/orig',
    'https://avatars.mds.yandex.net/i?id=62ba1b69e7eacb8bfab63982c958d61b_l-5221158-images-thumbs&n=13',
    'https://avatars.mds.yandex.net/i?id=b6988c99b85abf799a69c5470867357b_l-5235116-images-thumbs&n=13',
  ];

  // Список доступных обложек
  final List<String> _availableCovers = [
    'https://avatars.mds.yandex.net/i?id=ea37c708c5ce62c18b1bdd46eee2f008f7be91ac-11389740-images-thumbs&n=13',
    'https://avatars.mds.yandex.net/i?id=a8645c8c94fcb35eda1d8297057c76fed507e2d4-8821845-images-thumbs&n=13',
    'https://avatars.mds.yandex.net/i?id=b6988c99b85abf799a69c5470867357b_l-5235116-images-thumbs&n=13',
  ];

  bool get _isMobile => MediaQuery.of(context).size.width <= 600;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categories
        .firstWhere((c) => c.id != 'all')
        .id;
    // Выбираем случайные аватарку и обложку по умолчанию
    _selectedAvatarUrl = _availableAvatars.first;
    _selectedCoverUrl = _availableCovers.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _titleController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        _selectedCategoryId != null &&
        _selectedAvatarUrl != null &&
        _selectedCoverUrl != null;
  }

  int get _titleCharsLeft {
    return 32 - _titleController.text.length;
  }

  int get _descriptionCharsLeft {
    return 64 - _descriptionController.text.length;
  }

  void _createChannel() {
    if (_isFormValid) {
      widget.onCreateChannel(
        _titleController.text.trim(),
        _descriptionController.text.trim(),
        _selectedCategoryId!,
        _selectedAvatarUrl,
        _selectedCoverUrl,
      );
      Navigator.pop(context);
    }
  }

  void _selectAvatar(String avatarUrl) {
    setState(() {
      _selectedAvatarUrl = avatarUrl;
    });
  }

  void _selectCover(String coverUrl) {
    setState(() {
      _selectedCoverUrl = coverUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_isMobile ? 12 : 16),
      ),
      insetPadding: _isMobile
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 24)
          : const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Container(
        width: _isMobile ? double.infinity : 500, // На мобильном - вся ширина
        constraints: BoxConstraints(
          maxHeight: _isMobile ? 500 : 600, // Меньшая высота на мобильном
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: _isMobile
                ? const EdgeInsets.all(16)
                : const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                Row(
                  children: [
                    Container(
                      width: _isMobile ? 32 : 40,
                      height: _isMobile ? 32 : 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.blue, Colors.lightBlue],
                        ),
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: _isMobile ? 16 : 20,
                      ),
                    ),
                    SizedBox(width: _isMobile ? 8 : 12),
                    Expanded(
                      child: Text(
                        'Создать новый канал',
                        style: TextStyle(
                          fontSize: _isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: _isMobile ? 16 : 20),

                // ВЫБОР АВАТАРКИ
                _buildImageSelection(
                  'Аватарка канала',
                  _availableAvatars,
                  _selectedAvatarUrl,
                  _selectAvatar,
                ),
                SizedBox(height: _isMobile ? 12 : 16),

                // ВЫБОР ОБЛОЖКИ
                _buildImageSelection(
                  'Обложка канала',
                  _availableCovers,
                  _selectedCoverUrl,
                  _selectCover,
                ),
                SizedBox(height: _isMobile ? 12 : 16),

                // Поле названия
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Название канала',
                    hintText: 'Введите название (макс. 32 символа)',
                    border: const OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: _isMobile ? 12 : 16,
                      vertical: _isMobile ? 10 : 12,
                    ),
                    counterText: 'Осталось: $_titleCharsLeft',
                    counterStyle: TextStyle(
                      fontSize: _isMobile ? 11 : 12,
                      color: _titleCharsLeft < 0 ? Colors.red : Colors.grey,
                    ),
                  ),
                  maxLines: 1,
                  maxLength: 32,
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: _isMobile ? 12 : 16),

                // Поле описания
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Описание канала',
                    hintText: 'Опишите канал (макс. 64 символа)',
                    border: const OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: _isMobile ? 12 : 16,
                      vertical: _isMobile ? 10 : 12,
                    ),
                    counterText: 'Осталось: $_descriptionCharsLeft',
                    counterStyle: TextStyle(
                      fontSize: _isMobile ? 11 : 12,
                      color: _descriptionCharsLeft < 0 ? Colors.red : Colors.grey,
                    ),
                  ),
                  maxLines: _isMobile ? 2 : 2,
                  maxLength: 64,
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: _isMobile ? 12 : 16),

                // Выбор категории
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'Категория',
                    border: const OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: _isMobile ? 12 : 16,
                      vertical: _isMobile ? 10 : 12,
                    ),
                  ),
                  items: widget.categories
                      .where((category) => category.id != 'all')
                      .map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Row(
                        children: [
                          Icon(
                              category.icon,
                              color: category.color,
                              size: _isMobile ? 16 : 18
                          ),
                          SizedBox(width: _isMobile ? 8 : 12),
                          Text(
                            category.title,
                            style: TextStyle(fontSize: _isMobile ? 13 : 14),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                ),
                SizedBox(height: _isMobile ? 16 : 24),

                // ВАЛИДАЦИЯ
                if (_titleCharsLeft < 0 || _descriptionCharsLeft < 0)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(_isMobile ? 10 : 12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                            Icons.warning,
                            color: Colors.red[600],
                            size: _isMobile ? 14 : 16
                        ),
                        SizedBox(width: _isMobile ? 6 : 8),
                        Expanded(
                          child: Text(
                            _titleCharsLeft < 0 && _descriptionCharsLeft < 0
                                ? 'Слишком длинное название и описание'
                                : _titleCharsLeft < 0
                                ? 'Название слишком длинное'
                                : 'Описание слишком длинное',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: _isMobile ? 11 : 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_titleCharsLeft < 0 || _descriptionCharsLeft < 0)
                  SizedBox(height: _isMobile ? 12 : 16),

                // Кнопки действий
                _isMobile
                    ? _buildMobileButtons()
                    : _buildDesktopButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Кнопки для мобильной версии
  Widget _buildMobileButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isFormValid && _titleCharsLeft >= 0 && _descriptionCharsLeft >= 0
                ? _createChannel
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Создать канал',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Отмена',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  // Кнопки для десктопной версии
  Widget _buildDesktopButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Отмена',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isFormValid && _titleCharsLeft >= 0 && _descriptionCharsLeft >= 0
                ? _createChannel
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Создать',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  // Метод для построения выбора изображения
  Widget _buildImageSelection(
      String title,
      List<String> images,
      String? selectedImage,
      Function(String) onSelect,
      ) {
    final imageSize = _isMobile ? 60.0 : 80.0;
    final listHeight = _isMobile ? 70.0 : 80.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: _isMobile ? 13 : 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: listHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            separatorBuilder: (context, index) => SizedBox(width: _isMobile ? 6 : 8),
            itemBuilder: (context, index) {
              final imageUrl = images[index];
              final isSelected = selectedImage == imageUrl;

              return GestureDetector(
                onTap: () => onSelect(imageUrl),
                child: Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_isMobile ? 6 : 8),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey[300]!,
                      width: isSelected ? (_isMobile ? 2 : 3) : 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(_isMobile ? 5 : 6),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: SizedBox(
                              width: _isMobile ? 16 : 20,
                              height: _isMobile ? 16 : 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.grey,
                            size: _isMobile ? 20 : 24,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}