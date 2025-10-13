import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../../providers/channel_detail_provider.dart';
import '../../../../providers/channel_state_provider.dart';
import '../../models/channel.dart';
import '../../models/channel_detail_state.dart';

class ChannelInfoSection extends StatelessWidget {
  final Channel channel;
  final ChannelDetailProvider provider;
  final ChannelDetailState state;

  const ChannelInfoSection({
    super.key,
    required this.channel,
    required this.provider,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ChannelStateProvider>(
      builder: (context, stateProvider, child) {
        final avatarUrl = stateProvider.getAvatarForChannel(channel.id.toString());
        final coverUrl = stateProvider.getCoverForChannel(channel.id.toString());
        final hashtags = stateProvider.getHashtagsForChannel(channel.id.toString());

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ОБЛОЖКА КАНАЛА
              _buildCoverImage(context, coverUrl, stateProvider),

              // ОСНОВНОЙ КОНТЕНТ
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // АВАТАРКА И НАЗВАНИЕ
                    _buildAvatarAndTitle(context, avatarUrl, stateProvider),
                    const SizedBox(height: 20),

                    // ОПИСАНИЕ
                    _buildDescription(context),
                    const SizedBox(height: 20),

                    // ХЕШТЕГИ
                    _buildHashtagsSection(context, hashtags, stateProvider),
                    const SizedBox(height: 16),

                    // ДОПОЛНИТЕЛЬНАЯ ИНФОРМАЦИЯ
                    _buildAdditionalInfo(context),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCoverImage(BuildContext context, String? coverUrl, ChannelStateProvider stateProvider) {
    return Stack(
      children: [
        Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            color: channel.cardColor.withOpacity(0.1),
          ),
          child: coverUrl != null && coverUrl.isNotEmpty
              ? ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: CachedNetworkImage(
              imageUrl: coverUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: channel.cardColor.withOpacity(0.3),
              ),
              errorWidget: (context, url, error) => _buildDefaultCover(),
            ),
          )
              : _buildDefaultCover(),
        ),
        Positioned(
          bottom: 12,
          right: 12,
          child: _buildEditIconButton(
            icon: Icons.photo,
            tooltip: 'Сменить обложку',
            onPressed: () => _changeCoverImage(context, stateProvider),
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultCover() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            channel.cardColor.withOpacity(0.6),
            channel.cardColor.withOpacity(0.3),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: const Center(
        child: Icon(Icons.photo_library, size: 50, color: Colors.white),
      ),
    );
  }

  Widget _buildAvatarAndTitle(BuildContext context, String? avatarUrl, ChannelStateProvider stateProvider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // АВАТАРКА
        Stack(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: channel.cardColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
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
            Positioned(
              bottom: 0,
              right: 0,
              child: _buildEditIconButton(
                icon: Icons.person,
                tooltip: 'Сменить аватарку',
                onPressed: () => _changeAvatar(context, stateProvider),
                color: Colors.purple,
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                channel.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                channel.categoryName,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildEditButton(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: channel.cardColor.withOpacity(0.2),
      child: Icon(Icons.person, color: channel.cardColor, size: 40),
    );
  }

  Widget _buildEditIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    Color color = Colors.black,
    double size = 24,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
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
        icon: Icon(icon, color: Colors.white, size: size - 4),
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildEditButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: state.isEditingDescription ? channel.cardColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: state.isEditingDescription ? Colors.transparent : channel.cardColor,
        ),
      ),
      child: IconButton(
        icon: Icon(
          state.isEditingDescription ? Icons.check_rounded : Icons.edit_rounded,
          size: 18,
          color: state.isEditingDescription ? Colors.white : channel.cardColor,
        ),
        onPressed: provider.toggleEditDescription,
        tooltip: state.isEditingDescription ? 'Сохранить описание' : 'Редактировать описание',
        padding: const EdgeInsets.all(6),
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Описание',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        state.isEditingDescription
            ? _buildDescriptionEditor()
            : _buildDescriptionViewer(context),
      ],
    );
  }

  Widget _buildDescriptionEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: provider.descriptionController,
          maxLines: 4,
          style: const TextStyle(fontSize: 15, height: 1.5),
          decoration: InputDecoration(
            hintText: 'Опишите ваш канал...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: channel.cardColor, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '${provider.descriptionController.text.length}/500',
              style: TextStyle(
                fontSize: 12,
                color: provider.descriptionController.text.length > 500
                    ? Colors.red
                    : Colors.grey[600],
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: provider.toggleEditDescription,
              child: const Text('Отмена'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (provider.descriptionController.text.length <= 500) {
                  provider.toggleEditDescription();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: channel.cardColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionViewer(BuildContext context) {
    final hasLongDescription = channel.description.length > 150;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            channel.description.isEmpty ? 'Описание канала пока не добавлено...' : channel.description,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
            ),
            maxLines: state.showFullDescription ? null : 3,
            overflow: state.showFullDescription ? null : TextOverflow.ellipsis,
          ),
          if (hasLongDescription && !state.isEditingDescription) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: provider.toggleDescription,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: channel.cardColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    state.showFullDescription ? 'Свернуть' : 'Читать далее',
                    style: TextStyle(
                      color: channel.cardColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHashtagsSection(BuildContext context, List<String> hashtags, ChannelStateProvider stateProvider) {
    final cleanedHashtags = hashtags
        .map((tag) => tag.replaceAll('#', '').trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Хештеги',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            _buildEditIconButton(
              icon: Icons.tag,
              tooltip: 'Редактировать хештеги',
              onPressed: () => _editHashtags(context, stateProvider),
              color: Colors.orange,
              size: 20,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (cleanedHashtags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: cleanedHashtags.map((tag) {
              final displayTag = '#$tag';
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: channel.cardColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: channel.cardColor.withOpacity(0.3)),
                ),
                child: Text(
                  displayTag,
                  style: TextStyle(
                    fontSize: 13,
                    color: channel.cardColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Center(
              child: Text(
                'Хештеги не добавлены',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAdditionalInfo(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (channel.isVerified) _buildInfoChip('Проверенный', Icons.verified_rounded, Colors.blue),
        if (channel.isLive) _buildInfoChip('В эфире', Icons.live_tv_rounded, Colors.red),
        if (channel.isPopular) _buildInfoChip('Популярный', Icons.trending_up_rounded, Colors.green),
        if (channel.isNew) _buildInfoChip('Новый', Icons.new_releases_rounded, Colors.orange),
        if (channel.isActive) _buildInfoChip('Активный', Icons.flash_on_rounded, Colors.purple),
      ],
    );
  }

  Widget _buildInfoChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // МЕТОДЫ ДЛЯ РЕДАКТИРОВАНИЯ
  void _changeAvatar(BuildContext context, ChannelStateProvider provider) {
    final currentAvatar = provider.getAvatarForChannel(channel.id.toString());
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
                provider.setAvatarForChannel(channel.id.toString(), newAvatarUrl);
              }
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
          TextButton(
            onPressed: () {
              provider.setAvatarForChannel(channel.id.toString(), null);
              Navigator.pop(context);
            },
            child: const Text('Сбросить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _changeCoverImage(BuildContext context, ChannelStateProvider provider) {
    final currentCover = provider.getCoverForChannel(channel.id.toString());
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
                channel.id.toString(),
                newCoverUrl.isNotEmpty ? newCoverUrl : null,
              );
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _editHashtags(BuildContext context, ChannelStateProvider provider) {
    final currentHashtags = provider.getHashtagsForChannel(channel.id.toString());
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
                  provider.setHashtagsForChannel(channel.id.toString(), tempHashtags);
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