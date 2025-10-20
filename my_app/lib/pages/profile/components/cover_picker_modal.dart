import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:my_app/providers/news_provider.dart';
import '../utils/profile_utils.dart';

class CoverPickerModal extends StatefulWidget {
  final String userEmail;
  final Function(String) onSuccess;
  final Function(String) onError;

  const CoverPickerModal({
    super.key,
    required this.userEmail,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<CoverPickerModal> createState() => _CoverPickerModalState();
}

class _CoverPickerModalState extends State<CoverPickerModal> {
  final ProfileUtils _utils = ProfileUtils();

  void _showCoverUrlInputDialog(BuildContext context) {
    final TextEditingController urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => _CoverUrlInputDialog(
        urlController: urlController,
        onConfirm: (url) => _handleCoverUrlInput(context, url),
      ),
    );
  }

  Future<void> _handleCoverUrlInput(BuildContext context, String url) async {
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
      await newsProvider.updateCoverImageUrl(finalUrl);

      Navigator.pop(context);
      Navigator.pop(context);
      widget.onSuccess('Обложка установлена!');
    } catch (e) {
      widget.onError('Ошибка: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final coverUrl = _utils.getUserCoverUrl(context, widget.userEmail);

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
              'Выберите обложку профиля',
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
                  () => _showCoverUrlInputDialog(context),
            ),
            const SizedBox(height: 12),
            _buildSourceButton(
              Icons.photo_library_rounded,
              'Выбрать из галереи',
              Colors.blue,
                  () => _pickCoverImage(ImageSource.gallery, context),
            ),
            const SizedBox(height: 12),
            _buildSourceButton(
              Icons.photo_camera_rounded,
              'Сделать фото',
              Colors.green,
                  () => _pickCoverImage(ImageSource.camera, context),
            ),
            const SizedBox(height: 12),
            if (coverUrl != null)
              _buildSourceButton(
                Icons.delete_rounded,
                'Удалить обложку',
                Colors.red,
                    () => _deleteCover(context),
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

  Future<void> _pickCoverImage(ImageSource source, BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 400,
        imageQuality: 85,
      );
      if (image != null) {
        final newsProvider = Provider.of<NewsProvider>(context, listen: false);
        await newsProvider.updateCoverImageFile(File(image.path));
        Navigator.pop(context);
        widget.onSuccess('Обложка профиля обновлена');
      }
    } catch (e) {
      widget.onError('Ошибка: $e');
    }
  }

  Future<void> _deleteCover(BuildContext context) async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    await newsProvider.updateCoverImageUrl(null);
    await newsProvider.updateCoverImageFile(null);
    Navigator.pop(context);
    widget.onSuccess('Обложка профиля удалена');
  }
}

class _CoverUrlInputDialog extends StatefulWidget {
  final TextEditingController urlController;
  final Function(String) onConfirm;

  const _CoverUrlInputDialog({
    required this.urlController,
    required this.onConfirm,
  });

  @override
  State<_CoverUrlInputDialog> createState() => _CoverUrlInputDialogState();
}

class _CoverUrlInputDialogState extends State<_CoverUrlInputDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Введите ссылку на обложку'),
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
              hintText: 'https://example.com/cover.jpg',
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