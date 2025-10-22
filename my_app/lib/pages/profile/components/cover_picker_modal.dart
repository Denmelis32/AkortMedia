import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/providers/news_providers/news_provider.dart';
import 'package:my_app/services/file_picker_service.dart'; // Исправленный путь
import '../utils/profile_utils.dart';

class CoverPickerModal extends StatefulWidget {
  final String userEmail;
  final String? coverImageUrl;
  final File? coverImageFile;
  final Function(String) onSuccess;
  final Function(String) onError;
  final Color userColor;

  const CoverPickerModal({
    super.key,
    required this.userEmail,
    this.coverImageUrl,
    this.coverImageFile,
    required this.onSuccess,
    required this.onError,
    required this.userColor,
  });

  @override
  State<CoverPickerModal> createState() => _CoverPickerModalState();
}

class _CoverPickerModalState extends State<CoverPickerModal> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;
  String? _uploadError;

  // Проверка платформы
  bool get _isWebPlatform => FilePickerService.isWeb;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
            _buildCurrentCoverPreview(),
            const SizedBox(height: 20),

            if (_isUploading) _buildUploadingIndicator(),
            if (_uploadError != null) _buildErrorIndicator(),

            _buildOptionsGrid(context),
            const SizedBox(height: 20),
            _buildCancelButton(context),
          ],
        ),
      ),
    );
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
          child: Icon(Icons.photo_library_rounded, color: widget.userColor, size: 22),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Обложка профиля',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Выберите способ загрузки обложки',
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

  Widget _buildCurrentCoverPreview() {
    final hasCurrentCover = widget.coverImageUrl != null || widget.coverImageFile != null;

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
            width: 80,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: _buildPreviewImage(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasCurrentCover ? 'Текущая обложка' : 'Обложка не установлена',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasCurrentCover
                      ? 'Нажмите для предпросмотра'
                      : 'Выберите обложку из вариантов ниже',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (hasCurrentCover && !_isUploading) ...[
            const SizedBox(width: 8),
            Tooltip(
              message: 'Удалить обложку',
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
                    onTap: () => _deleteCover(context),
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
    if (widget.coverImageFile != null) {
      return Image.file(widget.coverImageFile!, fit: BoxFit.cover);
    } else if (widget.coverImageUrl != null) {
      return Image.network(
        widget.coverImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultCover();
        },
      );
    } else {
      return _buildDefaultCover();
    }
  }

  Widget _buildDefaultCover() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [widget.userColor, _darkenColor(widget.userColor, 0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(Icons.photo_library_rounded, color: Colors.white, size: 24),
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
          const Expanded(
            child: Text(
              'Загрузка обложки...',
              style: TextStyle(
                color: Colors.blue,
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

  Widget _buildOptionsGrid(BuildContext context) {
    final options = [
      _OptionItem(
        'Загрузить по ссылке',
        Icons.link_rounded,
        Colors.purple,
        'Из интернета',
            () => _showUrlInputDialog(context),
      ),
      if (!_isWebPlatform) // Скрываем галерею на веб-платформе
        _OptionItem(
          'Из галереи',
          Icons.photo_library_rounded,
          Colors.blue,
          'Ваши фото',
              () => _pickImage(ImageSource.gallery, context),
        ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _isWebPlatform ? 2 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
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

  void _showUrlInputDialog(BuildContext context) {
    final TextEditingController urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => _CoverUrlInputDialog(
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
        print('🔧 [COVER] Added https scheme: $finalUrl');
      }

      // Проверяем валидность URL
      if (!_isValidImageUrl(finalUrl)) {
        throw Exception('Некорректная ссылка на изображение. Поддерживаются JPG, PNG, GIF, WebP');
      }

      print('🔄 [COVER] Processing cover URL: $finalUrl');

      // Проверяем доступность изображения
      print('   🔍 [COVER] Checking image availability...');
      final response = await http.get(Uri.parse(finalUrl));
      if (response.statusCode != 200) {
        throw Exception('Изображение недоступно (код: ${response.statusCode})');
      }

      // Проверяем content-type
      final contentType = response.headers['content-type'];
      if (contentType == null || !contentType.startsWith('image/')) {
        throw Exception('Ссылка не ведет на изображение');
      }

      print('✅ [COVER] Cover URL is valid and accessible');

      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      await newsProvider.updateCoverImageUrl(finalUrl);

      // Закрываем диалог URL
      Navigator.pop(context);

      // Показываем успех и закрываем модальное окно
      widget.onSuccess('Обложка установлена! 🎉');
      if (mounted) {
        Navigator.pop(context);
      }

    } catch (e) {
      print('❌ [COVER] URL processing error: $e');
      setState(() {
        _isUploading = false;
        _uploadError = e.toString();
      });
      widget.onError('Ошибка загрузки: ${_getUserFriendlyError(e.toString())}');
    }
  }

  bool _isValidImageUrl(String url) {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.isAbsolute) return false;

      final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
      final path = uri.path.toLowerCase();

      final hasValidExtension = imageExtensions.any((ext) => path.endsWith(ext));

      final validHosts = [
        'imgur.com', 'i.imgur.com', 'cloudinary.com', 'unsplash.com',
        'picsum.photos', 'pixabay.com', 'pexels.com', 'flickr.com',
        'images.unsplash.com', 'source.unsplash.com', 'googleusercontent.com',
        'yandex.net', 'avatars.mds.yandex.net'
      ];

      final hasValidHost = validHosts.any((host) => uri.host.contains(host));

      return hasValidExtension || hasValidHost;
    } catch (e) {
      return false;
    }
  }

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    if (_isUploading) return;

    setState(() {
      _isUploading = true;
      _uploadError = null;
    });

    try {
      print('🔄 [COVER] Starting image picker with source: $source');

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90,
        requestFullMetadata: false,
      ).catchError((error) {
        print('❌ [COVER] Image picker error: $error');
        throw Exception(_parseImagePickerError(error));
      });

      if (image != null && mounted) {
        print('✅ [COVER] Image selected: ${image.path}');
        await _processSelectedCover(image, context);
      } else {
        // Пользователь отменил выбор
        print('ℹ️ [COVER] User cancelled image selection');
        setState(() {
          _isUploading = false;
        });
      }
    } catch (e) {
      print('❌ [COVER] Image picker critical error: $e');
      _handleImagePickError(e);
    }
  }

  Future<void> _processSelectedCover(XFile image, BuildContext context) async {
    try {
      final file = File(image.path);
      if (!await file.exists()) {
        throw Exception('Файл не найден или недоступен');
      }

      // Проверяем размер файла (до 15MB для обложки)
      final fileStat = await file.stat();
      if (fileStat.size > 15 * 1024 * 1024) {
        throw Exception('Файл слишком большой. Максимальный размер: 15MB');
      }

      // Проверяем, что это действительно изображение
      final bytes = await file.readAsBytes();
      if (bytes.lengthInBytes < 100) {
        throw Exception('Файл слишком маленький или поврежден');
      }

      print('✅ [COVER] Cover validation passed, size: ${fileStat.size} bytes');

      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      await newsProvider.updateCoverImageFile(file);

      widget.onSuccess('Обложка обновлена! 📸');
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('❌ [COVER] Cover processing error: $e');
      _handleImagePickError(e);
    }
  }

  void _handleImagePickError(dynamic error) {
    setState(() {
      _isUploading = false;
      _uploadError = error.toString();
    });

    final errorMessage = _getUserFriendlyError(error.toString());
    widget.onError('Ошибка при выборе обложки: $errorMessage');
  }

  Future<void> _deleteCover(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить обложку?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              final newsProvider = Provider.of<NewsProvider>(context, listen: false);
              await newsProvider.removeCoverImage();
              Navigator.pop(context); // Закрываем диалог подтверждения
              widget.onSuccess('Обложка удалена');
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
      return 'Функция не поддерживается в веб-версии. Используйте загрузку по ссылке.';
    }

    return 'Ошибка при выборе изображения: $errorString';
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

  Color _darkenColor(Color color, double factor) {
    assert(factor >= 0 && factor <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - factor).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

class _CoverUrlInputDialog extends StatefulWidget {
  final TextEditingController urlController;
  final Function(String) onConfirm;
  final Color userColor;

  const _CoverUrlInputDialog({
    required this.urlController,
    required this.onConfirm,
    required this.userColor,
  });

  @override
  State<_CoverUrlInputDialog> createState() => _CoverUrlInputDialogState();
}

class _CoverUrlInputDialogState extends State<_CoverUrlInputDialog> {
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

      final validHosts = [
        'imgur.com', 'i.imgur.com', 'cloudinary.com', 'unsplash.com',
        'picsum.photos', 'pixabay.com', 'pexels.com', 'flickr.com',
        'images.unsplash.com', 'source.unsplash.com', 'googleusercontent.com',
        'yandex.net', 'avatars.mds.yandex.net'
      ];

      final hasValidHost = validHosts.any((host) => uri.host.contains(host));

      return hasValidExtension || hasValidHost;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ссылка на обложку'),
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
                hintText: 'https://example.com/cover.jpg',
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
          '• https://picsum.photos/1200/400',
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