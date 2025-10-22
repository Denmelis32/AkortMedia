import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/providers/news_provider.dart'; // Добавьте этот импорт
import '../../../services/file_picker_service.dart';
import '../utils/profile_utils.dart';

class ImagePickerModal extends StatefulWidget {
  final String userEmail;
  final String? profileImageUrl;
  final File? profileImageFile;
  final Function(String) onSuccess;
  final Function(String) onError;
  final Color userColor;

  const ImagePickerModal({
    super.key,
    required this.userEmail,
    this.profileImageUrl,
    this.profileImageFile,
    required this.onSuccess,
    required this.onError,
    required this.userColor,
  });

  @override
  State<ImagePickerModal> createState() => _ImagePickerModalState();
}

class _ImagePickerModalState extends State<ImagePickerModal>
    with SingleTickerProviderStateMixin {
  final ProfileUtils _utils = ProfileUtils();
  final ImagePicker _imagePicker = ImagePicker();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool _isUploading = false;
  String? _uploadError;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showUrlInputDialog(BuildContext context) {
    final TextEditingController urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => _UrlInputDialog(
        urlController: urlController,
        userColor: widget.userColor,
        onConfirm: (url) => _handleUrlInput(context, url),
      ),
    );
  }

  Future<void> _handleUrlInput(BuildContext context, String url) async {
    if (url.isEmpty) {
      widget.onError('Введите ссылку на изображение');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadError = null;
    });

    try {
      String finalUrl = url.trim();

      // Автоматически добавляем https:// если нет схемы
      if (!finalUrl.startsWith('http')) {
        finalUrl = 'https://$finalUrl';
        print('🔧 Added https scheme: $finalUrl');
      }

      // Проверяем валидность URL
      if (!_isValidImageUrl(finalUrl)) {
        throw Exception('Некорректная ссылка на изображение. Поддерживаются JPG, PNG, GIF, WebP');
      }

      print('🔄 Processing image URL: $finalUrl');

      // Для Яндекс ссылок используем специальную обработку
      if (_isYandexImageUrl(finalUrl)) {
        await _processYandexImageUrl(context, finalUrl);
      } else {
        // Стандартная обработка для других URL
        await _processStandardImageUrl(context, finalUrl);
      }

    } catch (e) {
      print('❌ URL processing error: $e');
      setState(() {
        _isUploading = false;
        _uploadError = e.toString();
      });
      widget.onError('Ошибка загрузки: ${_getUserFriendlyError(e.toString())}');
    }
  }

  Future<void> _processStandardImageUrl(BuildContext context, String url) async {
    // Тестируем доступность изображения
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Изображение недоступно (код: ${response.statusCode})');
    }

    // Проверяем content-type
    final contentType = response.headers['content-type'];
    if (contentType == null || !contentType.startsWith('image/')) {
      throw Exception('Ссылка не ведет на изображение');
    }

    print('✅ Image URL is valid and accessible');

    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    await newsProvider.updateProfileImageUrl(url);

    // Закрываем диалог URL
    Navigator.pop(context);

    // Принудительное обновление всех аватарок
    _forceRefreshAllAvatars(newsProvider);

    // Показываем успех и закрываем модальное окно
    widget.onSuccess('Фото профиля установлено! 🎉');
    if (mounted) {
      Navigator.pop(context);
    }
  }

  /// Специальная обработка для Яндекс ссылок
  Future<void> _processYandexImageUrl(BuildContext context, String url) async {
    print('🔍 Processing Yandex image URL: $url');

    try {
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      await newsProvider.updateProfileImageUrl(url);

      // Закрываем диалог URL
      Navigator.pop(context);

      // Показываем успех с предупреждением
      widget.onSuccess('Ссылка на изображение сохранена! 📸\n(Яндекс изображения могут загружаться медленнее)');
      if (mounted) {
        Navigator.pop(context);
      }

    } catch (e) {
      throw Exception('Не удалось обработать Яндекс ссылку: $e');
    }
  }

  bool _isValidImageUrl(String url) {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.isAbsolute) return false;

      final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp', '.svg'];
      final path = uri.path.toLowerCase();

      // Проверяем расширение файла
      final hasValidExtension = imageExtensions.any((ext) => path.endsWith(ext));

      // Проверяем популярные хостинги изображений
      final validHosts = [
        'imgur.com', 'i.imgur.com', 'cloudinary.com', 'unsplash.com',
        'picsum.photos', 'pixabay.com', 'pexels.com', 'flickr.com',
        'images.unsplash.com', 'source.unsplash.com', 'googleusercontent.com',
        'yandex.net', 'avatars.mds.yandex.net'
      ];

      final hasValidHost = validHosts.any((host) => uri.host.contains(host));

      // Специальная проверка для Яндекс ссылок
      final isYandexImage = _isYandexImageUrl(url);

      return hasValidExtension || hasValidHost || isYandexImage;
    } catch (e) {
      return false;
    }
  }

  /// Специальная проверка для Яндекс изображений
  bool _isYandexImageUrl(String url) {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null) return false;

      // Проверяем Яндекс хостинг изображений
      if (uri.host.contains('yandex.net') || uri.host.contains('yandex.ru')) {
        final path = uri.path.toLowerCase();
        final query = uri.query.toLowerCase();

        final hasImageId = query.contains('i?id=') || query.contains('image=') || query.contains('img=');
        final hasImagePath = path.contains('/get-') ||
            path.contains('/images/') ||
            path.contains('/avatars/') ||
            path.contains('/thumbs') ||
            path.contains('/images-thumbs');

        return hasImageId || hasImagePath;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Проверка платформы
  bool get _isWebPlatform => FilePickerService.isWeb;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDragHandle(),
                    const SizedBox(height: 16),
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildCurrentPhotoPreview(),
                    const SizedBox(height: 20),
                    // Показываем индикатор загрузки или ошибку
                    if (_isUploading) _buildUploadingIndicator(),
                    if (_uploadError != null) _buildErrorIndicator(),
                    _buildOptionsGrid(context),
                    const SizedBox(height: 20),
                    _buildCancelButton(context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUploadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(widget.userColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Загрузка изображения...',
              style: TextStyle(
                color: Colors.blue[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[100]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getUserFriendlyError(_uploadError),
              style: TextStyle(
                color: Colors.red[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, size: 16, color: Colors.red),
            onPressed: () => setState(() => _uploadError = null),
          ),
        ],
      ),
    );
  }

  String _getUserFriendlyError(String? error) {
    if (error == null) return 'Ошибка загрузки';

    if (error.contains('namespace') || error.contains('permission')) {
      return 'Ошибка доступа к файлам. Проверьте разрешения приложения.';
    } else if (error.contains('path') || error.contains('file')) {
      return 'Не удалось получить доступ к файлу. Попробуйте другое изображение.';
    } else if (error.contains('network') || error.contains('socket')) {
      return 'Ошибка сети. Проверьте подключение к интернету.';
    } else if (error.contains('format') || error.contains('image')) {
      return 'Неподдерживаемый формат изображения. Используйте JPG, PNG или GIF.';
    } else if (error.contains('PhotoAccess')) {
      return 'Нет доступа к галерее. Предоставьте разрешение в настройках устройства.';
    } else if (error.contains('camera')) {
      return 'Камера недоступна. Проверьте разрешения или используйте другое устройство.';
    } else if (error.contains('Unsupported operation') || error.contains('_Namespace')) {
      return 'Функция не поддерживается в веб-версии. Используйте загрузку по ссылке.';
    }

    return error;
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.userColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.photo_camera_rounded, color: widget.userColor, size: 22),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Фото профиля',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Выберите способ загрузки изображения',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentPhotoPreview() {
    final hasCurrentPhoto = widget.profileImageUrl != null || widget.profileImageFile != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!, width: 2),
            ),
            child: ClipOval(
              child: _buildPreviewImage(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasCurrentPhoto ? 'Текущее фото' : 'Фото не установлено',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasCurrentPhoto
                      ? 'Нажмите для предпросмотра'
                      : 'Выберите фото из вариантов ниже',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (hasCurrentPhoto && !_isUploading) ...[
            const SizedBox(width: 8),
            Tooltip(
              message: 'Удалить фото',
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _deleteImage(context),
                    borderRadius: BorderRadius.circular(18),
                    child: Icon(Icons.delete_rounded, color: Colors.red, size: 18),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewImage() {
    if (widget.profileImageFile != null) {
      return Image.file(widget.profileImageFile!, fit: BoxFit.cover);
    } else if (widget.profileImageUrl != null) {
      return Image.network(
        widget.profileImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Error loading network image: $error');
          return _buildDefaultAvatar();
        },
      );
    } else {
      return _buildDefaultAvatar();
    }
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [widget.userColor, _utils.darkenColor(widget.userColor, 0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
    );
  }

  Widget _buildOptionsGrid(BuildContext context) {
    final options = [
      _OptionItem(
        'Загрузить по ссылке',
        Icons.link_rounded,
        Colors.purple,
        'Из интернета',
            () => _showUrlInputDialog(context),
      ),
      if (!_isWebPlatform) // Скрываем галерею и камеру на веб-платформе
        _OptionItem(
          'Из галереи',
          Icons.photo_library_rounded,
          Colors.blue,
          'Ваши фото',
              () => _pickImage(ImageSource.gallery, context),
        ),
      if (!_isWebPlatform) // Скрываем галерею и камеру на веб-платформе
        _OptionItem(
          'Камера',
          Icons.photo_camera_rounded,
          Colors.green,
          'Сделать фото',
              () => _pickImage(ImageSource.camera, context),
        ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _isWebPlatform ? 2 : 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        return _buildOptionCard(options[index]);
      },
    );
  }

  Widget _buildOptionCard(_OptionItem option) {
    final isDisabled = _isUploading;

    return Tooltip(
      message: isDisabled ? 'Загрузка в процессе...' : option.description,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : option.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Opacity(
            opacity: isDisabled ? 0.6 : 1.0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: option.color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: option.color.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: option.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(option.icon, color: option.color, size: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    option.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isUploading ? null : () => Navigator.pop(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.grey[700],
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(
          _isUploading ? 'Отмена (загрузка...)' : 'Отмена',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: _isUploading ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    if (_isUploading) return;

    setState(() {
      _isUploading = true;
      _uploadError = null;
    });

    try {
      print('🔄 Starting image picker with source: $source');

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        requestFullMetadata: false,
      ).catchError((error) {
        print('❌ Image picker error: $error');
        throw Exception(_parseImagePickerError(error));
      });

      if (image != null && mounted) {
        print('✅ Image selected: ${image.path}');
        await _processSelectedImage(image, context);
      } else {
        // Пользователь отменил выбор
        print('ℹ️ User cancelled image selection');
        setState(() {
          _isUploading = false;
        });
      }
    } catch (e) {
      print('❌ Image picker critical error: $e');
      _handleImagePickError(e);
    }
  }

  String _parseImagePickerError(dynamic error) {
    final errorString = error.toString();

    if (errorString.contains('namespace') || errorString.contains('permission')) {
      return 'Ошибка доступа к файлам. Проверьте разрешения приложения.';
    } else if (errorString.contains('path') || errorString.contains('file')) {
      return 'Не удалось получить доступ к файлу. Попробуйте другое изображение.';
    } else if (errorString.contains('PhotoAccess')) {
      return 'Нет доступа к галерее. Предоставьте разрешение в настройках устройства.';
    } else if (errorString.contains('camera')) {
      return 'Камера недоступна. Проверьте разрешения или используйте другое устройство.';
    } else if (errorString.contains('cancel')) {
      return 'Выбор отменен';
    } else if (errorString.contains('Unsupported operation') || errorString.contains('_Namespace')) {
      return 'Функция не поддерживается в веб-версии. Используйте загрузку по ссылке или "Загрузить файл".';
    }

    return 'Ошибка при выборе изображения: $errorString';
  }

  Future<void> _processSelectedImage(XFile image, BuildContext context) async {
    try {
      print('🔄 Processing selected image: ${image.path}');

      // Проверяем, доступен ли файл
      final file = File(image.path);
      if (!await file.exists()) {
        throw Exception('Файл не найден или недоступен');
      }

      // Проверяем размер файла
      final fileStat = await file.stat();
      if (fileStat.size > 10 * 1024 * 1024) { // 10MB лимит
        throw Exception('Файл слишком большой. Максимальный размер: 10MB');
      }

      // Проверяем, что это действительно изображение
      final bytes = await file.readAsBytes();
      if (bytes.lengthInBytes < 100) { // Минимальный размер для изображения
        throw Exception('Файл слишком маленький или поврежден');
      }

      print('✅ Image validation passed, size: ${fileStat.size} bytes');

      final newsProvider = Provider.of<NewsProvider>(context, listen: false);

      // Сохраняем файл
      await newsProvider.updateProfileImageFile(file);

      // Принудительное обновление всех аватарок
      _forceRefreshAllAvatars(newsProvider);

      // Показываем успех и закрываем модальное окно
      widget.onSuccess('Фото профиля обновлено! 📸');
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('❌ Image processing error: $e');
      _handleImagePickError(e);
    }
  }

  void _forceRefreshAllAvatars(NewsProvider newsProvider) {
    print('🔄 [IMAGE PICKER] Force refreshing all avatars...');

    // 1. Принудительно перезагружаем данные профиля
    newsProvider.loadProfileData().then((_) {
      print('✅ [IMAGE PICKER] Profile data reloaded');

      // 2. Уведомляем всех слушателей о изменении аватарок
      newsProvider.notifyListeners();

      // 3. Можно добавить дополнительную логику для обновления конкретных постов
      _notifyPostsAboutAvatarChange(newsProvider);
    });
  }

  void _notifyPostsAboutAvatarChange(NewsProvider newsProvider) {
    final userId = _utils.generateUserId(widget.userEmail);
    print('🔄 [IMAGE PICKER] Notifying posts about avatar change for user: $userId');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('✅ [IMAGE PICKER] Posts notified about avatar change');
    });
  }

  void _handleImagePickError(dynamic error) {
    setState(() {
      _isUploading = false;
      _uploadError = error.toString();
    });

    final errorMessage = _getUserFriendlyError(error.toString());
    widget.onError('Ошибка при выборе фото: $errorMessage');
  }

  Future<void> _deleteImage(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить фото?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              final newsProvider = Provider.of<NewsProvider>(context, listen: false);
              await newsProvider.updateProfileImageUrl(null);
              await newsProvider.updateProfileImageFile(null);

              // Принудительное обновление после удаления
              _forceRefreshAllAvatars(newsProvider);

              Navigator.pop(context); // Закрываем диалог подтверждения
              widget.onSuccess('Фото профиля удалено');
              if (mounted) {
                Navigator.pop(context); // Закрываем модальное окно
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}

class _UrlInputDialog extends StatefulWidget {
  final TextEditingController urlController;
  final Function(String) onConfirm;
  final Color userColor;

  const _UrlInputDialog({
    required this.urlController,
    required this.onConfirm,
    required this.userColor,
  });

  @override
  State<_UrlInputDialog> createState() => _UrlInputDialogState();
}

class _UrlInputDialogState extends State<_UrlInputDialog> {
  bool _isLoading = false;
  bool _isValidUrl = false;
  String _validationMessage = 'Введите ссылку на изображение';

  @override
  void initState() {
    super.initState();
    widget.urlController.addListener(_validateUrl);
  }

  @override
  void dispose() {
    widget.urlController.removeListener(_validateUrl);
    super.dispose();
  }

  void _validateUrl() {
    final url = widget.urlController.text.trim();
    final isValid = url.isNotEmpty && _isImageUrl(url);

    setState(() {
      _isValidUrl = isValid;
      _validationMessage = _getUrlHint(url);
    });
  }

  bool _isImageUrl(String url) {
    try {
      if (url.isEmpty) return false;

      // Автоматически добавляем https:// для проверки
      String testUrl = url;
      if (!testUrl.startsWith('http')) {
        testUrl = 'https://$testUrl';
      }

      final uri = Uri.tryParse(testUrl);
      if (uri == null || !uri.isAbsolute) return false;

      final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
      final path = uri.path.toLowerCase();

      final hasValidExtension = imageExtensions.any((ext) => path.endsWith(ext));

      // Популярные хостинги изображений
      final validHosts = [
        'imgur.com', 'i.imgur.com', 'cloudinary.com', 'unsplash.com',
        'picsum.photos', 'pixabay.com', 'pexels.com', 'flickr.com',
        'images.unsplash.com', 'source.unsplash.com', 'googleusercontent.com',
        'yandex.net', 'avatars.mds.yandex.net'
      ];

      final hasValidHost = validHosts.any((host) => uri.host.contains(host));

      // Специальная проверка для Яндекс
      final isYandex = uri.host.contains('yandex') &&
          (uri.query.contains('i?id=') ||
              path.contains('/images/') ||
              path.contains('/avatars/'));

      return hasValidExtension || hasValidHost || isYandex;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ссылка на изображение'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isLoading) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Проверка и загрузка...'),
          ] else ...[
            TextField(
              controller: widget.urlController,
              decoration: InputDecoration(
                hintText: 'https://example.com/photo.jpg',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.link_rounded),
                suffixIcon: _isValidUrl
                    ? Icon(Icons.check_circle_rounded, color: Colors.green)
                    : widget.urlController.text.isNotEmpty
                    ? Icon(Icons.error_rounded, color: Colors.red)
                    : null,
              ),
              onSubmitted: _isValidUrl ? (_) => _handleConfirm() : null,
            ),
            const SizedBox(height: 8),
            Text(
              _validationMessage,
              style: TextStyle(
                color: _isValidUrl ? Colors.green :
                widget.urlController.text.isNotEmpty ? Colors.red : Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            _buildExampleUrls(),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _isLoading || !_isValidUrl ? null : _handleConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.userColor,
          ),
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Загрузить'),
        ),
      ],
    );
  }

  Widget _buildExampleUrls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Примеры работающих ссылок:',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11,
          ),
        ),
        Text(
          '• https://picsum.photos/200/300',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 10,
          ),
        ),
        Text(
          '• https://i.imgur.com/abc123.jpg',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  String _getUrlHint(String url) {
    if (url.isEmpty) {
      return 'Введите ссылку на изображение';
    }

    if (!_isValidUrl) {
      return 'Введите корректную ссылку на изображение (JPG, PNG, GIF)';
    }

    return 'Ссылка корректна, можно загружать';
  }

  Future<void> _handleConfirm() async {
    final url = widget.urlController.text.trim();
    if (url.isEmpty || !_isValidUrl) return;

    setState(() => _isLoading = true);
    try {
      await widget.onConfirm(url);
    } catch (e) {
      setState(() => _isLoading = false);
      rethrow;
    }
  }
}

class _OptionItem {
  final String title;
  final IconData icon;
  final Color color;
  final String description;
  final VoidCallback onTap;

  const _OptionItem(this.title, this.icon, this.color, this.description, this.onTap);
}