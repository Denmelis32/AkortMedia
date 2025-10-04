// community_detail_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../chat/chat_page.dart';
import 'models/community.dart';
import '../rooms_pages/models/room.dart';
import 'utils/community_navigation.dart';

class CommunityDetailPage extends StatefulWidget {
  final Community community;
  final int initialTab;

  const CommunityDetailPage({
    super.key,
    required this.community,
    this.initialTab = 0,
  });

  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  final List<String> _communityTabs = ['Комнаты', 'Участники', 'Информация', 'События'];
  final CommunityNavigation _navigation = CommunityNavigation();
  final ScrollController _scrollController = ScrollController();
  final Map<String, bool> _expandedRooms = {};
  final Map<String, bool> _joiningRooms = {};

  late Community _currentCommunity;
  double _scrollOffset = 0;
  bool _showJoinButton = true;
  bool _isLoading = false;
  bool _showAppBarTitle = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _currentCommunity = widget.community;

    _tabController = TabController(
      length: _communityTabs.length,
      vsync: this,
      initialIndex: widget.initialTab,
    );

    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addObserver(this);

    // Инициализация состояния
    for (final room in _currentCommunity.rooms) {
      _expandedRooms[room.id] = false;
      _joiningRooms[room.id] = false;
    }
  }

  void _onScroll() {
    final newShowTitle = _scrollController.offset > 200;
    if (newShowTitle != _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = newShowTitle;
      });
    }
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  void _toggleRoomExpansion(String roomId) {
    setState(() {
      _expandedRooms[roomId] = !(_expandedRooms[roomId] ?? false);
    });
  }

  Future<void> _joinRoom(Room room) async {
    if (_joiningRooms[room.id] == true) return;

    setState(() {
      _joiningRooms[room.id] = true;
    });

    // Имитация загрузки
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        _joiningRooms[room.id] = false;
        _openChatPage(room);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite
              ? 'Добавлено в избранное 💖'
              : 'Убрано из избранного',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _openChatPage(Room room) {
    final userProvider = context.read<UserProvider>();

    if (!userProvider.isLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }

    if (!_currentCommunity.isUserMember) {
      _showJoinRequiredDialog();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          room: room,
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
        icon: const Icon(Icons.login_rounded, size: 48, color: Colors.blue),
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

  void _showJoinRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Присоединитесь к сообществу'),
        content: Text('Чтобы участвовать в комнатах сообщества "${_currentCommunity.name}", необходимо стать его участником.'),
        icon: const Icon(Icons.group_add_rounded, size: 48, color: Colors.green),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _joinCommunity();
            },
            child: const Text('Присоединиться'),
          ),
        ],
      ),
    );
  }

  void _joinCommunity() {
    final userProvider = context.read<UserProvider>();
    if (!userProvider.isLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Имитация загрузки
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _currentCommunity = _currentCommunity.copyWith(
            isUserMember: true,
            memberCount: _currentCommunity.memberCount + 1,
            onlineCount: _currentCommunity.onlineCount + 1,
          );
          _showJoinButton = false;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Вы присоединились к сообществу "${_currentCommunity.name}" 🎉'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            action: SnackBarAction(
              label: 'Отлично!',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    });
  }

  void _leaveCommunity() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Покинуть сообщество'),
        content: Text('Вы уверены, что хотите покинуть сообщество "${_currentCommunity.name}"?'),
        icon: const Icon(Icons.exit_to_app_rounded, size: 48, color: Colors.orange),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentCommunity = _currentCommunity.copyWith(
                  isUserMember: false,
                  memberCount: _currentCommunity.memberCount - 1,
                  onlineCount: _currentCommunity.onlineCount - 1,
                );
                _showJoinButton = true;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Вы покинули сообщество "${_currentCommunity.name}"'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Покинуть'),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedRoomCard(Room room) {
    final isExpanded = _expandedRooms[room.id] ?? false;
    final isJoining = _joiningRooms[room.id] ?? false;
    final participantsPercentage = room.maxParticipants > 0
        ? room.currentParticipants / room.maxParticipants
        : 0.0;

    final roomColor = _getRoomColor(room);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                roomColor.withOpacity(0.05),
                roomColor.withOpacity(0.02),
                Colors.transparent,
              ],
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _openChatPage(room),
              onLongPress: () => _toggleRoomExpansion(room.id),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Заголовок комнаты
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Аватар комнаты
                        Stack(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  colors: [
                                    roomColor.withOpacity(0.3),
                                    roomColor.withOpacity(0.1),
                                  ],
                                ),
                              ),
                              child: Center(child: room.getRoomIcon(size: 30)),
                            ),
                            if (room.isJoined)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check_rounded, size: 12, color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),

                        // Информация о комнате
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      room.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        height: 1.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  _buildRoomStatusBadge(room),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                room.description,
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                                maxLines: isExpanded ? null : 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Статистика комнаты
                    Row(
                      children: [
                        _buildEnhancedRoomStat(
                          icon: Icons.people_rounded,
                          value: '${room.currentParticipants}',
                          maxValue: room.maxParticipants > 0 ? '/${room.maxParticipants}' : '',
                          label: 'участников',
                          color: roomColor,
                          context: context,
                        ),
                        _buildEnhancedRoomStat(
                          icon: Icons.chat_bubble_rounded,
                          value: _formatNumber(room.messageCount),
                          label: 'сообщений',
                          color: roomColor,
                          context: context,
                        ),
                        _buildEnhancedRoomStat(
                          icon: Icons.av_timer_rounded,
                          value: _formatTimeAgo(room.createdAt),
                          label: 'активна',
                          color: roomColor,
                          context: context,
                        ),
                      ],
                    ),

                    // Прогресс бар заполненности
                    if (room.maxParticipants > 0) ...[
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: participantsPercentage,
                                  backgroundColor: Colors.grey[300],
                                  color: _getProgressColor(participantsPercentage),
                                  borderRadius: BorderRadius.circular(4),
                                  minHeight: 6,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${(participantsPercentage * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            participantsPercentage > 0.8
                                ? 'Почти заполнена! Присоединяйтесь скорее!'
                                : 'Есть свободные места',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Расширенная информация
                    if (isExpanded) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      Text(
                        'Темы для обсуждения:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: room.tags.take(3).map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: roomColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '#$tag',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: roomColor,
                            ),
                          ),
                        )).toList(),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Кнопка действия
                    Row(
                      children: [
                        Expanded(
                          child: room.isJoined
                              ? Text(
                            '🎉 Вы участвуете в этой комнате',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.green,
                            ),
                          )
                              : Text(
                            '💬 Присоединяйтесь к обсуждению',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildEnhancedRoomActionButton(room, isJoining),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedRoomActionButton(Room room, bool isJoining) {
    if (room.isJoined) {
      return OutlinedButton.icon(
        onPressed: () {
          // TODO: Выйти из комнаты
        },
        icon: const Icon(Icons.exit_to_app_rounded, size: 16),
        label: const Text('Выйти'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else if (room.currentParticipants >= room.maxParticipants && room.maxParticipants > 0) {
      return Tooltip(
        message: 'Комната полностью заполнена',
        child: OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.person_off_rounded, size: 16),
          label: const Text('Заполнена'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    } else {
      return isJoining
          ? SizedBox(
        width: 120,
        height: 40,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          ),
        ),
      )
          : ElevatedButton.icon(
        onPressed: () => _joinRoom(room),
        icon: const Icon(Icons.login_rounded, size: 16),
        label: const Text('Войти в комнату'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
      );
    }
  }

  Widget _buildRoomStatusBadge(Room room) {
    Color color;
    String text;
    IconData icon;

    if (room.isJoined) {
      color = Colors.green;
      text = 'Вы в комнате';
      icon = Icons.check_circle_rounded;
    } else if (room.currentParticipants >= room.maxParticipants && room.maxParticipants > 0) {
      color = Colors.red;
      text = 'Заполнена';
      icon = Icons.person_off_rounded;
    } else if (room.currentParticipants > room.maxParticipants * 0.8) {
      color = Colors.orange;
      text = 'Почти заполнена';
      icon = Icons.timer_rounded;
    } else {
      color = Colors.blue;
      text = 'Свободно';
      icon = Icons.group_add_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
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

  Widget _buildEnhancedRoomStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required BuildContext context,
    String maxValue = '',
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                if (maxValue.isNotEmpty)
                  Text(
                    maxValue,
                    style: TextStyle(
                      fontSize: 11,
                      color: color.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoomColor(Room room) {
    if (room.isJoined) return Colors.green;
    if (room.currentParticipants >= room.maxParticipants && room.maxParticipants > 0) return Colors.red;
    if (room.currentParticipants > room.maxParticipants * 0.8) return Colors.orange;
    return Theme.of(context).primaryColor;
  }

  Color _getProgressColor(double percentage) {
    if (percentage > 0.8) return Colors.orange;
    if (percentage > 0.6) return Colors.yellow[700]!;
    return Colors.green;
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}г назад';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}мес назад';
    } else if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}н назад';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}д назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}ч назад';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}м назад';
    } else {
      return 'Только что';
    }
  }

  Widget _buildEnhancedCommunityHeader() {
    final categoryColor = _currentCommunity.categoryColor;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Верхняя часть с аватаром и основной информацией
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Аватар сообщества
                Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            categoryColor.withOpacity(0.3),
                            categoryColor.withOpacity(0.1),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: categoryColor.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(child: _currentCommunity.getCommunityIcon(size: 40)),
                    ),
                    if (_currentCommunity.isVerified)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.verified_rounded, size: 16, color: Colors.white),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),

                // Основная информация
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _currentCommunity.name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_currentCommunity.canManage)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.withOpacity(0.3)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.settings_rounded, size: 14, color: Colors.blue),
                                  SizedBox(width: 4),
                                  Text(
                                    'Управление',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _currentCommunity.categoryIcon,
                                  size: 14,
                                  color: categoryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _currentCommunity.category,
                                  style: TextStyle(
                                    color: categoryColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          ..._currentCommunity.buildBadges(compact: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Описание
            Text(
              _currentCommunity.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 16),

            // Теги
            if (_currentCommunity.tags.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _currentCommunity.tags.map((tag) => GestureDetector(
                  onTap: () {
                    // TODO: Поиск по тегу
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(
                        color: categoryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Статистика и кнопки
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildEnhancedCommunityStat(
                          value: _currentCommunity.formattedMemberCount,
                          label: 'Участников',
                          icon: Icons.people_rounded,
                          color: Colors.blue,
                        ),
                        _buildEnhancedCommunityStat(
                          value: _currentCommunity.rooms.length.toString(),
                          label: 'Комнат',
                          icon: Icons.chat_rounded,
                          color: Colors.green,
                        ),
                        _buildEnhancedCommunityStat(
                          value: _currentCommunity.onlineCount.toString(),
                          label: 'Онлайн',
                          icon: Icons.online_prediction_rounded,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (_showJoinButton)
                    ElevatedButton.icon(
                      onPressed: _joinCommunity,
                      icon: const Icon(Icons.group_add_rounded),
                      label: const Text('Присоединиться'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                    )
                  else if (_currentCommunity.isUserMember)
                    OutlinedButton.icon(
                      onPressed: _leaveCommunity,
                      icon: const Icon(Icons.exit_to_app_rounded),
                      label: const Text('Покинуть'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedCommunityStat({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded),
      onSelected: (value) {
        switch (value) {
          case 'info':
            _tabController.animateTo(2);
            break;
          case 'report':
            _navigation.reportCommunity(context, _currentCommunity);
            break;
          case 'settings':
          // TODO: Настройки сообщества
            break;
          case 'invite':
            _navigation.shareCommunity(context, _currentCommunity);
            break;
          case 'favorite':
            _toggleFavorite();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'favorite',
          child: Row(
            children: [
              Icon(
                _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: _isFavorite ? Colors.pink : null,
              ),
              const SizedBox(width: 8),
              Text(_isFavorite ? 'В избранном' : 'В избранное'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'info',
          child: Row(
            children: [
              Icon(Icons.info_rounded, size: 20),
              SizedBox(width: 8),
              Text('Информация'),
            ],
          ),
        ),
        if (_currentCommunity.canManage)
          const PopupMenuItem(
            value: 'settings',
            child: Row(
              children: [
                Icon(Icons.settings_rounded, size: 20),
                SizedBox(width: 8),
                Text('Управление'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'invite',
          child: Row(
            children: [
              Icon(Icons.person_add_rounded, size: 20),
              SizedBox(width: 8),
              Text('Пригласить'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'report',
          child: Row(
            children: [
              Icon(Icons.report_rounded, size: 20),
              SizedBox(width: 8),
              Text('Пожаловаться'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent() {
    switch (_tabController.index) {
      case 0: // Комнаты
        return _buildRoomsTab();
      case 1: // Участники
        return _buildMembersTab();
      case 2: // Информация
        return _buildInfoTab();
      case 3: // События
        return _buildEventsTab();
      default:
        return const Center(child: Text('Содержимое вкладки'));
    }
  }

  Widget _buildRoomsTab() {
    if (_currentCommunity.rooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_rounded, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Пока нет комнат',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Будьте первым, кто создаст комнату для общения в этом сообществе',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                _createNewRoom();
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Создать комнату'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      itemCount: _currentCommunity.rooms.length,
      itemBuilder: (context, index) => _buildEnhancedRoomCard(_currentCommunity.rooms[index]),
    );
  }

  void _createNewRoom() {
    if (!_currentCommunity.isUserMember) {
      _showJoinRequiredDialog();
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Создать новую комнату',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Создайте пространство для общения в сообществе',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Center(
                  child: Text(
                    'Форма создания комнаты\n(в разработке)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMembersTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_alt_rounded, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Участники сообщества',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              '${_currentCommunity.memberCount} участников',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // TODO: Показать всех участников
            },
            child: const Text('Показать всех участников'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            title: 'О сообществе',
            icon: Icons.info_rounded,
            color: Colors.blue,
            children: [
              _buildInfoRow(
                icon: Icons.person_rounded,
                title: 'Создатель',
                value: _currentCommunity.creatorName,
              ),
              _buildInfoRow(
                icon: Icons.calendar_today_rounded,
                title: 'Создано',
                value: _currentCommunity.formattedCreatedAt,
              ),
              _buildInfoRow(
                icon: Icons.category_rounded,
                title: 'Категория',
                value: _currentCommunity.category,
              ),
              _buildInfoRow(
                icon: Icons.flag_rounded,
                title: 'Уровень',
                value: _currentCommunity.levelName,
                valueColor: _currentCommunity.levelColor,
              ),
            ],
          ),

          const SizedBox(height: 20),

          _buildInfoSection(
            title: 'Статистика',
            icon: Icons.analytics_rounded,
            color: Colors.green,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildStatCard(
                    value: _formatNumber(_currentCommunity.stats.totalMessages),
                    label: 'Всего сообщений',
                    icon: Icons.chat_rounded,
                    color: Colors.blue,
                  ),
                  _buildStatCard(
                    value: _currentCommunity.stats.dailyActiveUsers.toString(),
                    label: 'Активных сегодня',
                    icon: Icons.trending_up_rounded,
                    color: Colors.green,
                  ),
                  _buildStatCard(
                    value: '${(_currentCommunity.stats.weeklyGrowth * 100).toStringAsFixed(1)}%',
                    label: 'Рост за неделю',
                    icon: Icons.arrow_upward_rounded,
                    color: Colors.orange,
                  ),
                  _buildStatCard(
                    value: _currentCommunity.stats.roomsCreated.toString(),
                    label: 'Создано комнат',
                    icon: Icons.room_rounded,
                    color: Colors.purple,
                  ),
                ],
              ),
            ],
          ),

          if (_currentCommunity.rules != null) ...[
            const SizedBox(height: 20),
            _buildInfoSection(
              title: 'Правила сообщества',
              icon: Icons.rule_rounded,
              color: Colors.orange,
              children: [
                Text(
                  _currentCommunity.rules!,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],

          if (_currentCommunity.welcomeMessage != null) ...[
            const SizedBox(height: 20),
            _buildInfoSection(
              title: 'Приветствие',
              icon: Icons.waving_hand_rounded,
              color: Colors.green,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.1)),
                  ),
                  child: Text(
                    _currentCommunity.welcomeMessage!,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_rounded, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'События сообщества',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Здесь будут отображаться предстоящие события и мероприятия сообщества',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              _createNewEvent();
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Создать событие'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _createNewEvent() {
    if (!_currentCommunity.isUserMember) {
      _showJoinRequiredDialog();
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Создать новое событие',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Организуйте мероприятие для участников сообщества',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Center(
                  child: Text(
                    'Форма создания события\n(в разработке)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkUserMembership();
  }

  void _checkUserMembership() {
    final userProvider = context.read<UserProvider>();
    setState(() {
      _showJoinButton = !_currentCommunity.isUserMember && userProvider.isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _showAppBarTitle
              ? Text(
            _currentCommunity.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          )
              : const SizedBox.shrink(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _navigation.shareCommunity(context, _currentCommunity),
            tooltip: 'Поделиться',
          ),
          _buildCommunityMenu(),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _communityTabs.map((tab) => Tab(text: tab)).toList(),
          isScrollable: true,
        ),
      ),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: _buildEnhancedCommunityHeader(),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Комнаты
            _currentCommunity.rooms.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_rounded, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Пока нет комнат',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Будьте первым, кто создаст комнату для общения в этом сообществе',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      _createNewRoom();
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Создать комнату'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 20),
              itemCount: _currentCommunity.rooms.length,
              itemBuilder: (context, index) => _buildEnhancedRoomCard(_currentCommunity.rooms[index]),
            ),
            // Участники
            _buildMembersTab(),
            // Информация
            _buildInfoTab(),
            // События
            _buildEventsTab(),
          ],
        ),
      ),
      floatingActionButton: _currentCommunity.isUserMember
          ? FloatingActionButton(
        onPressed: () {
          _createNewRoom();
        },
        child: const Icon(Icons.add_rounded),
      )
          : null,
    );
  }
}