import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:my_app/providers/news_provider.dart';
import '../utils/profile_utils.dart';

class ImagePickerModal extends StatefulWidget {
  final String userEmail;
  final String? profileImageUrl;
  final File? profileImageFile;
  final Function(String) onSuccess;
  final Function(String) onError;

  const ImagePickerModal({
    super.key,
    required this.userEmail,
    this.profileImageUrl,
    this.profileImageFile,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<ImagePickerModal> createState() => _ImagePickerModalState();
}

class _ImagePickerModalState extends State<ImagePickerModal> {
  final ProfileUtils _utils = ProfileUtils();

  void _showUrlInputDialog(BuildContext context) {
    final TextEditingController urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => _UrlInputDialog(
        urlController: urlController,
        onConfirm: (url) => _handleUrlInput(context, url),
      ),
    );
  }

  Future<void> _handleUrlInput(BuildContext context, String url) async {
    if (url.isEmpty) {
      widget.onError('Введите ссылку');
      return;
    }

    try {
      String finalUrl = url;
      if (!url.startsWith('http')) {
        finalUrl = 'https://$url';
      }

      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      await newsProvider.updateProfileImageUrl(finalUrl);

      Navigator.pop(context); // Закрываем диалог
      Navigator.pop(context); // Закрываем модальное окно
      widget.onSuccess('Фото установлено!');
    } catch (e) {
      widget.onError('Ошибка: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDragHandle(),
            const SizedBox(height: 12),
            const Text(
              'Выберите фото профиля',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            _buildSourceButton(
              Icons.link_rounded,
              'Загрузить по ссылке',
              Colors.purple,
                  () => _showUrlInputDialog(context),
            ),
            const SizedBox(height: 12),
            _buildSourceButton(
              Icons.photo_library_rounded,
              'Выбрать из галереи',
              Colors.blue,
                  () => _pickImage(ImageSource.gallery, context),
            ),
            const SizedBox(height: 12),
            _buildSourceButton(
              Icons.photo_camera_rounded,
              'Сделать фото',
              Colors.green,
                  () => _pickImage(ImageSource.camera, context),
            ),
            const SizedBox(height: 12),
            if (widget.profileImageUrl != null || widget.profileImageFile != null)
              _buildSourceButton(
                Icons.delete_rounded,
                'Удалить фото',
                Colors.red,
                    () => _deleteImage(context),
              ),
            const SizedBox(height: 20),
            _buildCancelButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildSourceButton(IconData icon, String text, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 16),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.pop(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.grey[700],
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text('Отмена'),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null) {
        final newsProvider = Provider.of<NewsProvider>(context, listen: false);
        await newsProvider.updateProfileImageFile(File(image.path));
        Navigator.pop(context);
        widget.onSuccess('Фото профиля обновлено');
      }
    } catch (e) {
      widget.onError('Ошибка: $e');
    }
  }

  Future<void> _deleteImage(BuildContext context) async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    await newsProvider.updateProfileImageUrl(null);
    await newsProvider.updateProfileImageFile(null);
    Navigator.pop(context);
    widget.onSuccess('Фото профиля удалено');
  }
}

class _UrlInputDialog extends StatefulWidget {
  final TextEditingController urlController;
  final Function(String) onConfirm;

  const _UrlInputDialog({
    required this.urlController,
    required this.onConfirm,
  });

  @override
  State<_UrlInputDialog> createState() => _UrlInputDialogState();
}

class _UrlInputDialogState extends State<_UrlInputDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Введите ссылку на фото'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isLoading) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Проверка ссылки...'),
          ],
          TextField(
            controller: widget.urlController,
            decoration: const InputDecoration(
              hintText: 'https://example.com/photo.jpg',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleConfirm,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Установить'),
        ),
      ],
    );
  }

  Future<void> _handleConfirm() async {
    final url = widget.urlController.text.trim();
    if (url.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await widget.onConfirm(url);
    } catch (e) {
      setState(() => _isLoading = false);
      // Ошибка обрабатывается в onConfirm
    }
  }
}