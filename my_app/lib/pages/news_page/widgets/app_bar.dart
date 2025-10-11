import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/news_theme.dart';

class NewsAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String userName;
  final String userEmail;
  final bool isSearching;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchToggled;
  final VoidCallback onProfilePressed;
  final VoidCallback? onClearFilters;
  final VoidCallback? onAdvancedSearchPressed;
  final bool hasActiveFilters;
  final int? unreadNotificationsCount;
  final List<String>? recentSearches;
  final ValueChanged<String>? onRecentSearchSelected;
  final int? newMessagesCount;
  final String? profileImageUrl;
  final File? profileImageFile;

  const NewsAppBar({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.isSearching,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onSearchToggled,
    required this.onProfilePressed,
    this.onClearFilters,
    this.onAdvancedSearchPressed,
    this.hasActiveFilters = false,
    this.unreadNotificationsCount = 0,
    this.recentSearches,
    this.onRecentSearchSelected,
    this.newMessagesCount = 0,
    this.profileImageUrl,
    this.profileImageFile,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  State<NewsAppBar> createState() => _NewsAppBarState();
}

class _NewsAppBarState extends State<NewsAppBar> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  bool _isControllerInitialized = false;

  // TWITTER-LIKE АДАПТИВНЫЕ МЕТОДЫ
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1000) return 120; // Уменьшено для лучшего выравнивания
    if (width > 700) return 60;   // Для планшетов
    return 16;                    // Для мобильных
  }

  double _getContentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 600;
    if (width > 1000) return 600;
    if (width > 700) return 600;
    return double.infinity;
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _isControllerInitialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isControllerInitialized) {
        _searchController.text = widget.searchQuery;
      }
    });
  }

  @override
  void didUpdateWidget(NewsAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.searchQuery != oldWidget.searchQuery &&
        widget.searchQuery != _searchController.text) {
      _searchController.text = widget.searchQuery;
    }

    if (widget.isSearching && !oldWidget.isSearching) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    }

    if (!widget.isSearching && oldWidget.isSearching) {
      _searchFocusNode.unfocus();
      _searchController.clear();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _isControllerInitialized = false;
    super.dispose();
  }

  void _onSearchChanged(String text) {
    widget.onSearchChanged(text);
  }

  void _clearSearch() {
    _searchController.clear();
    widget.onSearchChanged('');
    _searchFocusNode.requestFocus();
  }

  List<Color> _getAvatarGradient(String name) {
    final colors = [
      [const Color(0xFF667eea), const Color(0xFF764ba2)],
      [const Color(0xFFf093fb), const Color(0xFFf5576c)],
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
      [const Color(0xFFfa709a), const Color(0xFFfee140)],
      [const Color(0xFF30cfd0), const Color(0xFF330867)],
    ];

    final index = name.isEmpty ? 0 : name.codeUnits.reduce((a, b) => a + b) % colors.length;
    return colors[index];
  }

  Widget _buildUserAvatar() {
    final gradientColors = _getAvatarGradient(widget.userName);
    final hasNewMessages = (widget.newMessagesCount ?? 0) > 0;
    final hasProfileImage = widget.profileImageUrl != null || widget.profileImageFile != null;

    return GestureDetector(
      onTap: widget.onProfilePressed,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: hasProfileImage ? null : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          image: _getProfileImageDecoration(),
          shape: BoxShape.circle,
          border: Border.all(
            color: hasNewMessages ? Colors.amber : Colors.white,
            width: hasNewMessages ? 1.2 : 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: (hasProfileImage ? Colors.black : gradientColors[0]).withOpacity(0.2),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: hasProfileImage ? null : Center(
          child: Text(
            widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  DecorationImage? _getProfileImageDecoration() {
    if (widget.profileImageFile != null) {
      return DecorationImage(
        image: FileImage(widget.profileImageFile!),
        fit: BoxFit.cover,
      );
    } else if (widget.profileImageUrl != null && widget.profileImageUrl!.isNotEmpty) {
      return DecorationImage(
        image: NetworkImage(widget.profileImageUrl!),
        fit: BoxFit.cover,
      );
    }
    return null;
  }

  Widget _buildClearFiltersButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: widget.hasActiveFilters ? 1.0 : 0.0,
        child: IgnorePointer(
          ignoring: !widget.hasActiveFilters,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onClearFilters,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.15),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.filter_alt_off_rounded,
                      size: 11,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'Очистить',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildSearchField() {
    return Expanded(
      child: Container(
        height: 32,
        margin: const EdgeInsets.only(right: 4),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          autofocus: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            hintText: 'Поиск новостей...',
            hintStyle: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.blue.withOpacity(0.25),
                width: 1.0,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Colors.blue,
              size: 14,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: Icon(
                Icons.clear_rounded,
                size: 14,
                color: Colors.blue.withOpacity(0.6),
              ),
              onPressed: _clearSearch,
              splashRadius: 12,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 28,
                minHeight: 28,
              ),
            )
                : null,
          ),
          style: TextStyle(
            color: Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          onChanged: _onSearchChanged,
        ),
      ),
    );
  }

  Widget _buildNormalTitle() {
    final hasNewMessages = (widget.newMessagesCount ?? 0) > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Text(
              'Лента новостей',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.black87,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.15),
                ),
              ),
              child: Text(
                'Beta',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 1),
        GestureDetector(
          onTap: widget.onProfilePressed,
          child: Row(
            children: [
              Icon(
                Icons.email_outlined,
                size: 9,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 2),
              Text(
                widget.userEmail,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (hasNewMessages) ...[
                const SizedBox(width: 2),
                Container(
                  width: 2.5,
                  height: 2.5,
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = _getHorizontalPadding(context);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.3,
      shadowColor: Colors.black.withOpacity(0.03),
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      title: widget.isSearching
          ? Row(
        children: [
          _buildSearchField(),
        ],
      )
          : _buildNormalTitle(),
      actions: [
        if (!widget.isSearching && widget.hasActiveFilters)
          _buildClearFiltersButton(),

        // Кнопка поиска/крестика
        Container(
          width: 32,
          height: 32,
          child: IconButton(
            icon: Icon(
              widget.isSearching ? Icons.close_rounded : Icons.search_rounded,
              color: Colors.blue,
              size: 16,
            ),
            onPressed: widget.onSearchToggled,
            tooltip: widget.isSearching ? 'Закрыть поиск' : 'Поиск',
            splashRadius: 16,
          ),
        ),

        // Аватар пользователя
        Padding(
          padding: const EdgeInsets.only(right: 8), // Фиксированный отступ справа
          child: _buildUserAvatar(),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(
          height: 0.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.blue.withOpacity(0.08),
                Colors.blue.withOpacity(0.03),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}