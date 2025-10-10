import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../../providers/channel_state_provider.dart';
import '../../models/channel.dart';

class ChannelHeader extends StatefulWidget {
  final Channel channel;
  final bool editable;
  final Function(String)? onAvatarChanged;
  final Function(String)? onCoverChanged;
  final Function(List<String>)? onHashtagsChanged;
  final Function(String)? onCurrentAvatarUrl; // НОВЫЙ КОЛБЭК ДЛЯ ПЕРЕДАЧИ ТЕКУЩЕЙ АВАТАРКИ

  const ChannelHeader({
    super.key,
    required this.channel,
    this.editable = false,
    this.onAvatarChanged,
    this.onCoverChanged,
    this.onHashtagsChanged,
    this.onCurrentAvatarUrl, // ДОБАВЛЕН НОВЫЙ ПАРАМЕТР
  });

  @override
  State<ChannelHeader> createState() => _ChannelHeaderState();
}

class _ChannelHeaderState extends State<ChannelHeader> {
  final TextEditingController _hashtagController = TextEditingController();
  String? _currentAvatarUrl; // ЛОКАЛЬНОЕ СОСТОЯНИЕ ДЛЯ АВАТАРКИ

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChannelState();
    });
  }

  void _initializeChannelState() {
    final provider = Provider.of<ChannelStateProvider>(context, listen: false);

    // Инициализируем аватарку, если еще не установлена
    if (provider.getAvatarForChannel(widget.channel.id.toString()) == null) {
      provider.setAvatarForChannel(widget.channel.id.toString(), widget.channel.imageUrl);
    }

    // Инициализируем обложку, если еще не установлена
    if (provider.getCoverForChannel(widget.channel.id.toString()) == null) {
      provider.setCoverForChannel(widget.channel.id.toString(), widget.channel.coverImageUrl);
    }

    // Инициализируем хештеги, если еще не установлены
    if (provider.getHashtagsForChannel(widget.channel.id.toString()).isEmpty) {
      provider.setHashtagsForChannel(widget.channel.id.toString(), widget.channel.tags);
    }

    // Устанавливаем текущую аватарку и уведомляем родителя
    _updateCurrentAvatar(provider);
  }

  void _updateCurrentAvatar(ChannelStateProvider provider) {
    final avatarUrl = provider.getAvatarForChannel(widget.channel.id.toString());
    setState(() {
      _currentAvatarUrl = avatarUrl;
    });
    // Уведомляем родителя о текущей аватарке
    widget.onCurrentAvatarUrl?.call(avatarUrl ?? widget.channel.imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChannelStateProvider>(
      builder: (context, provider, child) {
        final avatarUrl = provider.getAvatarForChannel(widget.channel.id.toString());
        final coverUrl = provider.getCoverForChannel(widget.channel.id.toString());
        final hashtags = provider.getHashtagsForChannel(widget.channel.id.toString());

        // Обновляем текущую аватарку при изменении в провайдере
        if (_currentAvatarUrl != avatarUrl) {
          _updateCurrentAvatar(provider);
        }

        return Stack(
          children: [
            // ОБЛОЖКА КАНАЛА
            _buildCoverImage(coverUrl),
            _buildCoverGradient(),

            // Градиент поверх фона
            _buildBackgroundGradient(),

            // Контент заголовка
            _buildContent(avatarUrl, hashtags),

            // КНОПКИ РЕДАКТИРОВАНИЯ
            if (widget.editable) _buildEditButtons(provider),
          ],
        );
      },
    );
  }

  // ОСТАЛЬНЫЕ МЕТОДЫ ОСТАЮТСЯ БЕЗ ИЗМЕНЕНИЙ...
  Widget _buildCoverImage(String? coverUrl) {
    return Positioned.fill(
      child: coverUrl != null && coverUrl.isNotEmpty
          ? CachedNetworkImage(
        imageUrl: coverUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: widget.channel.cardColor,
        ),
        errorWidget: (context, url, error) => _buildDefaultBackground(),
      )
          : _buildDefaultBackground(),
    );
  }

  Widget _buildDefaultBackground() {
    return Container(
      color: widget.channel.cardColor,
      height: double.infinity,
      width: double.infinity,
    );
  }

  Widget _buildCoverGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.black.withOpacity(0.4),
            Colors.transparent,
            Colors.black.withOpacity(0.2),
            Colors.black.withOpacity(0.6),
          ],
          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            widget.channel.cardColor.withOpacity(0.2),
            widget.channel.cardColor.withOpacity(0.1),
            Colors.transparent,
            widget.channel.cardColor.withOpacity(0.1),
            widget.channel.cardColor.withOpacity(0.3),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(String? avatarUrl, List<String> hashtags) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.black.withOpacity(0.4),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // АВАТАРКА
            _buildAvatar(avatarUrl),
            const SizedBox(height: 12),

            // Название канала
            _buildTitle(),
            const SizedBox(height: 8),

            // ХЕШТЕГИ
            if (hashtags.isNotEmpty) _buildHashtags(hashtags),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String? avatarUrl) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // АВАТАРКА
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: avatarUrl != null && avatarUrl.isNotEmpty
                ? CachedNetworkImage(
              imageUrl: avatarUrl,
              placeholder: (context, url) => _buildAvatarPlaceholder(),
              errorWidget: (context, url, error) => _buildAvatarPlaceholder(),
              fit: BoxFit.cover,
            )
                : _buildAvatarPlaceholder(),
          ),
        ),

        // ИНДИКАТОР РЕДАКТИРОВАНИЯ
        if (widget.editable)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.edit,
                color: Colors.white,
                size: 10,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: Colors.white.withOpacity(0.2),
      child: const Icon(Icons.person, color: Colors.white, size: 30),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.channel.title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [
          Shadow(
            blurRadius: 8,
            color: Colors.black87,
            offset: Offset(0, 1),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildHashtags(List<String> hashtags) {
    final cleanedHashtags = hashtags
        .map((tag) => tag.replaceAll('#', '').trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    if (cleanedHashtags.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        alignment: WrapAlignment.center,
        children: cleanedHashtags.map((tag) {
          final displayTag = '#$tag';
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
            ),
            child: Text(
              displayTag,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEditButtons(ChannelStateProvider provider) {
    return Positioned(
      bottom: 16,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildEditButton(
            icon: Icons.person,
            tooltip: 'Сменить аватарку',
            onPressed: () => _changeAvatar(provider),
            color: Colors.purple,
          ),
          const SizedBox(height: 8),
          _buildEditButton(
            icon: Icons.photo,
            tooltip: 'Сменить обложку',
            onPressed: () => _changeCoverImage(provider),
            color: Colors.green,
          ),
          const SizedBox(height: 8),
          _buildEditButton(
            icon: Icons.tag,
            tooltip: 'Редактировать хештеги',
            onPressed: () => _editHashtags(provider),
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    Color color = Colors.black,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
      ),
    );
  }

  void _changeAvatar(ChannelStateProvider provider) {
    final currentAvatar = provider.getAvatarForChannel(widget.channel.id.toString());
    final controller = TextEditingController(text: currentAvatar ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сменить аватарку'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Превью аватарки
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey, width: 2),
                ),
                child: ClipOval(
                  child: controller.text.isNotEmpty
                      ? Image.network(
                    controller.text,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                          child: Icon(Icons.error, color: Colors.red));
                    },
                  )
                      : const Center(child: Icon(Icons.person, size: 40)),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'URL новой аватарки',
                  hintText: 'https://example.com/avatar.jpg',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  // Обновляем превью при изменении текста
                  if (mounted) setState(() {});
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Рекомендуемый размер: 200x200 px',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final newAvatarUrl = controller.text.trim();
              if (newAvatarUrl.isNotEmpty) {
                provider.setAvatarForChannel(widget.channel.id.toString(), newAvatarUrl);
                widget.onAvatarChanged?.call(newAvatarUrl);
                _updateCurrentAvatar(provider); // ОБНОВЛЯЕМ ТЕКУЩУЮ АВАТАРКУ
              }
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
          TextButton(
            onPressed: () {
              provider.setAvatarForChannel(widget.channel.id.toString(), null);
              widget.onAvatarChanged?.call('');
              _updateCurrentAvatar(provider); // ОБНОВЛЯЕМ ТЕКУЩУЮ АВАТАРКУ
              Navigator.pop(context);
            },
            child: const Text('Сбросить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _changeCoverImage(ChannelStateProvider provider) {
    final currentCover = provider.getCoverForChannel(widget.channel.id.toString());
    final controller = TextEditingController(text: currentCover ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сменить обложку'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'URL новой обложки',
                  hintText: 'https://example.com/cover.jpg',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  // Обновляем состояние для превью
                  if (mounted) setState(() {});
                },
              ),
              const SizedBox(height: 16),
              if (controller.text.isNotEmpty)
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      controller.text,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, color: Colors.red),
                              SizedBox(height: 8),
                              Text('Не удалось загрузить изображение',
                                  style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final newCoverUrl = controller.text.trim();
              provider.setCoverForChannel(
                widget.channel.id.toString(),
                newCoverUrl.isNotEmpty ? newCoverUrl : null,
              );
              widget.onCoverChanged?.call(newCoverUrl);
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _editHashtags(ChannelStateProvider provider) {
    final currentHashtags = provider.getHashtagsForChannel(widget.channel.id.toString());
    final tempHashtags = List<String>.from(currentHashtags);
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Редактировать хештеги'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            labelText: 'Новый хештег',
                            hintText: 'flutter',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (value) {
                            _addHashtag(value, tempHashtags, setDialogState, controller);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.blue),
                        iconSize: 32,
                        onPressed: () {
                          _addHashtag(controller.text, tempHashtags, setDialogState, controller);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (tempHashtags.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          children: tempHashtags.map((tag) {
                            return Chip(
                              label: Text('#$tag'),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () {
                                setDialogState(() {
                                  tempHashtags.remove(tag);
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () {
                  provider.setHashtagsForChannel(widget.channel.id.toString(), tempHashtags);
                  widget.onHashtagsChanged?.call(tempHashtags);
                  Navigator.pop(context);
                },
                child: const Text('Сохранить'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _addHashtag(String value, List<String> tempHashtags, StateSetter setDialogState, TextEditingController controller) {
    if (value.trim().isNotEmpty) {
      final newTag = value.trim().replaceAll('#', '');
      if (newTag.isNotEmpty && !tempHashtags.contains(newTag)) {
        setDialogState(() {
          tempHashtags.add(newTag);
        });
      }
      controller.clear();
    }
  }
}