import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/providers/news_provider.dart';
import '../utils/profile_utils.dart';

class ProfileContentTabs extends StatefulWidget {
  final int selectedSection;
  final double contentMaxWidth;
  final Color userColor;
  final String userEmail;
  final Function(int) onSectionChanged;
  final int postsCount;
  final int likedCount;
  final int repostsCount;

  const ProfileContentTabs({
    super.key,
    required this.selectedSection,
    required this.contentMaxWidth,
    required this.userColor,
    required this.userEmail,
    required this.onSectionChanged,
    this.postsCount = 0,
    this.likedCount = 0,
    this.repostsCount = 0,
  });

  @override
  State<ProfileContentTabs> createState() => _ProfileContentTabsState();
}

class _ProfileContentTabsState extends State<ProfileContentTabs> {
  final List<GlobalKey> _tabKeys = List.generate(4, (_) => GlobalKey());
  double _indicatorPosition = 0.0;
  double _indicatorWidth = 0.0;
  int _currentIndex = 0;

  final List<_TabInfo> _tabs = const [
    _TabInfo('Мои посты', Icons.article_rounded, 'posts'),
    _TabInfo('Понравилось', Icons.favorite_rounded, 'likes'),
    _TabInfo('Репосты', Icons.repeat_rounded, 'reposts'),
    _TabInfo('Информация', Icons.info_rounded, 'info'),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedSection;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateIndicatorPosition();
    });
  }

  @override
  void didUpdateWidget(ProfileContentTabs oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedSection != widget.selectedSection) {
      _currentIndex = widget.selectedSection;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateIndicatorPosition();
      });
    }
  }

  void _updateIndicatorPosition() {
    final renderBox = _tabKeys[_currentIndex].currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final parentRenderBox = context.findRenderObject() as RenderBox?;
      if (parentRenderBox != null) {
        final parentPosition = parentRenderBox.localToGlobal(Offset.zero);
        final tabPosition = renderBox.localToGlobal(Offset.zero);

        final newPosition = tabPosition.dx - parentPosition.dx;
        final newWidth = renderBox.size.width;

        setState(() {
          _indicatorPosition = newPosition;
          _indicatorWidth = newWidth;
        });
      }
    }
  }

  void _handleTabTap(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateIndicatorPosition();
      widget.onSectionChanged(index);
    });
  }

  int _getBadgeCount(int index) {
    switch (index) {
      case 0: return widget.postsCount;
      case 1: return widget.likedCount;
      case 2: return widget.repostsCount;
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final utils = ProfileUtils();
    final isMobile = ProfileUtils.isMobile(context);

    return Container(
      constraints: BoxConstraints(maxWidth: widget.contentMaxWidth),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
          ],
        ),
        borderRadius: utils.getAdaptiveBorderRadius(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: utils.getAdaptiveValue(context, mobile: 12, tablet: 14, desktop: 16),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: utils.getAdaptivePadding(context),
        child: Column(
          children: [
            _buildHeaderSection(utils, context, isMobile),
            SizedBox(height: utils.getAdaptiveSpacing(context)),
            _buildTabsContainer(utils, context, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(ProfileUtils utils, BuildContext context, bool isMobile) {
    return Row(
      children: [
        Container(
          width: utils.getAdaptiveValue(context, mobile: 3, tablet: 3.5, desktop: 4),
          height: utils.getAdaptiveValue(context, mobile: 20, tablet: 22, desktop: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 1.5, tablet: 1.8, desktop: 2)),
          ),
        ),
        SizedBox(width: utils.getAdaptiveValue(context, mobile: 8, tablet: 10, desktop: 12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Контент профиля',
                style: TextStyle(
                  fontSize: utils.getAdaptiveFontSize(context, mobile: 16, tablet: 17, desktop: 18),
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: utils.getAdaptiveValue(context, mobile: 1, tablet: 2, desktop: 2)),
              _buildContentStats(utils, context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentStats(ProfileUtils utils, BuildContext context) {
    final totalContent = widget.postsCount + widget.likedCount + widget.repostsCount;
    return Text(
      totalContent > 0
          ? '$totalContent ${_getContentWord(totalContent)}'
          : 'Пока нет контента',
      style: TextStyle(
        fontSize: utils.getAdaptiveFontSize(context, mobile: 12, tablet: 13, desktop: 13),
        color: Colors.white.withOpacity(0.8),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  String _getContentWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'элемент';
    if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)) {
      return 'элемента';
    }
    return 'элементов';
  }

  Widget _buildTabsContainer(ProfileUtils utils, BuildContext context, bool isMobile) {
    final tabHeight = utils.getAdaptiveValue(context, mobile: 44, tablet: 48, desktop: 52);
    final indicatorHeight = utils.getAdaptiveValue(context, mobile: 36, tablet: 40, desktop: 44);
    final margin = utils.getAdaptiveValue(context, mobile: 3, tablet: 3.5, desktop: 4);

    return Container(
      height: tabHeight,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 14, tablet: 15, desktop: 16)),
        border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: utils.getAdaptiveValue(context, mobile: 1.2, tablet: 1.3, desktop: 1.5)
        ),
      ),
      child: Stack(
        children: [
          // Индикатор
          Positioned(
            left: _indicatorPosition,
            child: Container(
              width: _indicatorWidth,
              height: indicatorHeight,
              margin: EdgeInsets.all(margin),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 10, tablet: 11, desktop: 12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: utils.getAdaptiveValue(context, mobile: 6, tablet: 7, desktop: 8),
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          // Табы
          Row(
            children: _tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              return _buildTab(utils, context, tab, index, isMobile);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(ProfileUtils utils, BuildContext context, _TabInfo tab, int index, bool isMobile) {
    final isActive = _currentIndex == index;
    final badgeCount = _getBadgeCount(index);
    final horizontalPadding = utils.getAdaptiveValue(context, mobile: 6, tablet: 7, desktop: 8);
    final verticalPadding = utils.getAdaptiveValue(context, mobile: 10, tablet: 11, desktop: 12);

    return Expanded(
      child: Container(
        key: _tabKeys[index],
        margin: EdgeInsets.all(utils.getAdaptiveValue(context, mobile: 3, tablet: 3.5, desktop: 4)),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleTabTap(index),
            borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 10, tablet: 11, desktop: 12)),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      Icon(
                        tab.icon,
                        size: utils.getAdaptiveIconSize(context),
                        color: isActive ? Color(0xFF6366F1) : Colors.white.withOpacity(0.7),
                      ),
                      if (badgeCount > 0 && index != 3)
                        Positioned(
                          top: -utils.getAdaptiveValue(context, mobile: 3, tablet: 3.5, desktop: 4),
                          right: -utils.getAdaptiveValue(context, mobile: 3, tablet: 3.5, desktop: 4),
                          child: Container(
                            padding: EdgeInsets.all(utils.getAdaptiveValue(context, mobile: 2, tablet: 2.5, desktop: 3)),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white,
                                  width: utils.getAdaptiveValue(context, mobile: 1.2, tablet: 1.3, desktop: 1.5)
                              ),
                            ),
                            constraints: BoxConstraints(
                              minWidth: utils.getAdaptiveValue(context, mobile: 14, tablet: 15, desktop: 16),
                              minHeight: utils.getAdaptiveValue(context, mobile: 14, tablet: 15, desktop: 16),
                            ),
                            child: Text(
                              badgeCount > 99 ? '99+' : badgeCount.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: utils.getAdaptiveFontSize(context, mobile: 7, tablet: 7.5, desktop: 8),
                                fontWeight: FontWeight.w900,
                                height: 1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (!isMobile || (isMobile && _shouldShowTextOnMobile(tab.text)))
                    SizedBox(width: utils.getAdaptiveValue(context, mobile: 4, tablet: 5, desktop: 6)),
                  if (!isMobile || (isMobile && _shouldShowTextOnMobile(tab.text)))
                    Text(
                      _getTabText(tab.text, isMobile),
                      style: TextStyle(
                        color: isActive ? Color(0xFF6366F1) : Colors.white.withOpacity(0.7),
                        fontSize: utils.getAdaptiveFontSize(context, mobile: 11, tablet: 12, desktop: 13),
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _shouldShowTextOnMobile(String text) {
    return text.length <= 8;
  }

  String _getTabText(String text, bool isMobile) {
    if (!isMobile) return text;

    switch (text) {
      case 'Мои посты': return 'Посты';
      case 'Понравилось': return 'Лайки';
      case 'Репосты': return 'Репосты';
      case 'Информация': return 'Инфо';
      default: return text;
    }
  }
}

class _TabInfo {
  final String text;
  final IconData icon;
  final String type;

  const _TabInfo(this.text, this.icon, this.type);
}