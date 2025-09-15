// lib/pages/cards_page/channel_detail_page.dart
import 'package:flutter/material.dart';
import 'models/channel.dart';

class Video {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String channelName;
  final int views;
  final Duration duration;
  final DateTime publishedAt;

  Video({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.channelName,
    required this.views,
    required this.duration,
    required this.publishedAt,
  });
}

class ChannelDetailPage extends StatelessWidget {
  final Channel channel;

  const ChannelDetailPage({super.key, required this.channel});

  String _formatViews(int views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    }
    return views.toString();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return "$hours:$minutes:$seconds";
    }
    return "$minutes:$seconds";
  }

  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} лет назад';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} месяцев назад';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} дней назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} часов назад';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} минут назад';
    }
    return 'Только что';
  }

  @override
  Widget build(BuildContext context) {
    final List<Video> videos = [
      Video(
        id: '1',
        title: 'Новейшие технологии 2024: что нас ждет?',
        thumbnailUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400',
        channelName: channel.title,
        views: 125000,
        duration: const Duration(minutes: 15, seconds: 30),
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Video(
        id: '2',
        title: 'Обзор нового iPhone 15 Pro Max',
        thumbnailUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400',
        channelName: channel.title,
        views: 89000,
        duration: const Duration(minutes: 22, seconds: 45),
        publishedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Video(
        id: '3',
        title: 'Искусственный интеллект в повседневной жизни',
        thumbnailUrl: 'https://images.unsplash.com/photo-1677442135135-416f8aa26a5b?w=400',
        channelName: channel.title,
        views: 156000,
        duration: const Duration(minutes: 18, seconds: 20),
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Video(
        id: '4',
        title: 'Будущее VR технологий - что ожидать?',
        thumbnailUrl: 'https://images.unsplash.com/photo-1593118247619-e2d6f056869e?w=400',
        channelName: channel.title,
        views: 78000,
        duration: const Duration(minutes: 25, seconds: 10),
        publishedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Заголовок с обложкой канала
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            floating: false,
            snap: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      channel.cardColor.withOpacity(0.9),
                      channel.cardColor.withOpacity(0.7),
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Фоновое изображение с размытием
                    Positioned.fill(
                      child: Image.network(
                        channel.imageUrl,
                        fit: BoxFit.cover,
                        color: Colors.black.withOpacity(0.2),
                        colorBlendMode: BlendMode.darken,
                      ),
                    ),
                    // Затемнение градиента
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                    // Контент заголовка
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Аватар канала
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.8),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.network(
                                channel.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Название канала
                          Text(
                            channel.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 12,
                                  color: Colors.black,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          // Статистика канала
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildStatItem(
                                icon: Icons.people_outline,
                                value: '${channel.subscribers}',
                                label: 'подписчиков',
                              ),
                              const SizedBox(width: 20),
                              _buildStatItem(
                                icon: Icons.video_library_outlined,
                                value: '${channel.videos}',
                                label: 'видео',
                              ),
                              const SizedBox(width: 20),
                              _buildStatItem(
                                icon: Icons.visibility_outlined,
                                value: '2.5M',
                                label: 'просмотров',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Основной контент
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Описание канала
                  _buildDescriptionSection(),
                  const SizedBox(height: 24),

                  // Кнопки действий
                  _buildActionButtons(),
                  const SizedBox(height: 32),

                  // Вкладки
                  _buildTabSection(),
                  const SizedBox(height: 24),

                  // Заголовок видео
                  _buildVideoHeader(),
                ],
              ),
            ),
          ),

          // Список видео
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final video = videos[index];
                return _buildVideoItem(video, context);
              },
              childCount: videos.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String value, required String label}) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 6,
                color: Colors.black,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
            shadows: [
              Shadow(
                blurRadius: 4,
                color: Colors.black,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'О КАНАЛЕ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            channel.description,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          // Дополнительная информация
          _buildInfoRow(Icons.calendar_today, 'Создан: 15 марта 2022'),
          _buildInfoRow(Icons.location_on, 'Россия, Москва'),
          _buildInfoRow(Icons.link, 'www.example.com'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: channel.cardColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              shadowColor: channel.cardColor.withOpacity(0.3),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add_alt_1, size: 20),
                SizedBox(width: 8),
                Text(
                  'ПОДПИСАТЬСЯ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Кнопка уведомлений
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, size: 24),
            color: Colors.grey[700],
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Кнопка меню
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, size: 24),
            color: Colors.grey[700],
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton('Видео', true),
          ),
          Expanded(
            child: _buildTabButton('Сообщества', false),
          ),
          Expanded(
            child: _buildTabButton('Плейлисты', false),
          ),
          Expanded(
            child: _buildTabButton('Информация', false),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, bool isActive) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isActive ? channel.cardColor : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: TextButton(
        onPressed: () {},
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? channel.cardColor : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildVideoHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'ПОСЛЕДНИЕ ВИДЕО',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          'Смотреть все',
          style: TextStyle(
            fontSize: 14,
            color: Colors.blue,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoItem(Video video, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Превью видео
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  video.thumbnailUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              // Длительность видео
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _formatDuration(video.duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Индикатор просмотра
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: channel.cardColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'НОВОЕ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Информация о видео
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок видео
                Text(
                  video.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Статистика видео
                Row(
                  children: [
                    // Просмотры
                    _buildVideoStat(Icons.visibility_outlined, '${_formatViews(video.views)} просмотров'),
                    const SizedBox(width: 16),
                    // Дата публикации
                    _buildVideoStat(Icons.calendar_today, _timeAgo(video.publishedAt)),
                  ],
                ),
                const SizedBox(height: 12),

                // Прогресс-бар (имитация)
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.7, // 70% просмотрено
                    child: Container(
                      decoration: BoxDecoration(
                        color: channel.cardColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}