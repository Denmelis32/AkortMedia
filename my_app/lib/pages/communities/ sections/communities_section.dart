// widgets/sections/communities_section.dart
import 'package:flutter/material.dart';
import '../models/community.dart';

class CommunitiesSection extends StatefulWidget {
  final List<Community> communities;
  final Function(Community) onCommunityTap;
  final VoidCallback onCreateCommunity;
  final Function(Community)? onJoinCommunity;
  final Function(Community)? onLeaveCommunity;

  const CommunitiesSection({
    super.key,
    required this.communities,
    required this.onCommunityTap,
    required this.onCreateCommunity,
    this.onJoinCommunity,
    this.onLeaveCommunity,
  });

  @override
  State<CommunitiesSection> createState() => _CommunitiesSectionState();
}

class _CommunitiesSectionState extends State<CommunitiesSection> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  String _searchQuery = '';
  CommunityFilter _currentFilter = CommunityFilter.all;

  List<Community> get _filteredCommunities {
    var filtered = widget.communities;

    // Применяем поиск
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((community) =>
      community.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          community.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          community.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase())) ||
          community.category.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Применяем фильтры
    switch (_currentFilter) {
      case CommunityFilter.popular:
        filtered = filtered.where((c) => c.isPopular).toList();
        break;
      case CommunityFilter.growing:
        filtered = filtered.where((c) => c.isGrowing).toList();
        break;
      case CommunityFilter.active:
        filtered = filtered.where((c) => c.isActive).toList();
        break;
      case CommunityFilter.verified:
        filtered = filtered.where((c) => c.isVerified).toList();
        break;
      case CommunityFilter.joined:
        filtered = filtered.where((c) => c.isUserMember).toList();
        break;
      case CommunityFilter.all:
      default:
        break;
    }

    return filtered;
  }

  List<Community> get _featuredCommunities {
    return _filteredCommunities
        .where((c) => c.isPopular || c.isVerified)
        .take(6)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCommunities = _filteredCommunities;
    final featuredCommunities = _featuredCommunities;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Расширяемый заголовок с поиском
        SliverAppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          expandedHeight: _isSearching ? 100 : 160,
          floating: true,
          pinned: true,
          snap: true,
          flexibleSpace: FlexibleSpaceBar(
            background: _buildHeader(context),
            collapseMode: CollapseMode.pin,
          ),
        ),

        // Быстрые действия и фильтры
        SliverToBoxAdapter(
          child: _buildQuickActionsAndFilters(context),
        ),

        // Рекомендуемые сообщества (только если есть результаты)
        if (featuredCommunities.isNotEmpty && _currentFilter == CommunityFilter.all)
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              context: context,
              title: '🌟 Рекомендуемые',
              subtitle: 'Популярные и проверенные сообщества',
              showAction: true,
              onAction: () {
                setState(() {
                  _currentFilter = CommunityFilter.popular;
                });
              },
            ),
          ),

        if (featuredCommunities.isNotEmpty && _currentFilter == CommunityFilter.all)
          SliverToBoxAdapter(
            child: _buildFeaturedCommunities(context, featuredCommunities),
          ),

        // Результаты поиска/фильтрации
        SliverToBoxAdapter(
          child: _buildResultsHeader(context, filteredCommunities),
        ),

        // Список сообществ
        if (filteredCommunities.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final community = filteredCommunities[index];
                return _buildCommunityCard(community, context);
              },
              childCount: filteredCommunities.length,
            ),
          )
        else
        // Пустое состояние
          SliverToBoxAdapter(
            child: _buildEmptyState(context),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isSearching
                ? _buildSearchField(context)
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Сообщества',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Найдите сообщества по вашим интересам',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatsOverview(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      decoration: InputDecoration(
        hintText: 'Поиск сообществ...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchQuery = '';
              _searchController.clear();
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      onSubmitted: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  Widget _buildStatsOverview(BuildContext context) {
    final totalCommunities = widget.communities.length;
    final joinedCommunities = widget.communities.where((c) => c.isUserMember).length;
    final popularCommunities = widget.communities.where((c) => c.isPopular).length;

    return Row(
      children: [
        _buildStatChip(
          icon: Icons.people_alt_rounded,
          value: totalCommunities.toString(),
          label: 'Всего',
          color: Colors.blue,
          context: context,
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          icon: Icons.group_rounded,
          value: joinedCommunities.toString(),
          label: 'Ваши',
          color: Colors.green,
          context: context,
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          icon: Icons.trending_up_rounded,
          value: popularCommunities.toString(),
          label: 'Популярные',
          color: Colors.orange,
          context: context,
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 2),
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

  Widget _buildQuickActionsAndFilters(BuildContext context) {
    return Column(
      children: [
        // Быстрые действия
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context: context,
                  icon: Icons.add_rounded,
                  title: 'Создать',
                  subtitle: 'Новое сообщество',
                  color: Theme.of(context).primaryColor,
                  onTap: widget.onCreateCommunity,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context: context,
                  icon: Icons.search_rounded,
                  title: 'Поиск',
                  subtitle: 'Найти сообщества',
                  color: Colors.orange,
                  onTap: () {
                    setState(() {
                      _isSearching = true;
                      _searchFocusNode.requestFocus();
                    });
                  },
                ),
              ),
            ],
          ),
        ),

        // Фильтры
        _buildFilterChips(context),
      ],
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: CommunityFilter.values.map((filter) {
          final isSelected = _currentFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _currentFilter = selected ? filter : CommunityFilter.all;
                });
              },
              label: Text(filter.title),
              avatar: Icon(filter.icon, size: 16),
              backgroundColor: Theme.of(context).colorScheme.surface,
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.1),
              checkmarkColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Theme.of(context).primaryColor : null,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    required String subtitle,
    bool showAction = false,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          if (showAction && onAction != null)
            TextButton(
              onPressed: onAction,
              child: const Text('Смотреть все'),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCommunities(BuildContext context, List<Community> featuredCommunities) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: (featuredCommunities.length / 2).ceil(),
        padEnds: false,
        controller: PageController(viewportFraction: 0.85),
        itemBuilder: (context, pageIndex) {
          final startIndex = pageIndex * 2;
          final endIndex = startIndex + 2;
          final pageCommunities = featuredCommunities.sublist(
            startIndex,
            endIndex < featuredCommunities.length ? endIndex : featuredCommunities.length,
          );

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: pageCommunities.map((community) {
                return Expanded(
                  child: _buildFeaturedCommunityCard(community, context),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedCommunityCard(Community community, BuildContext context) {
    final categoryColor = _getCategoryColor(community.category);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => widget.onCommunityTap(community),
          child: Stack(
            children: [
              // Градиентный фон
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      categoryColor.withOpacity(0.15),
                      categoryColor.withOpacity(0.05),
                    ],
                  ),
                ),
              ),

              // Контент
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Верхняя часть - аватар и название
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            community.getCommunityIcon(size: 40),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    community.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    community.category,
                                    style: TextStyle(
                                      color: categoryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          community.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    // Нижняя часть - статистика и кнопка
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.people_rounded,
                                      size: 12,
                                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
                                  const SizedBox(width: 4),
                                  Text(
                                    community.formattedMemberCount,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${community.onlineCount} онлайн',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildFeaturedJoinButton(community, context),
                      ],
                    ),
                  ],
                ),
              ),

              // Бейджи
              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  children: [
                    ...community.buildBadges(compact: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsHeader(BuildContext context, List<Community> communities) {
    String title;
    String subtitle;

    if (_searchQuery.isNotEmpty) {
      title = 'Результаты поиска';
      subtitle = 'Найдено ${communities.length} сообществ';
    } else if (_currentFilter != CommunityFilter.all) {
      title = _currentFilter.title;
      subtitle = '${communities.length} сообществ';
    } else {
      title = 'Все сообщества';
      subtitle = '${communities.length} сообществ';
    }

    return _buildSectionHeader(
      context: context,
      title: title,
      subtitle: subtitle,
    );
  }

  Widget _buildCommunityCard(Community community, BuildContext context) {
    final categoryColor = _getCategoryColor(community.category);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => widget.onCommunityTap(community),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Аватар сообщества с анимацией
              Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: community.getCommunityIcon(size: 60),
                  ),
                  if (community.isUserMember)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Информация
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                community.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                community.category,
                                style: TextStyle(
                                  color: categoryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...community.buildBadges(compact: true),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      community.description,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Теги и статистика
                    Wrap(
                      spacing: 6,
                      children: [
                        ...community.tags.take(2).map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#$tag',
                            style: TextStyle(
                              fontSize: 10,
                              color: categoryColor,
                            ),
                          ),
                        )),
                        if (community.tags.length > 2)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '+${community.tags.length - 2}',
                              style: TextStyle(
                                fontSize: 10,
                                color: categoryColor.withOpacity(0.6),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatItem(
                          icon: Icons.people_rounded,
                          value: community.formattedMemberCount,
                          label: 'участников',
                          context: context,
                        ),
                        _buildStatItem(
                          icon: Icons.chat_rounded,
                          value: community.rooms.length.toString(),
                          label: 'комнат',
                          context: context,
                        ),
                        _buildStatItem(
                          icon: Icons.online_prediction_rounded,
                          value: community.onlineCount.toString(),
                          label: 'онлайн',
                          context: context,
                        ),
                        const Spacer(),
                        _buildJoinButton(community, context),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
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
              Icon(icon,
                  size: 12,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)),
              const SizedBox(width: 2),
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

  Widget _buildFeaturedJoinButton(Community community, BuildContext context) {
    return GestureDetector(
      onTap: () => community.isUserMember
          ? widget.onLeaveCommunity?.call(community)
          : widget.onJoinCommunity?.call(community),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: community.isUserMember
              ? Colors.green.withOpacity(0.1)
              : Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
          border: community.isUserMember
              ? Border.all(color: Colors.green)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              community.isUserMember ? Icons.check_rounded : Icons.add_rounded,
              size: 14,
              color: community.isUserMember ? Colors.green : Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              community.isUserMember ? 'В сообществе' : 'Присоединиться',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: community.isUserMember ? Colors.green : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinButton(Community community, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: OutlinedButton(
        onPressed: () => community.isUserMember
            ? widget.onLeaveCommunity?.call(community)
            : widget.onJoinCommunity?.call(community),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          side: BorderSide(
            color: community.isUserMember
                ? Colors.green
                : Theme.of(context).primaryColor,
          ),
          backgroundColor: community.isUserMember
              ? Colors.green.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Text(
          community.isUserMember ? 'Вы в сообществе' : 'Присоединиться',
          style: TextStyle(
            fontSize: 12,
            color: community.isUserMember
                ? Colors.green
                : Theme.of(context).primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Сообщества не найдены',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Попробуйте изменить поисковый запрос или сбросить фильтры'
                : 'Попробуйте изменить фильтры или создать новое сообщество',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _searchController.clear();
                _currentFilter = CommunityFilter.all;
                _isSearching = false;
              });
            },
            child: const Text('Сбросить фильтры'),
          ),
        ],
      ),
    );
  }

  // Публичный метод для получения цвета категории
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'технологии':
        return Colors.blue;
      case 'игры':
        return Colors.purple;
      case 'социальное':
        return Colors.green;
      case 'путешествия':
        return Colors.orange;
      case 'образование':
        return Colors.teal;
      case 'бизнес':
        return Colors.indigo;
      case 'искусство':
        return Colors.pink;
      case 'музыка':
        return Colors.deepPurple;
      case 'наука':
        return Colors.blueGrey;
      case 'спорт':
        return Colors.red;
      case 'программирование':
        return Colors.blueAccent;
      case 'дизайн':
        return Colors.pinkAccent;
      case 'фотография':
        return Colors.amber;
      case 'кулинария':
        return Colors.deepOrange;
      case 'здоровье':
        return Colors.lightGreen;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}

// Перечисление для фильтров
enum CommunityFilter {
  all('Все', Icons.all_inclusive_rounded),
  popular('Популярные', Icons.trending_up_rounded),
  growing('Растущие', Icons.arrow_upward_rounded),
  active('Активные', Icons.flash_on_rounded),
  verified('Проверенные', Icons.verified_rounded),
  joined('Ваши', Icons.group_rounded);

  final String title;
  final IconData icon;

  const CommunityFilter(this.title, this.icon);
}