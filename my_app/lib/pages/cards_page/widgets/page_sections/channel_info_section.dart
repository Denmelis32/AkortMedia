import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/channel_detail_provider.dart';
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(),
          const SizedBox(height: 20),
          _buildDescription(context),
          const SizedBox(height: 24),
          _buildChannelStats(context),
          const SizedBox(height: 16),
          _buildAdditionalInfo(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: channel.cardColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: channel.cardColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: channel.cardColor),
              const SizedBox(width: 6),
              Text(
                'ИНФОРМАЦИЯ О КАНАЛЕ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: channel.cardColor,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        _buildEditButton(),
      ],
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
    return state.isEditingDescription
        ? _buildDescriptionEditor()
        : _buildDescriptionViewer(context);
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
                  // Здесь можно добавить сохранение в базу данных
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

  Widget _buildChannelStats(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          _buildStatRow(
            context,
            Icons.people_alt_rounded,
            'Подписчики',
            _formatNumber(channel.subscribers),
            Colors.blue,
          ),
          const Divider(height: 20),
          _buildStatRow(
            context,
            Icons.video_library_rounded,
            'Видео',
            _formatNumber(channel.videos),
            Colors.green,
          ),
          const Divider(height: 20),
          _buildStatRow(
            context,
            Icons.calendar_today_rounded,
            'Создан',
            _formatDate(channel.createdAt),
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, IconData icon, String title, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
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
        _buildInfoChip(channel.categoryName, Icons.category_rounded, Colors.grey[600]!),
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

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${_getRussianWord(years, ['год', 'года', 'лет'])} назад';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${_getRussianWord(months, ['месяц', 'месяца', 'месяцев'])} назад';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${_getRussianWord(difference.inDays, ['день', 'дня', 'дней'])} назад';
    }

    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _getRussianWord(int number, List<String> words) {
    if (number % 10 == 1 && number % 100 != 11) {
      return words[0];
    } else if (number % 10 >= 2 && number % 10 <= 4 && (number % 100 < 10 || number % 100 >= 20)) {
      return words[1];
    } else {
      return words[2];
    }
  }
}