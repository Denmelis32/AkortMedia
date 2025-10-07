import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/channel.dart';

class ChannelHeader extends StatefulWidget {
  final Channel channel;
  final List<String> initialHashtags;
  final String? initialCoverImageUrl;
  final String? initialAvatarUrl; // НОВОЕ: кастомный аватар
  final bool editable;

  const ChannelHeader({
    super.key,
    required this.channel,
    this.initialHashtags = const [],
    this.initialCoverImageUrl,
    this.initialAvatarUrl, // НОВОЕ: кастомный аватар
    this.editable = false,
  });

  @override
  State<ChannelHeader> createState() => _ChannelHeaderState();
}

class _ChannelHeaderState extends State<ChannelHeader> {
  late List<String> _hashtags;
  late String? _coverImageUrl;
  late String? _avatarUrl; // НОВОЕ: состояние аватарки
  final TextEditingController _hashtagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _hashtags = List.from(widget.initialHashtags);
    _coverImageUrl = widget.initialCoverImageUrl;
    _avatarUrl = widget.initialAvatarUrl ?? widget.channel.imageUrl; // По умолчанию из канала
  }

  @override
  Widget build(BuildContext context) {
    final allHashtags = [...widget.channel.tags, ..._hashtags];

    return Stack(
      children: [
        // ОБЛОЖКА КАНАЛА
        _buildCoverImage(),
        _buildCoverGradient(),

        // Градиент поверх фона
        _buildBackgroundGradient(),

        // Контент заголовка (АВАТАРКА И ХЕШТЕГИ ВНИЗУ ПО ЦЕНТРУ)
        _buildContent(allHashtags),

        // КНОПКИ РЕДАКТИРОВАНИЯ СПРАВА СНИЗУ (3 КНОПКИ)
        if (widget.editable) _buildEditButtons(),
      ],
    );
  }

  Widget _buildCoverImage() {
    return Positioned.fill(
      child: _coverImageUrl != null
          ? CachedNetworkImage(
        imageUrl: _coverImageUrl!,
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
          stops: [0.0, 0.3, 0.5, 0.7, 1.0],
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

  Widget _buildContent(List<String> allHashtags) {
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
            // АВАТАРКА С ВОЗМОЖНОСТЬЮ РЕДАКТИРОВАНИЯ
            _buildAvatar(),
            const SizedBox(height: 12),

            // Название канала
            _buildTitle(),
            const SizedBox(height: 8),

            // ХЕШТЕГИ ПО ЦЕНТРУ
            if (allHashtags.isNotEmpty) _buildHashtags(allHashtags),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
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
            child: _avatarUrl != null
                ? CachedNetworkImage(
              imageUrl: _avatarUrl!,
              placeholder: (context, url) => _buildAvatarPlaceholder(),
              errorWidget: (context, url, error) => _buildAvatarPlaceholder(),
              fit: BoxFit.cover,
            )
                : _buildAvatarPlaceholder(),
          ),
        ),

        // ИНДИКАТОР РЕДАКТИРОВАНИЯ (если включено)
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
    print('🟡 CHANNEL HEADER: Building hashtags for ${widget.channel.title}');
    print('🟡 CHANNEL HEADER Hashtags input: $hashtags');

    // Очищаем хештеги от лишних решеток
    final cleanedHashtags = hashtags
        .map((tag) => tag.replaceAll('#', '').trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    print('🟡 CHANNEL HEADER Cleaned hashtags: $cleanedHashtags');

    if (cleanedHashtags.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        alignment: WrapAlignment.center,
        children: cleanedHashtags.map((tag) {
          final displayTag = '#$tag';
          print('🟡 CHANNEL HEADER Creating widget for: $displayTag');

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

  // КНОПКИ РЕДАКТИРОВАНИЯ СПРАВА СНИЗУ (3 КНОПКИ)
  Widget _buildEditButtons() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Кнопка смены аватарки
          _buildEditButton(
            icon: Icons.person,
            tooltip: 'Сменить аватарку',
            onPressed: _changeAvatar,
            color: Colors.purple,
          ),
          const SizedBox(height: 8),
          // Кнопка смены обложки
          _buildEditButton(
            icon: Icons.photo,
            tooltip: 'Сменить обложку',
            onPressed: _changeCoverImage,
            color: Colors.green,
          ),
          const SizedBox(height: 8),
          // Кнопка редактирования хештегов
          _buildEditButton(
            icon: Icons.tag,
            tooltip: 'Редактировать хештеги',
            onPressed: _editHashtags,
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

  // МЕТОД РЕДАКТИРОВАНИЯ АВАТАРКИ
  void _changeAvatar() {
    final controller = TextEditingController(text: _avatarUrl ?? '');

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
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Icon(Icons.error));
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
                  // Можно добавить live-preview если нужно
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
              if (controller.text.isNotEmpty) {
                setState(() {
                  _avatarUrl = controller.text;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _avatarUrl = null; // Сброс к стандартному аватару
              });
              Navigator.pop(context);
            },
            child: const Text('Сбросить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _changeCoverImage() {
    final controller = TextEditingController(text: _coverImageUrl ?? '');

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
              ),
              const SizedBox(height: 16),
              if (controller.text.isNotEmpty)
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                    image: DecorationImage(
                      image: NetworkImage(controller.text),
                      fit: BoxFit.cover,
                      onError: (error, stackTrace) {
                        // Игнорируем ошибки загрузки превью
                      },
                    ),
                  ),
                  child: controller.text.isEmpty
                      ? const Center(child: Text('Введите URL'))
                      : null,
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
              setState(() {
                _coverImageUrl = controller.text.isNotEmpty ? controller.text : null;
              });
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _editHashtags() {
    final tempHashtags = List<String>.from(_hashtags);
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
                            if (value.trim().isNotEmpty) {
                              final newTag = value.trim();
                              if (!tempHashtags.contains(newTag)) {
                                setDialogState(() {
                                  tempHashtags.add(newTag);
                                });
                              }
                              controller.clear();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.blue),
                        iconSize: 32,
                        onPressed: () {
                          if (controller.text.trim().isNotEmpty) {
                            final newTag = controller.text.trim();
                            if (!tempHashtags.contains(newTag)) {
                              setDialogState(() {
                                tempHashtags.add(newTag);
                              });
                            }
                            controller.clear();
                          }
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
                  setState(() {
                    _hashtags = List.from(tempHashtags);
                  });
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
}