import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_provider.dart';
import '../../chat/chat_page.dart';
import '../../rooms_pages/models/room.dart';
import '../utils/formatters.dart';

class RoomCard extends StatefulWidget {
  final Room room;
  final VoidCallback? onJoin;
  final VoidCallback? onLeave;
  final VoidCallback? onFavorite;
  final bool showCommunityInfo;

  const RoomCard({
    super.key,
    required this.room,
    this.onJoin,
    this.onLeave,
    this.onFavorite,
    this.showCommunityInfo = false,
  });

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  bool _isJoining = false;
  bool _isExpanded = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.room.favoriteCount > 0;
  }

  Future<void> _joinRoom() async {
    if (_isJoining || !widget.room.canJoin) return;

    setState(() {
      _isJoining = true;
    });

    // Имитация загрузки
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        _isJoining = false;
      });
      widget.onJoin?.call();
      _openChatPage();
    }
  }

  void _openChatPage() {
    final userProvider = context.read<UserProvider>();

    if (!userProvider.isLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          room: widget.room,
          userName: userProvider.userName,
        ),
      ),
    );
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Требуется вход'),
        content: const Text('Для участия в обсуждениях необходимо войти в систему.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Позже'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Навигация к экрану входа
            },
            child: const Text('Войти'),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    widget.onFavorite?.call();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Аватар комнаты с бейджами
        Stack(
          children: [
            // Основной аватар
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.room.roomColor.withOpacity(0.8),
                    widget.room.roomColor.withOpacity(0.4),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  widget.room.category.icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            // Бейдж проверенной комнаты
            if (widget.room.isVerified)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            // Бейдж приглашения
            if (widget.room.hasPendingInvite)
              Positioned(
                bottom: -4,
                left: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.pink,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),

        // Основная информация
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и статус
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.room.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildRoomStatus(),
                ],
              ),
              const SizedBox(height: 4),

              // Категория и язык
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.room.roomColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.room.category.icon,
                          size: 12,
                          color: widget.room.roomColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.room.category.title,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: widget.room.roomColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.room.language.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoomStatus() {
    Color color;
    String text;
    IconData icon;

    if (widget.room.isJoined) {
      color = Colors.green;
      text = 'Вы в комнате';
      icon = Icons.check_circle_rounded;
    } else if (widget.room.isFull) {
      color = Colors.red;
      text = 'Заполнена';
      icon = Icons.person_off_rounded;
    } else if (widget.room.participationRate > 0.8) {
      color = Colors.orange;
      text = 'Почти заполнена';
      icon = Icons.timer_rounded;
    } else if (widget.room.isScheduled) {
      color = Colors.blue;
      text = widget.room.formattedStartTime;
      icon = Icons.schedule_rounded;
    } else {
      color = Colors.blue;
      text = 'Свободно';
      icon = Icons.group_add_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        // Участники
        _buildStatItem(
          icon: Icons.people_rounded,
          value: '${widget.room.currentParticipants}',
          maxValue: widget.room.maxParticipants > 0 ? '/${widget.room.maxParticipants}' : '',
          label: 'участников',
          color: Colors.blue,
        ),

        // Сообщения
        _buildStatItem(
          icon: Icons.chat_rounded,
          value: Formatters.formatNumber(widget.room.messageCount),
          label: 'сообщений',
          color: Colors.green,
        ),

        // Активность
        _buildStatItem(
          icon: Icons.flash_on_rounded,
          value: widget.room.activityLevelText,
          label: 'активность',
          color: Colors.orange,
        ),

        // Рейтинг
        if (widget.room.rating > 0)
          _buildStatItem(
            icon: Icons.star_rounded,
            value: widget.room.rating.toStringAsFixed(1),
            label: 'рейтинг',
            color: Colors.amber,
          ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    String maxValue = '',
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                if (maxValue.isNotEmpty)
                  Text(
                    maxValue,
                    style: TextStyle(
                      fontSize: 10,
                      color: color.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    if (widget.room.maxParticipants <= 0) return const SizedBox();

    final percentage = widget.room.participationRate;
    Color color;

    if (percentage < 0.5) {
      color = Colors.green;
    } else if (percentage < 0.8) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey[300],
                color: color,
                borderRadius: BorderRadius.circular(4),
                minHeight: 6,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(percentage * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          percentage > 0.8
              ? 'Почти заполнена! Присоединяйтесь скорее!'
              : 'Есть свободные места',
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    if (!_isExpanded) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),

        // Теги
        if (widget.room.tags.isNotEmpty) ...[
          Text(
            'Теги для обсуждения:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: widget.room.tags.take(5).map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: widget.room.roomColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '#$tag',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: widget.room.roomColor,
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 12),
        ],

        // Дополнительные функции
        if (widget.room.hasVoiceChat || widget.room.hasVideoChat || widget.room.hasMedia)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Доступные функции:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  if (widget.room.hasVoiceChat)
                    _buildFeatureChip('Голосовой чат', Icons.mic_rounded, Colors.teal),
                  if (widget.room.hasVideoChat)
                    _buildFeatureChip('Видеочат', Icons.videocam_rounded, Colors.indigo),
                  if (widget.room.hasMedia)
                    _buildFeatureChip('Медиа', Icons.photo_library_rounded, Colors.purple),
                  if (widget.room.hasPolls)
                    _buildFeatureChip('Опросы', Icons.poll_rounded, Colors.blue),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),

        // Информация о создателе
        Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.grey[300],
              child: Icon(
                Icons.person_rounded,
                size: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Создатель: ${widget.room.creatorName}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Text(
              widget.room.formattedCreatedAt,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Информация о статусе
        Expanded(
          child: widget.room.isJoined
              ? Text(
            '🎉 Вы участвуете в этой комнате',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.green,
            ),
          )
              : Text(
            widget.room.hasPendingInvite
                ? '📩 Вас пригласили в эту комнату'
                : '💬 Присоединяйтесь к обсуждению',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Кнопка избранного
        IconButton(
          onPressed: _toggleFavorite,
          icon: Icon(
            _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: _isFavorite ? Colors.pink : Colors.grey,
            size: 20,
          ),
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(),
        ),

        const SizedBox(width: 8),

        // Основная кнопка действия
        _buildMainActionButton(),
      ],
    );
  }

  Widget _buildMainActionButton() {
    if (widget.room.isJoined) {
      return OutlinedButton(
        onPressed: _openChatPage,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Перейти в чат'),
      );
    } else if (widget.room.isFull) {
      return Tooltip(
        message: 'Комната полностью заполнена',
        child: OutlinedButton(
          onPressed: null,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Заполнена'),
        ),
      );
    } else if (_isJoining) {
      return SizedBox(
        width: 120,
        height: 36,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          ),
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: _joinRoom,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        child: Text(widget.room.hasPendingInvite ? 'Принять приглашение' : 'Войти в комнату'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _toggleExpand,
        onLongPress: () {
          // TODO: Показать меню дополнительных действий
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.room.roomColor.withOpacity(0.02),
                widget.room.roomColor.withOpacity(0.01),
                Colors.transparent,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                _buildHeader(),

                const SizedBox(height: 12),

                // Описание
                Text(
                  widget.room.description,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    height: 1.4,
                  ),
                  maxLines: _isExpanded ? null : 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Статистика
                _buildStatsRow(),

                const SizedBox(height: 12),

                // Прогресс заполненности
                if (widget.room.maxParticipants > 0) ...[
                  _buildProgressIndicator(),
                  const SizedBox(height: 12),
                ],

                // Расширенное содержимое
                _buildExpandedContent(),

                const SizedBox(height: 8),

                // Кнопки действий
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}