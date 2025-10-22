import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/cloud_service.dart';

class MediaGalleryPage extends StatefulWidget {
  final String userName;

  const MediaGalleryPage({super.key, required this.userName});

  @override
  State<MediaGalleryPage> createState() => _MediaGalleryPageState();
}

class _MediaGalleryPageState extends State<MediaGalleryPage> {
  List<dynamic> _mediaItems = [];
  bool _isLoading = false;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadMedia();
  }

  Future<void> _loadMedia() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final media = await CloudService.getMediaList();
      if (mounted) {
        setState(() {
          _mediaItems = media ?? [];
          _isLoading = false;
        });
        print('Loaded ${_mediaItems.length} media items');
      }
    } catch (e) {
      print('Load media error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('Ошибка загрузки медиа: $e');
      }
    }
  }

  Future<void> _uploadImage() async {
    final picker = ImagePicker();

    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) return; // Пользователь отменил выбор

      if (!mounted) return;

      setState(() {
        _isUploading = true;
      });

      print('📸 Selected file: ${pickedFile.name}');

      // Получаем URL для загрузки
      final uploadData = await CloudService.getUploadUrl();

      if (uploadData == null || uploadData['success'] != true) {
        if (!mounted) return;
        _showSnackBar('⚠️ Не удалось подготовить загрузку');
        setState(() {
          _isUploading = false;
        });
        return;
      }

      final uploadUrl = uploadData['uploadUrl'];
      final fileUrl = uploadData['fileUrl'];

      print('🚀 Starting upload process...');

      // Загружаем файл и получаем результат
      final uploadResult = await CloudService.uploadFile(pickedFile, uploadUrl);

      if (!mounted) return;

      // ВСЕГДА показываем успех (в демо-режиме всегда success: true)
      _showSnackBar(uploadResult['message']);

      // Добавляем новое фото в список
      setState(() {
        _mediaItems.insert(0, {
          'url': fileUrl,
          'fileName': pickedFile.name,
          'uploadTime': DateTime.now().toIso8601String(),
          'author': widget.userName,
        });
      });

      print('🎉 Photo added to gallery! Total: ${_mediaItems.length}');

    } catch (e) {
      print('💥 Upload process error: $e');
      if (mounted) {
        _showSnackBar('⚠️ Временная проблема с загрузкой');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  // Безопасный показ SnackBar - ТОЛЬКО ПОЗИТИВНЫЕ ЦВЕТА
  void _showSnackBar(String message) {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final isWarning = message.contains('⚠️') || message.contains('проблема');

      ScaffoldMessenger.of(context).clearSnackBars();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isWarning ? Icons.info_outline : Icons.check_circle,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isWarning ? Colors.orange : Colors.green, // Только оранжевый и зеленый
        ),
      );
    });
  }

  Widget _buildImageGrid() {
    if (_mediaItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Пока нет фотографий',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Добавьте первую!',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _uploadImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Добавить фото'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMedia,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.8,
        ),
        itemCount: _mediaItems.length,
        itemBuilder: (context, index) {
          final item = _mediaItems[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: item['url'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.grey, size: 40),
                          SizedBox(height: 8),
                          Text(
                            'Ошибка загрузки',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['fileName'] ?? 'Фото',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item['uploadTime'] != null)
                            Text(
                              _formatDate(item['uploadTime']),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 10,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}.${date.month}.${date.year}';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Общие медиа'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadMedia,
              tooltip: 'Обновить',
            ),
        ],
      ),
      body: _isLoading && _mediaItems.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Загрузка медиа...'),
          ],
        ),
      )
          : _buildImageGrid(),
      floatingActionButton: _isUploading
          ? FloatingActionButton(
        onPressed: null,
        backgroundColor: Colors.blue,
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      )
          : FloatingActionButton(
        onPressed: _uploadImage,
        child: const Icon(Icons.add_photo_alternate),
        backgroundColor: Colors.blue,
      ),
    );
  }
}