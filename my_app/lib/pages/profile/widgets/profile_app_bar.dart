import 'package:flutter/material.dart';
import '../utils/profile_utils.dart';

class ProfileAppBar extends StatefulWidget {
  final bool showSearchBar;
  final TextEditingController searchController;
  final VoidCallback onBackPressed;
  final VoidCallback onSearchToggled;
  final VoidCallback onProfileMenuPressed;
  final Color userColor;
  final String userName;
  final int notificationCount;

  const ProfileAppBar({
    super.key,
    required this.showSearchBar,
    required this.searchController,
    required this.onBackPressed,
    required this.onSearchToggled,
    required this.onProfileMenuPressed,
    required this.userColor,
    required this.userName,
    this.notificationCount = 0,
  });

  @override
  State<ProfileAppBar> createState() => _ProfileAppBarState();
}

class _ProfileAppBarState extends State<ProfileAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _searchBarAnimation;
  late Animation<double> _titleAnimation;
  late Animation<Color?> _colorAnimation;

  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _searchBarAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _titleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: Colors.grey[600],
      end: widget.userColor,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    widget.searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(ProfileAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showSearchBar != widget.showSearchBar) {
      if (widget.showSearchBar) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      _isSearching = widget.searchController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final utils = ProfileUtils();
    final isMobile = ProfileUtils.isMobile(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: utils.getAdaptiveValue(context, mobile: 12, tablet: 14, desktop: 16),
            vertical: utils.getAdaptiveValue(context, mobile: 6, tablet: 7, desktop: 8),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF6366F1),
                const Color(0xFF8B5CF6),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: utils.getAdaptiveValue(context, mobile: 8, tablet: 10, desktop: 12),
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                _buildBackButton(utils, context, isMobile),
                SizedBox(width: utils.getAdaptiveValue(context, mobile: 6, tablet: 7, desktop: 8)),

                if (!widget.showSearchBar)
                  _buildAnimatedTitle(utils, context, isMobile),

                if (widget.showSearchBar)
                  _buildAnimatedSearchField(utils, context, isMobile),

                const Spacer(),

                _buildActionButtons(utils, context, isMobile),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackButton(ProfileUtils utils, BuildContext context, bool isMobile) {
    final buttonSize = utils.getAdaptiveValue(context, mobile: 36, tablet: 38, desktop: 40);

    return Tooltip(
      message: 'Назад',
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 10, tablet: 11, desktop: 12)),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onBackPressed,
            borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 10, tablet: 11, desktop: 12)),
            splashColor: Colors.white.withOpacity(0.2),
            child: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: utils.getAdaptiveIconSize(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTitle(ProfileUtils utils, BuildContext context, bool isMobile) {
    return Expanded(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _titleAnimation.value,
        child: Row(
          children: [
            Container(
              width: utils.getAdaptiveValue(context, mobile: 3, tablet: 3.5, desktop: 4),
              height: utils.getAdaptiveValue(context, mobile: 20, tablet: 22, desktop: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 1.5, tablet: 1.8, desktop: 2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
            SizedBox(width: utils.getAdaptiveValue(context, mobile: 8, tablet: 10, desktop: 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Профиль',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: utils.getAdaptiveFontSize(context, mobile: 18, tablet: 19, desktop: 20),
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!isMobile) SizedBox(height: utils.getAdaptiveValue(context, mobile: 1, tablet: 1.5, desktop: 2)),
                  if (!isMobile) Text(
                    widget.userName,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: utils.getAdaptiveFontSize(context, mobile: 11, tablet: 12, desktop: 12),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedSearchField(ProfileUtils utils, BuildContext context, bool isMobile) {
    return Expanded(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _searchBarAnimation.value,
        child: Row(
          children: [
            Expanded(
              child: _buildEnhancedSearchField(utils, context, isMobile),
            ),
            SizedBox(width: utils.getAdaptiveValue(context, mobile: 6, tablet: 7, desktop: 8)),
            _buildCloseSearchButton(utils, context, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedSearchField(ProfileUtils utils, BuildContext context, bool isMobile) {
    final fieldHeight = utils.getAdaptiveValue(context, mobile: 36, tablet: 40, desktop: 44);

    return Container(
      height: fieldHeight,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 14, tablet: 15, desktop: 16)),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: utils.getAdaptiveValue(context, mobile: 3, tablet: 3.5, desktop: 4),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: utils.getAdaptiveValue(context, mobile: 12, tablet: 14, desktop: 16)),
          Icon(
            Icons.search_rounded,
            size: utils.getAdaptiveIconSize(context),
            color: Colors.white.withOpacity(0.8),
          ),
          SizedBox(width: utils.getAdaptiveValue(context, mobile: 8, tablet: 10, desktop: 12)),
          Expanded(
            child: TextField(
              controller: widget.searchController,
              autofocus: true,
              style: TextStyle(
                fontSize: utils.getAdaptiveFontSize(context, mobile: 14, tablet: 15, desktop: 16),
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: isMobile ? 'Поиск...' : 'Поиск постов, лайков, репостов...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintStyle: TextStyle(
                  fontSize: utils.getAdaptiveFontSize(context, mobile: 14, tablet: 15, desktop: 16),
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              cursorColor: Colors.white,
              textInputAction: TextInputAction.search,
            ),
          ),
          if (_isSearching) ...[
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _isSearching ? 1.0 : 0.0,
              child: IconButton(
                icon: Icon(
                  Icons.clear_rounded,
                  size: utils.getAdaptiveIconSize(context),
                  color: Colors.white.withOpacity(0.8),
                ),
                onPressed: () => widget.searchController.clear(),
                padding: EdgeInsets.all(utils.getAdaptiveValue(context, mobile: 4, tablet: 5, desktop: 6)),
                constraints: BoxConstraints(
                  minWidth: utils.getAdaptiveValue(context, mobile: 32, tablet: 36, desktop: 40),
                  minHeight: utils.getAdaptiveValue(context, mobile: 32, tablet: 36, desktop: 40),
                ),
              ),
            ),
          ],
          SizedBox(width: utils.getAdaptiveValue(context, mobile: 6, tablet: 7, desktop: 8)),
        ],
      ),
    );
  }

  Widget _buildCloseSearchButton(ProfileUtils utils, BuildContext context, bool isMobile) {
    final buttonSize = utils.getAdaptiveValue(context, mobile: 36, tablet: 40, desktop: 44);

    return Tooltip(
      message: 'Закрыть поиск',
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 10, tablet: 11, desktop: 12)),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onSearchToggled,
            borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 10, tablet: 11, desktop: 12)),
            splashColor: Colors.white.withOpacity(0.2),
            child: Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: utils.getAdaptiveIconSize(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(ProfileUtils utils, BuildContext context, bool isMobile) {
    return Row(
      children: [
        if (widget.notificationCount > 0)
          _buildNotificationButton(utils, context, isMobile),

        _buildSearchToggleButton(utils, context, isMobile),

        _buildMenuButton(utils, context, isMobile),
      ],
    );
  }

  Widget _buildNotificationButton(ProfileUtils utils, BuildContext context, bool isMobile) {
    final buttonSize = utils.getAdaptiveValue(context, mobile: 36, tablet: 38, desktop: 40);
    final badgeSize = utils.getAdaptiveValue(context, mobile: 14, tablet: 15, desktop: 16);

    return Tooltip(
      message: 'Уведомления',
      child: Stack(
        children: [
          Container(
            width: buttonSize,
            height: buttonSize,
            margin: EdgeInsets.only(right: utils.getAdaptiveValue(context, mobile: 6, tablet: 7, desktop: 8)),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 10, tablet: 11, desktop: 12)),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.notificationCount} новых уведомлений'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 10, tablet: 11, desktop: 12)),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: utils.getAdaptiveIconSize(context),
                ),
              ),
            ),
          ),
          Positioned(
            top: utils.getAdaptiveValue(context, mobile: 4, tablet: 5, desktop: 6),
            right: utils.getAdaptiveValue(context, mobile: 8, tablet: 9, desktop: 12),
            child: Container(
              padding: EdgeInsets.all(utils.getAdaptiveValue(context, mobile: 3, tablet: 3.5, desktop: 4)),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              constraints: BoxConstraints(
                minWidth: badgeSize,
                minHeight: badgeSize,
              ),
              child: Text(
                widget.notificationCount > 99 ? '99+' : widget.notificationCount.toString(),
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
    );
  }

  Widget _buildSearchToggleButton(ProfileUtils utils, BuildContext context, bool isMobile) {
    final buttonSize = utils.getAdaptiveValue(context, mobile: 36, tablet: 38, desktop: 40);

    return Tooltip(
      message: widget.showSearchBar ? 'Закрыть поиск' : 'Поиск',
      child: Container(
        width: buttonSize,
        height: buttonSize,
        margin: EdgeInsets.only(right: utils.getAdaptiveValue(context, mobile: 6, tablet: 7, desktop: 8)),
        decoration: BoxDecoration(
          color: widget.showSearchBar
              ? Colors.white.withOpacity(0.25)
              : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 10, tablet: 11, desktop: 12)),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onSearchToggled,
            borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 10, tablet: 11, desktop: 12)),
            splashColor: Colors.white.withOpacity(0.2),
            child: Icon(
              widget.showSearchBar ? Icons.search_off_rounded : Icons.search_rounded,
              color: Colors.white,
              size: utils.getAdaptiveIconSize(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(ProfileUtils utils, BuildContext context, bool isMobile) {
    final buttonSize = utils.getAdaptiveValue(context, mobile: 36, tablet: 38, desktop: 40);

    return Tooltip(
      message: 'Меню профиля',
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 10, tablet: 11, desktop: 12)),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onProfileMenuPressed,
            borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 10, tablet: 11, desktop: 12)),
            splashColor: Colors.white.withOpacity(0.2),
            child: Icon(
              Icons.more_vert_rounded,
              color: Colors.white,
              size: utils.getAdaptiveIconSize(context),
            ),
          ),
        ),
      ),
    );
  }
}