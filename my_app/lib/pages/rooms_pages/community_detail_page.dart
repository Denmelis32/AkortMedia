// community_detail_page.dart - НОВАЯ версия для сообществ
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../chat/chat_page.dart';
import '../communities/models/community.dart';
import 'models/room.dart';

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
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _communityTabs = ['Комнаты', 'Участники', 'Информация', 'События'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _communityTabs.length,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openChatPage(Room room) {
    final userProvider = context.read<UserProvider>();

    if (!userProvider.isLoggedIn) {
      _showLoginRequiredDialog();
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ОК'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(Room room) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: room.getRoomIcon(size: 40),
        title: Text(
          room.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(room.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.people_rounded, size: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)),
                const SizedBox(width: 4),
                Text(
                  '${room.currentParticipants}/${room.maxParticipants}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.chat_rounded, size: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)),
                const SizedBox(width: 4),
                Text(
                  room.messageCount.formatCount(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: room.isJoined
            ? IconButton(
          icon: const Icon(Icons.exit_to_app_rounded),
          onPressed: () {
            // Покинуть комнату
            setState(() {
              // Обновить состояние комнаты
            });
          },
        )
            : ElevatedButton(
          onPressed: () {
            // Присоединиться к комнате
            setState(() {
              // Обновить состояние комнаты
            });
          },
          child: const Text('Войти'),
        ),
        onTap: () => _openChatPage(room),
      ),
    );
  }

  Widget _buildCommunityInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              widget.community.getCommunityIcon(size: 60),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.community.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.community.category,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.community.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: widget.community.tags.map((tag) => Chip(
              label: Text('#$tag'),
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            )).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                icon: Icons.people_rounded,
                value: widget.community.formattedMemberCount,
                label: 'участников',
              ),
              _buildStatItem(
                icon: Icons.chat_rounded,
                value: widget.community.rooms.length.toString(),
                label: 'комнат',
              ),
              _buildStatItem(
                icon: Icons.online_prediction_rounded,
                value: widget.community.onlineCount.toString(),
                label: 'онлайн',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String value, required String label}) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_tabController.index) {
      case 0: // Комнаты
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: widget.community.rooms.length,
          itemBuilder: (context, index) => _buildRoomCard(widget.community.rooms[index]),
        );
      case 1: // Участники
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_alt_rounded, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Участники сообщества', style: TextStyle(fontSize: 18)),
            ],
          ),
        );
      case 2: // Информация
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_rounded, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Информация о сообществе', style: TextStyle(fontSize: 18)),
            ],
          ),
        );
      case 3: // События
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_rounded, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('События сообщества', style: TextStyle(fontSize: 18)),
            ],
          ),
        );
      default:
        return const Center(child: Text('Содержимое вкладки'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.community.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              // Поделиться сообществом
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {
              // Дополнительные действия
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _communityTabs.map((tab) => Tab(text: tab)).toList(),
          isScrollable: true,
        ),
      ),
      body: Column(
        children: [
          // Информация о сообществе
          _buildCommunityInfo(),
          // Разделитель
          Container(
            height: 1,
            color: Theme.of(context).dividerColor,
          ),
          // Контент вкладок
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _communityTabs.map((_) => _buildTabContent()).toList(),
            ),
          ),
        ],
      ),
    );
  }
}