import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../../../providers/channel_provider/channel_state_provider.dart';
import '../../models/channel.dart';

class ChannelHeader extends StatelessWidget {
  final Channel channel;
  final VoidCallback? onSearch;
  final VoidCallback? onShare;
  final VoidCallback? onOptions;
  final bool showAppBarTitle;

  const ChannelHeader({
    super.key,
    required this.channel,
    this.onSearch,
    this.onShare,
    this.onOptions,
    this.showAppBarTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ChannelStateProvider>(
      builder: (context, provider, child) {
        return Stack(
          children: [
            // УДАЛЕНО: обложка канала и градиенты

            // ТОЛЬКО APP BAR
            _buildAppBar(context),
          ],
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : _getHorizontalPadding(context),
          vertical: 8,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Кнопка назад
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Назад',
            ),

            const SizedBox(width: 8),

            // Заголовок
            Text(
              'Канал',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Spacer(),

            // Кнопки действий
            Row(
              children: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.search, color: Colors.black, size: 18),
                  ),
                  onPressed: onSearch,
                  tooltip: 'Поиск',
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.share, color: Colors.black, size: 18),
                  ),
                  onPressed: onShare,
                  tooltip: 'Поделиться',
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.more_vert, color: Colors.black, size: 18),
                  ),
                  onPressed: onOptions,
                  tooltip: 'Опции',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1000) return 280;
    if (width > 700) return 80;
    return 16;
  }

// УДАЛЕНО: все методы связанные с обложкой (_buildCoverImage, _buildDefaultBackground, _buildCoverGradient, _buildBackgroundGradient)
}