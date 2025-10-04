// community_detail_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../chat/chat_page.dart';
import '../communities/models/community.dart';
import 'models/room.dart';
import '../communities/utils/community_navigation.dart';

class CommunityDetailPage extends StatefulWidget {
  final Community community;
  final int initialTab;

  const CommunityDetailPage({
    super.key,
    required this.community,
    required this.initialTab,
  });

  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  final List<String> _communityTabs = ['Комнаты', 'Участники', 'Информация', 'События'];
  final CommunityNavigation _navigation = CommunityNavigation();
  final ScrollController _scrollController = ScrollController();
  final Map<String, bool> _expandedRooms = {};

  late Community _currentCommunity; // Изменяемая копия community
  double _scrollOffset = 0;
  bool _showJoinButton = true;

  @override
  void initState() {
    super.initState();
    _currentCommunity = widget.community; // Инициализируем копией
    _tabController = TabController(
      length: _communityTabs.length,
      vsync: this,
      initialIndex: widget.initialTab,
    );

    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addObserver(this);

    // Инициализация состояния расширения комнат
    for (final room in _currentCommunity.rooms) {
      _expandedRooms[room.id] = false;
    }
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

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  void _toggleRoomExpansion(String roomId) {
    setState(() {
      _expandedRooms[roomId] = !(_expandedRooms[roomId] ?? false);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ChatPage(
          room: room,
          userName: userProvider.userName,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutQuart;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
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
      _currentCommunity = _currentCommunity.copyWith(
        isUserMember: true,
        memberCount: _currentCommunity.memberCount + 1,
        onlineCount: _currentCommunity.onlineCount + 1,
      );
      _showJoinButton = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Вы присоединились к сообществу "${_currentCommunity.name}" 🎉'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Отлично!',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
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

  Widget _buildRoomCard(Room room) {
    final isExpanded = _expandedRooms[room.id] ?? false;
    final participantsPercentage = room.maxParticipants > 0
        ? room.currentParticipants / room.maxParticipants
        : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openChatPage(room),
          onLongPress: () => _toggleRoomExpansion(room.id),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок и иконка
                Row(
                  children: [
                    Stack(
                      children: [
                        room.getRoomIcon(size: 50),
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            room.description,
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                              fontSize: 14,
                            ),
                            maxLines: isExpanded ? null : 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _buildRoomStatusBadge(room),
                  ],
                ),

                const SizedBox(height: 12),

                // Статистика комнаты
                Row(
                  children: [
                    _buildRoomStat(
                      icon: Icons.people_rounded,
                      value: '${room.currentParticipants}/${room.maxParticipants}',
                      label: 'участников',
                      context: context,
                    ),
                    _buildRoomStat(
                      icon: Icons.chat_rounded,
                      value: NumberFormatting(room.messageCount).formatCount(),
                      label: 'сообщений',
                      context: context,
                    ),
                    _buildRoomStat(
                      icon: Icons.schedule_rounded,
                      value: room.createdAt.timeAgo(),
                      label: 'создана',
                      context: context,
                    ),
                  ],
                ),

                // Прогресс бар заполненности (только если есть ограничение)
                if (room.maxParticipants > 0) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: participantsPercentage,
                    backgroundColor: Colors.grey[300],
                    color: participantsPercentage > 0.8 ? Colors.orange : Colors.green,
                    minHeight: 4,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Заполнено на ${(participantsPercentage * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                ],

                // Дополнительная информация (при расширении)
                if (isExpanded) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Темы обсуждения:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: room.tags.take(5).map((tag) => Chip(
                      label: Text('#$tag'),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )).toList(),
                  ),
                ],

                const SizedBox(height: 8),

                // Кнопка действия
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        room.isJoined ? 'Вы в комнате' : 'Присоединиться к обсуждению',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                    ),
                    _buildRoomActionButton(room),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomStat({
    required IconData icon,
    required String value,
    required String label,
    required BuildContext context,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                ),
              ),
            ],
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomActionButton(Room room) {
    if (room.isJoined) {
      return OutlinedButton.icon(
        onPressed: () {
          setState(() {
            // TODO: Обновить состояние комнаты
          });
        },
        icon: const Icon(Icons.exit_to_app_rounded, size: 16),
        label: const Text('Выйти'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
    } else if (room.currentParticipants >= room.maxParticipants && room.maxParticipants > 0) {
      return OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.person_off_rounded, size: 16),
        label: const Text('Заполнена'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
    } else {
      return ElevatedButton.icon(
        onPressed: () {
          setState(() {
            // TODO: Обновить состояние комнаты
            _openChatPage(room);
          });
        },
        icon: const Icon(Icons.login_rounded, size: 16),
        label: const Text('Войти'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
    }
  }

  Widget _buildCommunityHeader() {
    final isPinned = _scrollOffset > 100;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: isPinned ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ] : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Аватар сообщества
                Stack(
                  children: [
                    _currentCommunity.getCommunityIcon(size: 70),
                    if (_currentCommunity.isVerified)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.verified_rounded, size: 14, color: Colors.white),
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
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_currentCommunity.canManage)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue),
                              ),
                              child: const Text(
                                'Управление',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _currentCommunity.categoryIcon,
                            size: 14,
                            color: _currentCommunity.categoryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _currentCommunity.category,
                            style: TextStyle(
                              color: _currentCommunity.categoryColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
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

            const SizedBox(height: 12),

            // Описание
            Text(
              _currentCommunity.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.4,
              ),
            ),

            const SizedBox(height: 12),

            // Теги
            if (_currentCommunity.tags.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                children: _currentCommunity.tags.map((tag) => GestureDetector(
                  onTap: () {
                    // TODO: Поиск по тегу
                  },
                  child: Chip(
                    label: Text('#$tag'),
                    backgroundColor: _currentCommunity.categoryColor.withOpacity(0.1),
                    labelStyle: TextStyle(color: _currentCommunity.categoryColor),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Статистика и кнопки
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _buildCommunityStat(
                        value: _currentCommunity.formattedMemberCount,
                        label: 'участников',
                        icon: Icons.people_rounded,
                      ),
                      _buildCommunityStat(
                        value: _currentCommunity.rooms.length.toString(),
                        label: 'комнат',
                        icon: Icons.chat_rounded,
                      ),
                      _buildCommunityStat(
                        value: _currentCommunity.onlineCount.toString(),
                        label: 'онлайн',
                        icon: Icons.online_prediction_rounded,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (_showJoinButton)
                  ElevatedButton.icon(
                    onPressed: _joinCommunity,
                    icon: const Icon(Icons.group_add_rounded),
                    label: const Text('Присоединиться'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  )
                else if (_currentCommunity.isUserMember)
                  OutlinedButton.icon(
                    onPressed: _leaveCommunity,
                    icon: const Icon(Icons.exit_to_app_rounded),
                    label: const Text('Покинуть'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityStat({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Theme.of(context).primaryColor),
              const SizedBox(width: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
        ],
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
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '${_currentCommunity.memberCount} участников',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
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
          // Основная информация
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'О сообществе',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
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
            ),
          ),

          const SizedBox(height: 16),

          // Статистика
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Статистика',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      _buildStatCard(
                        value: NumberFormatting(_currentCommunity.stats.totalMessages).formatCount(),
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
            ),
          ),

          // Правила
          if (_currentCommunity.rules != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.rule_rounded, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          'Правила сообщества',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(_currentCommunity.rules!),
                  ],
                ),
              ),
            ),
          ],

          // Приветственное сообщение
          if (_currentCommunity.welcomeMessage != null) ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.green.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.waving_hand_rounded, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Приветствие',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(_currentCommunity.welcomeMessage!),
                  ],
                ),
              ),
            ),
          ],
        ],
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
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? Theme.of(context).textTheme.bodyMedium?.color,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
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
    if (_currentCommunity.events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_rounded, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'События сообщества',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Здесь будут отображаться предстоящие события',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Создать событие
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Создать событие'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _currentCommunity.events.length,
      itemBuilder: (context, index) {
        final event = _currentCommunity.events[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.event_rounded, color: Colors.blue),
            ),
            title: Text(event.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.description),
                const SizedBox(height: 4),
                Text(
                  '${event.startTime.day}.${event.startTime.month}.${event.startTime.year} • ${event.participants} участников',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: event.isUpcoming ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                event.isUpcoming ? 'Предстоит' : 'Завершено',
                style: TextStyle(
                  fontSize: 10,
                  color: event.isUpcoming ? Colors.green : Colors.grey,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabContent() {
    switch (_tabController.index) {
      case 0: // Комнаты
        return _currentCommunity.rooms.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_rounded, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Пока нет комнат',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Будьте первым, кто создаст комнату для общения',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Создать комнату
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Создать комнату'),
              ),
            ],
          ),
        )
            : ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(top: 8),
          itemCount: _currentCommunity.rooms.length,
          itemBuilder: (context, index) => _buildRoomCard(_currentCommunity.rooms[index]),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _scrollOffset > 100 ? 1.0 : 0.0,
          child: Text(_currentCommunity.name),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _navigation.shareCommunity(context, _currentCommunity),
            tooltip: 'Поделиться',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'info':
                  _navigation.openCommunityDetail(
                    context: context,
                    community: _currentCommunity,
                    selectedTab: 2,
                  );
                  break;
                case 'report':
                  _navigation.reportCommunity(context, _currentCommunity);
                  break;
                case 'settings':
                // TODO: Переход к настройкам сообщества
                  break;
                case 'invite':
                // TODO: Пригласить друзей
                  break;
              }
            },
            itemBuilder: (context) => [
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
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _communityTabs.map((tab) => Tab(text: tab)).toList(),
          isScrollable: true,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // Заголовок сообщества
          _buildCommunityHeader(),
          // Контент вкладок
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _communityTabs.map((_) => _buildTabContent()).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: _currentCommunity.isUserMember
          ? FloatingActionButton(
        onPressed: () {
          // TODO: Создать комнату
        },
        child: const Icon(Icons.add_rounded),
      )
          : null,
    );
  }
}

// Расширения для форматирования
extension NumberFormatting on int {
  String formatCount() {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }
}

extension DateFormatting on DateTime {
  String timeAgo() {
    final now = DateTime.now();
    final difference = now.difference(this);

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
}