// widgets/sections/communities_section.dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/community.dart';

// Добавляем enum для фильтров
enum CommunityFilter {
  all('Все', Icons.all_inclusive_rounded),
  popular('Популярные', Icons.trending_up_rounded),
  growing('Растущие', Icons.arrow_upward_rounded),
  active('Активные', Icons.flash_on_rounded),
  verified('Проверенные', Icons.verified_rounded),
  joined('Мои сообщества', Icons.group_rounded),
  newest('Новые', Icons.new_releases_rounded),
  trending('В тренде', Icons.local_fire_department_rounded);

  const CommunityFilter(this.title, this.icon);
  final String title;
  final IconData icon;
}

// Добавляем enum для режимов просмотра
enum CommunityViewMode {
  grid,
  list,
}

class CommunitiesSection extends StatefulWidget {
  final List<Community> communities;
  final Function(Community) onCommunityTap;
  final VoidCallback onCreateCommunity;
  final Function(Community)? onJoinCommunity;
  final Function(Community)? onLeaveCommunity;
  final VoidCallback? onExploreMore;

  const CommunitiesSection({
    super.key,
    required this.communities,
    required this.onCommunityTap,
    required this.onCreateCommunity,
    this.onJoinCommunity,
    this.onLeaveCommunity,
    this.onExploreMore,
  });

  @override
  State<CommunitiesSection> createState() => _CommunitiesSectionState();
}

class _CommunitiesSectionState extends State<CommunitiesSection>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _isSearching = false;
  String _searchQuery = '';
  CommunityFilter _currentFilter = CommunityFilter.all;
  CommunityViewMode _viewMode = CommunityViewMode.grid;
  Set<String> _expandedCards = {};
  double _scrollOffset = 0;

  // AI рекомендации на основе поведения пользователя
  List<Community> get _aiRecommendedCommunities {
    final userCommunities = widget.communities.where((c) => c.isUserMember).toList();
    final userCategories = userCommunities.map((c) => c.category).toSet();

    return widget.communities
        .where((community) {
      // Приоритет: похожие категории, но не присоединенные
      final categoryMatch = userCategories.contains(community.category);
      final notJoined = !community.isUserMember;
      final isPopular = community.isPopular;

      return notJoined && (categoryMatch || isPopular);
    })
        .take(4)
        .toList();
  }

  List<Community> get _trendingCommunities {
    return widget.communities
        .where((c) => c.isGrowing && c.stats.weeklyGrowth > 0.2)
        .take(6)
        .toList();
  }

  List<Community> get _filteredCommunities {
    var filtered = widget.communities;

    // Поиск
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((community) =>
      community.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          community.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          community.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase())) ||
          community.category.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Фильтры
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
      case CommunityFilter.newest:
        filtered = filtered..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case CommunityFilter.trending:
        filtered = _trendingCommunities;
        break;
      case CommunityFilter.all:
      default:
        break;
    }

    return filtered;
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _scrollController.addListener(_onScroll);

    // Запуск анимации после построения
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  void _toggleCardExpansion(String communityId) {
    setState(() {
      if (_expandedCards.contains(communityId)) {
        _expandedCards.remove(communityId);
      } else {
        _expandedCards.add(communityId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredCommunities = _filteredCommunities;
    final aiRecommended = _aiRecommendedCommunities;
    final trending = _trendingCommunities;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          _animationController.forward();
        }
        return false;
      },
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Анимированный заголовок с параллакс эффектом
          SliverAppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            expandedHeight: 200,
            floating: true,
            pinned: true,
            snap: true,
            elevation: _scrollOffset > 50 ? 4 : 0,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildAnimatedHeader(context),
              collapseMode: CollapseMode.pin,
            ),
          ),

          // Быстрые действия с анимацией
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _buildQuickActions(context),
              ),
            ),
          ),

          // AI рекомендации
          if (aiRecommended.isNotEmpty && _currentFilter == CommunityFilter.all)
            _buildAISection(context, aiRecommended),

          // Трендовые сообщества
          if (trending.isNotEmpty && _currentFilter == CommunityFilter.all)
            _buildTrendingSection(context, trending),

          // Переключатель вида и фильтры
          SliverToBoxAdapter(
            child: _buildViewControls(context),
          ),

          // Результаты
          SliverToBoxAdapter(
            child: _buildResultsHeader(context, filteredCommunities),
          ),

          // Сетка или список сообществ
          if (filteredCommunities.isNotEmpty)
            _viewMode == CommunityViewMode.grid
                ? _buildGridLayout(filteredCommunities)
                : _buildListLayout(filteredCommunities)
          else
          // Анимированное пустое состояние
            SliverToBoxAdapter(
              child: _buildAnimatedEmptyState(context),
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeader(BuildContext context) {
    return AnimatedBuilder(
      animation: _scrollController,
      builder: (context, child) {
        final opacity = 1.0 - (_scrollOffset / 100).clamp(0.0, 1.0);
        final scale = 1.0 + (_scrollOffset / 500).clamp(0.0, 0.3);

        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Сообщества',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Откройте мир общения по интересам',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _isSearching
                      ? _buildSearchField(context)
                      : _buildInteractiveStats(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInteractiveStats(BuildContext context) {
    final total = widget.communities.length;
    final joined = widget.communities.where((c) => c.isUserMember).length;
    final popular = widget.communities.where((c) => c.isPopular).length;

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _buildAnimatedStatCard(
          icon: Icons.people_alt_rounded,
          value: total.toString(),
          label: 'Сообществ',
          color: Colors.blue,
          context: context,
        ),
        _buildAnimatedStatCard(
          icon: Icons.group_rounded,
          value: joined.toString(),
          label: 'Ваши',
          color: Colors.green,
          context: context,
        ),
        _buildAnimatedStatCard(
          icon: Icons.trending_up_rounded,
          value: popular.toString(),
          label: 'Популярные',
          color: Colors.orange,
          context: context,
        ),
        _buildAnimatedStatCard(
          icon: Icons.auto_awesome_rounded,
          value: _aiRecommendedCommunities.length.toString(),
          label: 'Для вас',
          color: Colors.purple,
          context: context,
        ),
      ],
    );
  }

  Widget _buildAnimatedStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required BuildContext context,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
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
        hintText: 'Поиск по сообществам, тегам, интересам...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
              ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
            ),
          ],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        filled: true,
      ),
      onChanged: (value) => setState(() => _searchQuery = value),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildActionButton(
            icon: Icons.add_rounded,
            label: 'Создать',
            color: Theme.of(context).primaryColor,
            onTap: widget.onCreateCommunity,
          ),
          _buildActionButton(
            icon: Icons.search_rounded,
            label: 'Поиск',
            color: Colors.orange,
            onTap: () => setState(() {
              _isSearching = true;
              _searchFocusNode.requestFocus();
            }),
          ),
          _buildActionButton(
            icon: Icons.auto_awesome_rounded,
            label: 'AI Подбор',
            color: Colors.purple,
            onTap: _showAIRecommendations,
          ),
          if (widget.onExploreMore != null)
            _buildActionButton(
              icon: Icons.explore_rounded,
              label: 'Исследовать',
              color: Colors.teal,
              onTap: widget.onExploreMore!,
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      color: color.withOpacity(0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildAISection(BuildContext context, List<Community> recommendations) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          _buildSectionHeader(
            context: context,
            title: '🤖 Рекомендуем именно вам',
            subtitle: 'На основе ваших интересов и активности',
            showAction: true,
            actionText: 'Еще',
            onAction: _showAIRecommendations,
          ),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                final community = recommendations[index];
                return _buildAIRecommendedCard(community, context, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIRecommendedCard(Community community, BuildContext context, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      width: 280,
      margin: EdgeInsets.only(
        right: 12,
        left: index == 0 ? 0 : 0,
      ),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            // Градиентный фон с анимацией
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getCategoryColor(community.category).withOpacity(0.3),
                    _getCategoryColor(community.category).withOpacity(0.1),
                  ],
                ),
              ),
            ),

            // Контент
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      community.getCommunityIcon(size: 40),
                      const SizedBox(width: 12),
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
                                color: _getCategoryColor(community.category),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildAIMatchIndicator(community, context),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: Text(
                      community.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _buildStatChip(
                        icon: Icons.people_rounded,
                        value: community.formattedMemberCount,
                        context: context,
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        icon: Icons.trending_up_rounded,
                        value: '${(community.stats.weeklyGrowth * 100).toStringAsFixed(0)}%',
                        context: context,
                      ),
                      const Spacer(),
                      _buildSmartJoinButton(community, context),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIMatchIndicator(Community community, BuildContext context) {
    final matchScore = _calculateAIMatchScore(community);

    return Tooltip(
      message: 'Совпадение интересов: ${(matchScore * 100).toInt()}%',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.purple),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded, size: 12, color: Colors.purple),
            const SizedBox(width: 4),
            Text(
              '${(matchScore * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateAIMatchScore(Community community) {
    // Упрощенный алгоритм матчинга
    double score = 0.0;

    // Совпадение категории
    final userCategories = widget.communities
        .where((c) => c.isUserMember)
        .map((c) => c.category)
        .toSet();

    if (userCategories.contains(community.category)) {
      score += 0.4;
    }

    // Популярность
    if (community.isPopular) score += 0.3;

    // Активность
    if (community.isActive) score += 0.2;

    // Рост
    if (community.isGrowing) score += 0.1;

    return score.clamp(0.0, 1.0);
  }

  SliverToBoxAdapter _buildTrendingSection(BuildContext context, List<Community> trending) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          _buildSectionHeader(
            context: context,
            title: '🚀 В тренде',
            subtitle: 'Самые быстрорастущие сообщества',
            showAction: true,
            actionText: 'Все тренды',
            onAction: () => setState(() => _currentFilter = CommunityFilter.trending),
          ),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: trending.length,
              itemBuilder: (context, index) {
                final community = trending[index];
                return _buildTrendingCard(community, context, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingCard(Community community, BuildContext context, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200 + (index * 50)),
      width: 200,
      margin: EdgeInsets.only(right: 12, left: index == 0 ? 0 : 0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => widget.onCommunityTap(community),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Stack(
                  children: [
                    community.getCommunityIcon(size: 40),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.trending_up_rounded, size: 8, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        community.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+${(community.stats.weeklyGrowth * 100).toStringAsFixed(0)}% за неделю',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Переключатель вида
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Row(
              children: [
                _buildViewModeButton(
                  mode: CommunityViewMode.grid,
                  icon: Icons.grid_view_rounded,
                  label: 'Сетка',
                ),
                _buildViewModeButton(
                  mode: CommunityViewMode.list,
                  icon: Icons.view_list_rounded,
                  label: 'Список',
                ),
              ],
            ),
          ),

          const Spacer(),

          // Фильтры
          PopupMenuButton<CommunityFilter>(
            onSelected: (filter) => setState(() => _currentFilter = filter),
            itemBuilder: (context) => CommunityFilter.values.map((filter) {
              return PopupMenuItem(
                value: filter,
                child: Row(
                  children: [
                    Icon(filter.icon, size: 18),
                    const SizedBox(width: 8),
                    Text(filter.title),
                  ],
                ),
              );
            }).toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.filter_list_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text(_currentFilter.title),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeButton({
    required CommunityViewMode mode,
    required IconData icon,
    required String label,
  }) {
    final isActive = _viewMode == mode;

    return Material(
      color: isActive ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => _viewMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? Theme.of(context).primaryColor : null,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? Theme.of(context).primaryColor : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
          const SizedBox(width: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartJoinButton(Community community, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Material(
        color: community.isUserMember
            ? Colors.green.withOpacity(0.1)
            : Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => community.isUserMember
              ? widget.onLeaveCommunity?.call(community)
              : widget.onJoinCommunity?.call(community),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    required String subtitle,
    bool showAction = false,
    String actionText = 'Смотреть все',
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
              child: Text(actionText),
            ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader(BuildContext context, List<Community> communities) {
    String title;
    String subtitle;

    if (_searchQuery.isNotEmpty) {
      title = 'Результаты поиска';
      subtitle = 'Найдено ${communities.length} ${_getCommunityWord(communities.length)}';
    } else if (_currentFilter != CommunityFilter.all) {
      title = _currentFilter.title;
      subtitle = '${communities.length} ${_getCommunityWord(communities.length)}';
    } else {
      title = 'Все сообщества';
      subtitle = '${communities.length} ${_getCommunityWord(communities.length)}';
    }

    return _buildSectionHeader(
      context: context,
      title: title,
      subtitle: subtitle,
    );
  }

  String _getCommunityWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'сообщество';
    if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)) {
      return 'сообщества';
    }
    return 'сообществ';
  }

  SliverGrid _buildGridLayout(List<Community> communities) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final community = communities[index];
          return _buildGridCommunityCard(community, context, index);
        },
        childCount: communities.length,
      ),
    );
  }

  Widget _buildGridCommunityCard(Community community, BuildContext context, int index) {
    final categoryColor = _getCategoryColor(community.category);
    final isExpanded = _expandedCards.contains(community.id);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.fromLTRB(
        index.isEven ? 16 : 8,
        8,
        index.isOdd ? 16 : 8,
        8,
      ),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => widget.onCommunityTap(community),
          onLongPress: () => _toggleCardExpansion(community.id),
          child: Stack(
            children: [
              // Градиентный фон
              Container(
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
                  children: [
                    // Аватар и название
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
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                community.category,
                                style: TextStyle(
                                  color: categoryColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Описание (расширяемое)
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 300),
                      crossFadeState: isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: Text(
                        community.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      secondChild: Text(
                        community.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Статистика и кнопка
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
                              if (isExpanded) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.chat_rounded,
                                        size: 12,
                                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${community.rooms.length} комнат',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        _buildSmartJoinButton(community, context),
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

              // Индикатор расширения
              if (isExpanded)
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.expand_less_rounded, size: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  SliverList _buildListLayout(List<Community> communities) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final community = communities[index];
          return _buildListCommunityCard(community, context, index);
        },
        childCount: communities.length,
      ),
    );
  }

  Widget _buildListCommunityCard(Community community, BuildContext context, int index) {
    final categoryColor = _getCategoryColor(community.category);
    final isExpanded = _expandedCards.contains(community.id);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => widget.onCommunityTap(community),
          onLongPress: () => _toggleCardExpansion(community.id),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Аватар сообщества
                Stack(
                  children: [
                    community.getCommunityIcon(size: 60),
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

                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        crossFadeState: isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: Text(
                          community.description,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        secondChild: Text(
                          community.description,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Теги
                      Wrap(
                        spacing: 6,
                        children: [
                          ...community.tags.take(isExpanded ? 4 : 2).map((tag) => Container(
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
                          if (community.tags.length > (isExpanded ? 4 : 2))
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '+${community.tags.length - (isExpanded ? 4 : 2)}',
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
                          _buildSmartJoinButton(community, context),
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

  Widget _buildAnimatedEmptyState(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            // Заменим Lottie на иконку
            Icon(
              Icons.search_off_rounded,
              size: 80,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              _getEmptyStateTitle(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptyStateSubtitle(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _resetFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Сбросить фильтры'),
                ),
                OutlinedButton(
                  onPressed: widget.onCreateCommunity,
                  child: const Text('Создать сообщество'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getEmptyStateTitle() {
    if (_searchQuery.isNotEmpty) {
      return 'Ничего не найдено';
    } else if (_currentFilter != CommunityFilter.all) {
      return 'Нет подходящих сообществ';
    }
    return 'Сообществ пока нет';
  }

  String _getEmptyStateSubtitle() {
    if (_searchQuery.isNotEmpty) {
      return 'Попробуйте изменить поисковый запрос или использовать другие ключевые слова';
    } else if (_currentFilter != CommunityFilter.all) {
      return 'Попробуйте изменить фильтры или создать новое сообщество';
    }
    return 'Будьте первым - создайте новое сообщество по вашим интересам!';
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _currentFilter = CommunityFilter.all;
      _isSearching = false;
      _expandedCards.clear();
    });
  }

  void _showAIRecommendations() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: Colors.purple),
                  const SizedBox(width: 8),
                  Text(
                    'AI Рекомендации',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _aiRecommendedCommunities.length,
                itemBuilder: (context, index) {
                  final community = _aiRecommendedCommunities[index];
                  final matchScore = _calculateAIMatchScore(community);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: community.getCommunityIcon(size: 50),
                      title: Text(community.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(community.category),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: matchScore,
                            backgroundColor: Colors.grey[200],
                            color: Colors.purple,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Совпадение: ${(matchScore * 100).toInt()}%',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: _buildSmartJoinButton(community, context),
                      onTap: () {
                        Navigator.pop(context);
                        widget.onCommunityTap(community);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}