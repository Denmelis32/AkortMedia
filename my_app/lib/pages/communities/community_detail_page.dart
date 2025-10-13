import 'package:flutter/material.dart';
import 'package:my_app/pages/communities/widgets/shared/community_header.dart';
import 'package:provider/provider.dart';
import 'models/community.dart'; // Создадим этот виджет
import 'package:my_app/providers/community_state_provider.dart';

class CommunityDetailPage extends StatefulWidget {
  final Community community;

  const CommunityDetailPage({super.key, required this.community});

  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  Color _getAppBarColor() {
    final progress = _scrollOffset.clamp(0, 200) / 200;
    return Color.lerp(
      Colors.transparent,
      widget.community.cardColor.withOpacity(0.95),
      progress,
    )!;
  }

  double _getAppBarElevation() {
    return _scrollOffset > 100 ? 4.0 : 0.0;
  }

  bool _showAppBarTitle() {
    return _scrollOffset > 150;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F5F5),
              Color(0xFFE8E8E8),
            ],
          ),
        ),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          slivers: [
            // AppBar с обложкой
            SliverAppBar(
              expandedHeight: 280,
              flexibleSpace: FlexibleSpaceBar(
                background: CommunityHeader(
                  community: widget.community,
                  editable: true, // или false в зависимости от прав
                  onAvatarChanged: (newAvatarUrl) {
                    final stateProvider = Provider.of<CommunityStateProvider>(context, listen: false);
                    stateProvider.setAvatarForCommunity(
                        widget.community.id.toString(),
                        newAvatarUrl.isEmpty ? null : newAvatarUrl
                    );
                  },
                  onCoverChanged: (newCoverUrl) {
                    final stateProvider = Provider.of<CommunityStateProvider>(context, listen: false);
                    stateProvider.setCoverForCommunity(
                        widget.community.id.toString(),
                        newCoverUrl.isEmpty ? null : newCoverUrl
                    );
                  },
                  onHashtagsChanged: (newHashtags) {
                    final stateProvider = Provider.of<CommunityStateProvider>(context, listen: false);
                    stateProvider.setHashtagsForCommunity(
                        widget.community.id.toString(),
                        newHashtags
                    );
                  },
                ),
                title: AnimatedOpacity(
                  opacity: _showAppBarTitle() ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    widget.community.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                centerTitle: true,
              ),
              backgroundColor: _getAppBarColor(),
              elevation: _getAppBarElevation(),
              automaticallyImplyLeading: false,
              pinned: true,
              floating: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Назад',
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.white),
                  onPressed: () {
                    // Добавить в избранное
                  },
                  tooltip: 'Добавить в избранное',
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {
                    // Поделиться
                  },
                  tooltip: 'Поделиться',
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {
                    // Опции
                  },
                  tooltip: 'Опции',
                ),
              ],
            ),

            // Контент сообщества
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Основная информация
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.community.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.community.description,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Статистика
                            Row(
                              children: [
                                _buildStatItem('Участники', Icons.people, '${widget.community.membersCount}'),
                                const SizedBox(width: 20),
                                _buildStatItem('Посты', Icons.chat, '${widget.community.postsCount}'),
                                const Spacer(),
                                if (widget.community.isPrivate)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.lock, size: 16, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Приватное',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Теги
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Теги сообщества',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: widget.community.tags.map((tag) {
                                return Chip(
                                  label: Text('#$tag'),
                                  backgroundColor: widget.community.cardColor.withOpacity(0.1),
                                  labelStyle: TextStyle(
                                    color: widget.community.cardColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Кнопки действий
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Вступить в сообщество
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: widget.community.cardColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                icon: const Icon(Icons.group_add),
                                label: const Text('Вступить в сообщество'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: () {
                                // Настройки уведомлений
                              },
                              icon: const Icon(Icons.notifications_none),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                padding: const EdgeInsets.all(12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, IconData icon, String value) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}