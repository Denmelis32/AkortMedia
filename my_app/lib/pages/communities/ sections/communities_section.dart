// widgets/sections/communities_section.dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/community.dart';

// Расширяем enum для фильтров
enum CommunityFilter {
  all('Все', Icons.all_inclusive_rounded, Colors.blue),
  popular('Популярные', Icons.trending_up_rounded, Colors.orange),
  growing('Растущие', Icons.arrow_upward_rounded, Colors.green),
  active('Активные', Icons.flash_on_rounded, Colors.red),
  verified('Проверенные', Icons.verified_rounded, Colors.blue),
  joined('Мои сообщества', Icons.group_rounded, Colors.purple),
  newest('Новые', Icons.new_releases_rounded, Colors.teal),
  trending('В тренде', Icons.local_fire_department_rounded, Colors.deepOrange);

  const CommunityFilter(this.title, this.icon, this.color);
  final String title;
  final IconData icon;
  final Color color;
}

// Расширяем enum для режимов просмотра
enum CommunityViewMode {
  grid(Icons.grid_view_rounded, 'Сетка'),
  list(Icons.view_list_rounded, 'Список'),
  compact(Icons.view_quilt_rounded, 'Компактный');

  const CommunityViewMode(this.icon, this.label);
  final IconData icon;
  final String label;
}

class CommunitiesSection extends StatefulWidget {
  final List<Community> communities;
  final Function(Community) onCommunityTap;
  final VoidCallback onCreateCommunity;
  final Function(Community)? onJoinCommunity;
  final Function(Community)? onLeaveCommunity;
  final VoidCallback? onExploreMore;
  final bool showQuickActions;
  final bool showAIRecommendations;
  final bool showTrending;

  const CommunitiesSection({
    super.key,
    required this.communities,
    required this.onCommunityTap,
    required this.onCreateCommunity,
    this.onJoinCommunity,
    this.onLeaveCommunity,
    this.onExploreMore,
    this.showQuickActions = true,
    this.showAIRecommendations = true,
    this.showTrending = true,
  });

  @override
  State<CommunitiesSection> createState() => _CommunitiesSectionState();
}

class _CommunitiesSectionState extends State<CommunitiesSection>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final PageController _trendingController = PageController(viewportFraction: 0.8);
  final PageController _aiController = PageController(viewportFraction: 0.85);

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _headerColorAnimation;

  bool _isSearching = false;
  String _searchQuery = '';
  CommunityFilter _currentFilter = CommunityFilter.all;
  CommunityViewMode _viewMode = CommunityViewMode.grid;
  Set<String> _expandedCards = {};
  Set<String> _favoriteCommunities = {};
  double _scrollOffset = 0;
  bool _showFiltersSheet = false;
  int _currentTrendingPage = 0;
  int _currentAIPage = 0;

  // Кэш для анимированных значков
  final Map<String, IconData> _animatedIcons = {};

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    // Инициализируем анимацию цвета с прозрачным значением по умолчанию
    _headerColorAnimation = ConstantAnimation(Colors.transparent);

    _scrollController.addListener(_onScroll);
    _trendingController.addListener(_onTrendingPageChange);
    _aiController.addListener(_onAIPageChange);

    // Загрузка избранных сообществ
    _loadFavorites();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Теперь безопасно обращаемся к Theme.of(context) здесь
    _headerColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Theme.of(context).colorScheme.surface.withOpacity(0.95),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeInOut),
    ));

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

  void _onTrendingPageChange() {
    setState(() {
      _currentTrendingPage = _trendingController.page?.round() ?? 0;
    });
  }

  void _onAIPageChange() {
    setState(() {
      _currentAIPage = _aiController.page?.round() ?? 0;
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

  void _toggleFavorite(String communityId) {
    setState(() {
      if (_favoriteCommunities.contains(communityId)) {
        _favoriteCommunities.remove(communityId);
        _animatedIcons.remove(communityId);
      } else {
        _favoriteCommunities.add(communityId);
        _animatedIcons[communityId] = Icons.favorite_rounded;
      }
    });
    _saveFavorites();
  }

  void _loadFavorites() async {
    // Здесь можно загружать из SharedPreferences
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      setState(() {
        _favoriteCommunities = {'comm1', 'comm3'}.toSet(); // Пример данных
      });
    }
  }

  void _saveFavorites() {
    // Здесь можно сохранять в SharedPreferences
  }

  // AI рекомендации с улучшенным алгоритмом
  List<Community> get _aiRecommendedCommunities {
    final userCommunities = widget.communities.where((c) => c.isUserMember).toList();
    final userCategories = userCommunities.map((c) => c.category).toSet();
    final userTags = userCommunities.expand((c) => c.tags).toSet();

    final recommended = widget.communities
        .where((community) {
      if (community.isUserMember) return false;

      double score = 0.0;

      // Совпадение категории
      if (userCategories.contains(community.category)) score += 0.4;

      // Совпадение тегов
      final commonTags = community.tags.toSet().intersection(userTags);
      score += commonTags.length * 0.1;

      // Популярность и активность
      if (community.isPopular) score += 0.2;
      if (community.isActive) score += 0.15;
      if (community.isGrowing) score += 0.1;

      // Избранное
      if (_favoriteCommunities.contains(community.id)) score += 0.15;

      return score >= 0.3;
    })
        .toList();

    recommended.sort((a, b) => _calculateAIMatchScore(b).compareTo(_calculateAIMatchScore(a)));
    return recommended.take(6).toList();
  }

  double _calculateAIMatchScore(Community community) {
    final userCommunities = widget.communities.where((c) => c.isUserMember).toList();
    final userCategories = userCommunities.map((c) => c.category).toSet();
    final userTags = userCommunities.expand((c) => c.tags).toSet();

    double score = 0.0;

    // Совпадение категории
    if (userCategories.contains(community.category)) {
      score += 0.4;
    }

    // Совпадение тегов
    final commonTags = community.tags.toSet().intersection(userTags);
    score += commonTags.length * 0.1;

    // Популярность
    if (community.isPopular) score += 0.2;

    // Активность
    if (community.isActive) score += 0.15;

    // Рост
    if (community.isGrowing) score += 0.1;

    // Избранное
    if (_favoriteCommunities.contains(community.id)) score += 0.15;

    return score.clamp(0.0, 1.0);
  }

  List<Community> get _trendingCommunities {
    final trending = widget.communities
        .where((c) => c.isGrowing && c.stats.weeklyGrowth > 0.15)
        .toList();

    trending.sort((a, b) => b.stats.weeklyGrowth.compareTo(a.stats.weeklyGrowth));
    return trending.take(8).toList();
  }

  List<Community> get _filteredCommunities {
    var filtered = widget.communities;

    // Поиск
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((community) =>
      community.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          community.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          community.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase())) ||
          community.category.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
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
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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

  Widget _buildAnimatedHeader(BuildContext context) {
    return AnimatedBuilder(
      animation: _scrollController,
      builder: (context, child) {
        final opacity = 1.0 - (_scrollOffset / 100).clamp(0.0, 1.0);
        final scale = 1.0 + (_scrollOffset / 500).clamp(0.0, 0.3);
        final translateY = -(_scrollOffset / 3).clamp(0.0, 40.0);

        return Transform.translate(
          offset: Offset(0, translateY),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Сообщества',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Откройте мир общения по интересам',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Статистика перемещена в отдельный виджет ниже
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _isSearching
          ? _buildSearchField(context)
          : Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _isSearching = true;
                  _searchFocusNode.requestFocus();
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text(
                        'Поиск сообществ...',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Сообщества, теги, интересы...',
                  prefixIcon: Icon(Icons.search_rounded,
                      color: Theme.of(context).colorScheme.primary),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.clear_rounded,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                        ),
                      IconButton(
                        icon: Icon(Icons.close_rounded,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                        onPressed: () {
                          setState(() {
                            _isSearching = false;
                            _searchQuery = '';
                            _searchController.clear();
                            _searchFocusNode.unfocus();
                          });
                        },
                      ),
                    ],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveStats(BuildContext context) {
    final total = widget.communities.length;
    final joined = widget.communities.where((c) => c.isUserMember).length;

    return Wrap(
      spacing: 8, // Уменьшено с 12
      runSpacing: 8, // Уменьшено с 12
      children: [
        _buildCompactStatCard(
          icon: Icons.people_alt_rounded,
          value: total.toString(),
          label: 'Всего',
          color: Colors.blue,
          context: context,
        ),
        _buildCompactStatCard(
          icon: Icons.group_rounded,
          value: joined.toString(),
          label: 'Ваши',
          color: Colors.green,
          context: context,
        ),
      ],
    );
  }

// Компактная версия карточки статистики
  Widget _buildCompactStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Уменьшены отступы
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16), // Уменьшено с 20
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color), // Уменьшено с 16
          const SizedBox(width: 6), // Уменьшено с 8
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14, // Уменьшено с 16
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10, // Уменьшено с 11
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Уменьшены отступы
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Первая строка кнопок
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildCompactActionButton(
                  icon: Icons.add_rounded,
                  label: 'Создать',
                  color: Theme.of(context).colorScheme.primary,
                  onTap: widget.onCreateCommunity,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactActionButton(
                  icon: Icons.search_rounded,
                  label: 'Поиск',
                  color: Colors.orange,
                  onTap: () => setState(() {
                    _isSearching = true;
                    _searchFocusNode.requestFocus();
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactActionButton(
                  icon: Icons.auto_awesome_rounded,
                  label: 'AI Подбор',
                  color: Colors.purple,
                  onTap: _showAIRecommendations,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Вторая строка кнопок
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (widget.onExploreMore != null)
                Expanded(
                  child: _buildCompactActionButton(
                    icon: Icons.explore_rounded,
                    label: 'Исследовать',
                    color: Colors.teal,
                    onTap: widget.onExploreMore!,
                  ),
                ),
              if (widget.onExploreMore != null) const SizedBox(width: 8),
              Expanded(
                child: _buildCompactActionButton(
                  icon: Icons.favorite_rounded,
                  label: 'Избранное',
                  color: Colors.pink,
                  onTap: _showFavorites,
                ),
              ),
              if (widget.onExploreMore == null) const SizedBox(width: 8),
              if (widget.onExploreMore == null)
                Expanded(child: Container()), // Пустой контейнер для выравнивания
            ],
          ),
        ],
      ),
    );
  }

// Компактная версия кнопки для экономии места
  Widget _buildCompactActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: color,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      shadowColor: color.withOpacity(0.3),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 14,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSectionHeader(
            context: context,
            title: '🤖 Рекомендуем именно вам',
            subtitle: 'На основе ваших интересов и активности',
            showAction: true,
            actionText: 'Все рекомендации',
            onAction: _showAIRecommendations,
          ),
          const SizedBox(height: 8),
          // ЗАМЕНА: Используем ограничение по высоте вместо фиксированной
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 220,
              maxHeight: 280, // Максимальная высота для безопасности
            ),
            child: Stack(
              children: [
                PageView.builder(
                  controller: _aiController,
                  itemCount: recommendations.length,
                  itemBuilder: (context, index) {
                    final community = recommendations[index];
                    return _buildAIRecommendedCard(community, context, index);
                  },
                  padEnds: false,
                ),
                if (recommendations.length > 1)
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(recommendations.length, (index) {
                        return Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentAIPage == index
                                ? Theme.of(context).primaryColor
                                : Colors.grey.withOpacity(0.5),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildAIRecommendedCard(Community community, BuildContext context, int index) {
    final matchScore = _calculateAIMatchScore(community);
    final categoryColor = _getCategoryColor(community.category);

    return AnimatedContainer(
      duration: Duration(milliseconds: 400 + (index * 100)),
      margin: EdgeInsets.only(
        left: index == 0 ? 20 : 10,
        right: index == _aiRecommendedCommunities.length - 1 ? 20 : 10,
        bottom: 20,
      ),
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox( // ДОБАВЛЕНО: Ограничение по высоте
          constraints: const BoxConstraints(
            minHeight: 200,
            maxHeight: 260,
          ),
          child: Stack(
            children: [
              // Градиентный фон с анимацией
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      categoryColor.withOpacity(0.3),
                      categoryColor.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Контент
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // ИЗМЕНЕНО: чтобы не растягивалось
                  children: [
                    // Заголовок с аватаром и индикатором совпадения
                    Row(
                      children: [
                        Stack(
                          children: [
                            community.getCommunityIcon(size: 50),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.purple,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.auto_awesome_rounded,
                                    size: 12, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                community.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                community.category,
                                style: TextStyle(
                                  color: categoryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1, // ДОБАВЛЕНО
                                overflow: TextOverflow.ellipsis, // ДОБАВЛЕНО
                              ),
                            ],
                          ),
                        ),
                        _buildAIMatchIndicator(matchScore, context),
                      ],
                    ),

                    const SizedBox(height: 12), // УМЕНЬШЕНО с 16

                    // Описание
                    Expanded( // ИЗМЕНЕНО: используем Expanded для гибкости
                      child: SingleChildScrollView( // ДОБАВЛЕНО: скролл если не помещается
                        physics: const ClampingScrollPhysics(),
                        child: Text(
                          community.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12), // УМЕНЬШЕНО с 16

                    // Теги
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: community.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '#$tag',
                            style: TextStyle(
                              fontSize: 11,
                              color: categoryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 12), // УМЕНЬШЕНО с 16

                    // Статистика и кнопка
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
                        const SizedBox(width: 8),
                        _buildStatChip(
                          icon: Icons.chat_rounded,
                          value: '${community.rooms.length}',
                          context: context,
                        ),
                        const Spacer(),
                        _buildEnhancedJoinButton(community, context),
                      ],
                    ),
                  ],
                ),
              ),

              // Избранное
              Positioned(
                top: 12,
                right: 12,
                child: _buildFavoriteButton(community),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIMatchIndicator(double matchScore, BuildContext context) {
    return Tooltip(
      message: 'Совпадение интересов: ${(matchScore * 100).toInt()}%',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.withOpacity(0.8),
              Colors.deepPurple.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_rounded, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              '${(matchScore * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
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
            height: 140,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _trendingController,
                  itemCount: trending.length,
                  itemBuilder: (context, index) {
                    final community = trending[index];
                    return _buildTrendingCard(community, context, index);
                  },
                  padEnds: false,
                ),
                // Индикаторы страниц
                if (trending.length > 1)
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(trending.length, (index) {
                        return Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentTrendingPage == index
                                ? Colors.orange
                                : Colors.grey.withOpacity(0.5),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingCard(Community community, BuildContext context, int index) {
    final growth = community.stats.weeklyGrowth * 100;
    final categoryColor = _getCategoryColor(community.category);

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      margin: EdgeInsets.only(
        left: index == 0 ? 20 : 10,
        right: index == _trendingCommunities.length - 1 ? 20 : 10,
        bottom: 8,
      ),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => widget.onCommunityTap(community),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Аватар с бейджем тренда
                Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            categoryColor.withOpacity(0.3),
                            categoryColor.withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: community.getCommunityIcon(size: 40),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.trending_up_rounded,
                            size: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // Информация
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        community.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '+${growth.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            community.formattedMemberCount,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Кнопка присоединения
                _buildCompactJoinButton(community, context),
              ],
            ),
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
      showAction: communities.isNotEmpty,
      actionText: 'Сбросить',
      onAction: _resetFilters,
    );
  }

  Widget _buildCommunityList(List<Community> communities) {
    switch (_viewMode) {
      case CommunityViewMode.grid:
        return _buildGridLayout(communities);
      case CommunityViewMode.list:
        return _buildListLayout(communities);
      case CommunityViewMode.compact:
        return _buildCompactLayout(communities);
    }
  }

  SliverGrid _buildGridLayout(List<Community> communities) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
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
    final isFavorite = _favoriteCommunities.contains(community.id);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.fromLTRB(
        index.isEven ? 16 : 8,
        8,
        index.isOdd ? 16 : 8,
        8,
      ),
      child: Card(
        elevation: 6,
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
                      Colors.transparent,
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
                        const SizedBox(width: 12),
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
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      secondChild: Text(
                        community.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          height: 1.3,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Статистика
                    Row(
                      children: [
                        _buildStatChip(
                          icon: Icons.people_rounded,
                          value: community.formattedMemberCount,
                          context: context,
                        ),
                        const SizedBox(width: 6),
                        _buildStatChip(
                          icon: Icons.chat_rounded,
                          value: community.rooms.length.toString(),
                          context: context,
                        ),
                        if (isExpanded) ...[
                          const SizedBox(width: 6),
                          _buildStatChip(
                            icon: Icons.online_prediction_rounded,
                            value: community.onlineCount.toString(),
                            context: context,
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Кнопка присоединения
                    _buildEnhancedJoinButton(community, context),
                  ],
                ),
              ),

              // Бейджи и избранное
              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  children: [
                    ...community.buildBadges(compact: true),
                    const SizedBox(width: 4),
                    _buildFavoriteButton(community),
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
    final isFavorite = _favoriteCommunities.contains(community.id);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => widget.onCommunityTap(community),
          onLongPress: () => _toggleCardExpansion(community.id),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Аватар сообщества
                Stack(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            categoryColor.withOpacity(0.2),
                            categoryColor.withOpacity(0.05),
                          ],
                        ),
                      ),
                      child: community.getCommunityIcon(size: 40),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  community.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  community.category,
                                  style: TextStyle(
                                    color: categoryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              ...community.buildBadges(compact: false),
                              const SizedBox(height: 4),
                              _buildFavoriteButton(community),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Описание
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        crossFadeState: isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: Text(
                          community.description,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        secondChild: Text(
                          community.description,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                            height: 1.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Теги
                      if (isExpanded || community.tags.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: community.tags.take(isExpanded ? 6 : 3).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '#$tag',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: categoryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                      if (isExpanded || community.tags.isNotEmpty) const SizedBox(height: 12),

                      // Статистика и кнопка
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
                          _buildEnhancedJoinButton(community, context),
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

  SliverList _buildCompactLayout(List<Community> communities) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final community = communities[index];
          return _buildCompactCommunityCard(community, context, index);
        },
        childCount: communities.length,
      ),
    );
  }

  Widget _buildCompactCommunityCard(Community community, BuildContext context, int index) {
    final categoryColor = _getCategoryColor(community.category);
    final isFavorite = _favoriteCommunities.contains(community.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => widget.onCommunityTap(community),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Аватар
                Stack(
                  children: [
                    community.getCommunityIcon(size: 40),
                    if (community.isUserMember)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded, size: 8, color: Colors.white),
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
                      Text(
                        community.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        community.category,
                        style: TextStyle(
                          color: categoryColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // Статистика
                Row(
                  children: [
                    Icon(Icons.people_rounded, size: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)),
                    const SizedBox(width: 2),
                    Text(
                      community.formattedMemberCount,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildCompactJoinButton(community, context),
                  ],
                ),

                const SizedBox(width: 8),

                // Избранное
                _buildFavoriteButton(community, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(Community community, {double size = 20}) {
    final isFavorite = _favoriteCommunities.contains(community.id);
    final icon = _animatedIcons[community.id] ??
        (isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded);

    return IconButton(
      icon: Icon(icon, size: size),
      color: isFavorite ? Colors.pink : Colors.grey,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(minWidth: size, minHeight: size),
      onPressed: () => _toggleFavorite(community.id),
    );
  }

  Widget _buildEnhancedJoinButton(Community community, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Material(
        color: community.isUserMember
            ? Colors.green.withOpacity(0.1)
            : Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => community.isUserMember
              ? widget.onLeaveCommunity?.call(community)
              : widget.onJoinCommunity?.call(community),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  community.isUserMember ? Icons.check_rounded : Icons.add_rounded,
                  size: 16,
                  color: community.isUserMember ? Colors.green : Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  community.isUserMember ? 'В сообществе' : 'Присоединиться',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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

  Widget _buildCompactJoinButton(Community community, BuildContext context) {
    return Material(
      color: community.isUserMember
          ? Colors.green.withOpacity(0.1)
          : Theme.of(context).colorScheme.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => community.isUserMember
            ? widget.onLeaveCommunity?.call(community)
            : widget.onJoinCommunity?.call(community),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Icon(
            community.isUserMember ? Icons.check_rounded : Icons.add_rounded,
            size: 14,
            color: community.isUserMember ? Colors.green : Theme.of(context).colorScheme.primary,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ],
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
                  size: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
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
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
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
                    fontSize: 20,
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
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(actionText),
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getEmptyStateIcon(),
              size: 50,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            _getEmptyStateTitle(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            _getEmptyStateSubtitle(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              fontSize: 16,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              ElevatedButton(
                onPressed: _resetFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Сбросить фильтры'),
              ),
              OutlinedButton(
                onPressed: widget.onCreateCommunity,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Создать сообщество'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEndOfListHint(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Вы достигли конца списка',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Найдено ${_filteredCommunities.length} сообществ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEmptyStateIcon() {
    if (_searchQuery.isNotEmpty) {
      return Icons.search_off_rounded;
    } else if (_currentFilter != CommunityFilter.all) {
      return Icons.filter_alt_off_rounded;
    }
    return Icons.group_work_rounded;
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

  String _getCommunityWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'сообщество';
    if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)) {
      return 'сообщества';
    }
    return 'сообществ';
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _currentFilter = CommunityFilter.all;
      _isSearching = false;
      _expandedCards.clear();
      _searchFocusNode.unfocus();
    });
  }

  void _showAIRecommendations() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Хедер
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: Colors.purple),
                  ),
                  const SizedBox(width: 12),
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

            const SizedBox(height: 8),

            // Контент
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _aiRecommendedCommunities.length,
                itemBuilder: (context, index) {
                  final community = _aiRecommendedCommunities[index];
                  final matchScore = _calculateAIMatchScore(community);
                  final categoryColor = _getCategoryColor(community.category);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: Stack(
                        children: [
                          community.getCommunityIcon(size: 50),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.purple,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.auto_awesome_rounded,
                                  size: 10, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      title: Text(community.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(community.category),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: matchScore,
                            backgroundColor: Colors.grey[200],
                            color: Colors.purple,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Совпадение: ${(matchScore * 100).toInt()}%',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const Spacer(),
                              Text(
                                community.formattedMemberCount,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: _buildEnhancedJoinButton(community, context),
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

  void _showFavorites() {
    final favoriteCommunities = widget.communities
        .where((community) => _favoriteCommunities.contains(community.id))
        .toList();

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
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.pink.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_rounded, color: Colors.pink),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Избранные сообщества',
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
              child: favoriteCommunities.isEmpty
                  ? _buildEmptyFavoritesState(context)
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favoriteCommunities.length,
                itemBuilder: (context, index) {
                  final community = favoriteCommunities[index];
                  return _buildFavoriteListItem(community, context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFavoritesState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 80,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Нет избранных сообществ',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            'Добавляйте сообщества в избранное,\nчтобы быстро находить их позже',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteListItem(Community community, BuildContext context) {
    final categoryColor = _getCategoryColor(community.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: community.getCommunityIcon(size: 50),
        title: Text(community.name),
        subtitle: Text(community.category),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildEnhancedJoinButton(community, context),
            const SizedBox(width: 8),
            _buildFavoriteButton(community),
          ],
        ),
        onTap: () {
          Navigator.pop(context);
          widget.onCommunityTap(community);
        },
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
  Widget build(BuildContext context) {
    final filteredCommunities = _filteredCommunities;
    final aiRecommended = _aiRecommendedCommunities;
    final trending = _trendingCommunities;
    final theme = Theme.of(context);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          _animationController.forward();
        }
        return false;
      },
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // Улучшенный заголовок с параллакс эффектом
          SliverAppBar(
            backgroundColor: _headerColorAnimation.value,
            expandedHeight: 160,
            floating: true,
            pinned: true,
            snap: true,
            elevation: _scrollOffset > 50 ? 8 : 0,
            shadowColor: theme.shadowColor.withOpacity(0.3),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildAnimatedHeader(context),
              collapseMode: CollapseMode.pin,
              titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: _buildSearchBar(context),
            ),
          ),


          // Быстрые действия с улучшенной анимацией
          if (widget.showQuickActions && !_isSearching)
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildQuickActions(context),
                ),
              ),
            ),

          // AI рекомендации с каруселью
          if (aiRecommended.isNotEmpty &&
              _currentFilter == CommunityFilter.all &&
              widget.showAIRecommendations)
            _buildAISection(context, aiRecommended),

          // Трендовые сообщества с каруселью
          if (trending.isNotEmpty &&
              _currentFilter == CommunityFilter.all &&
              widget.showTrending)
            _buildTrendingSection(context, trending),

          // Улучшенные контролы вида и фильтров
          SliverPersistentHeader(
            pinned: true,
            delegate: _ViewControlsDelegate(
              viewMode: _viewMode,
              currentFilter: _currentFilter,
              onViewModeChanged: (mode) => setState(() => _viewMode = mode),
              onFilterChanged: (filter) => setState(() => _currentFilter = filter),
              showFilters: _currentFilter == CommunityFilter.all,
              theme: theme,
            ),
          ),

          // Заголовок результатов
          SliverToBoxAdapter(
            child: _buildResultsHeader(context, filteredCommunities),
          ),

          // Сетка, список или компактный вид
          if (filteredCommunities.isNotEmpty)
            _buildCommunityList(filteredCommunities)
          else
          // Анимированное пустое состояние
            SliverToBoxAdapter(
              child: _buildAnimatedEmptyState(context),
            ),

          // Подсказка в конце
          if (filteredCommunities.length > 10)
            SliverToBoxAdapter(
              child: _buildEndOfListHint(context),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    _trendingController.dispose();
    _aiController.dispose();
    super.dispose();
  }
}

// Простой класс для постоянной анимации
class ConstantAnimation<T> extends Animation<T> {
  final T _value;

  ConstantAnimation(T value) : _value = value;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}

  @override
  void addStatusListener(AnimationStatusListener listener) {}

  @override
  void removeStatusListener(AnimationStatusListener listener) {}

  @override
  AnimationStatus get status => AnimationStatus.completed;

  @override
  T get value => _value;
}

// Делегат для персистентного хедера
class _ViewControlsDelegate extends SliverPersistentHeaderDelegate {
  final CommunityViewMode viewMode;
  final CommunityFilter currentFilter;
  final ValueChanged<CommunityViewMode> onViewModeChanged;
  final ValueChanged<CommunityFilter> onFilterChanged;
  final bool showFilters;
  final ThemeData theme;

  _ViewControlsDelegate({
    required this.viewMode,
    required this.currentFilter,
    required this.onViewModeChanged,
    required this.onFilterChanged,
    required this.showFilters,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: theme.colorScheme.surface.withOpacity(0.95),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Переключатель вида
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: CommunityViewMode.values.map((mode) {
                  return _buildViewModeButton(mode, context);
                }).toList(),
              ),
            ),

            const Spacer(),

            // Фильтры
            if (showFilters)
              PopupMenuButton<CommunityFilter>(
                onSelected: onFilterChanged,
                itemBuilder: (context) => CommunityFilter.values.map((filter) {
                  return PopupMenuItem(
                    value: filter,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: filter.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(filter.icon, size: 18, color: filter.color),
                        ),
                        const SizedBox(width: 12),
                        Text(filter.title),
                      ],
                    ),
                  );
                }).toList(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: currentFilter.color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(currentFilter.icon, size: 18, color: currentFilter.color),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        currentFilter.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down_rounded,
                          color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewModeButton(CommunityViewMode mode, BuildContext context) {
    final isActive = viewMode == mode;

    return Material(
      color: isActive ? theme.primaryColor.withOpacity(0.15) : Colors.transparent,
      borderRadius: _getBorderRadius(mode),
      child: InkWell(
        borderRadius: _getBorderRadius(mode),
        onTap: () => onViewModeChanged(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                mode.icon,
                size: 18,
                color: isActive ? theme.primaryColor : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                mode.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? theme.primaryColor : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BorderRadius _getBorderRadius(CommunityViewMode mode) {
    if (mode == CommunityViewMode.values.first) {
      return const BorderRadius.horizontal(left: Radius.circular(16));
    } else if (mode == CommunityViewMode.values.last) {
      return const BorderRadius.horizontal(right: Radius.circular(16));
    }
    return BorderRadius.zero;
  }

  @override
  double get maxExtent => 56;

  @override
  double get minExtent => 56;

  @override
  bool shouldRebuild(covariant _ViewControlsDelegate oldDelegate) {
    return viewMode != oldDelegate.viewMode ||
        currentFilter != oldDelegate.currentFilter ||
        showFilters != oldDelegate.showFilters ||
        theme != oldDelegate.theme;
  }
}