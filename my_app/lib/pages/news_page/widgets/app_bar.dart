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

  // Адаптивные методы как в CardsPage
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 700) return 80;
    return 16;
  }

  double _getContentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 1200;
    if (width > 1000) return 900;
    if (width > 700) return 700;
    return double.infinity;
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _isControllerInitialized = true;

    // Устанавливаем начальное значение после инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isControllerInitialized) {
        _searchController.text = widget.searchQuery;
      }
    });
  }

  @override
  void didUpdateWidget(NewsAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Синхронизируем только если query изменился извне (например, при очистке фильтров)
    // Но не синхронизируем при обычном вводе текста пользователем
    if (widget.searchQuery != oldWidget.searchQuery &&
        widget.searchQuery != _searchController.text) {
      _searchController.text = widget.searchQuery;
    }

    // Автофокус при включении поиска
    if (widget.isSearching && !oldWidget.isSearching) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    }

    // Сброс фокуса при выключении поиска
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
    // Просто передаем изменения в родительский компонент
    // Не обновляем контроллер здесь - он уже содержит правильный текст
    widget.onSearchChanged(text);
  }

  void _clearSearch() {
    _searchController.clear();
    widget.onSearchChanged('');
    _searchFocusNode.requestFocus();
  }

  // Генерация градиента для аватара на основе имени пользователя
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
        width: 36,
        height: 36,
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
            width: hasNewMessages ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: (hasProfileImage ? Colors.black : gradientColors[0]).withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: hasProfileImage ? null : Center(
          child: Text(
            widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
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
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: widget.hasActiveFilters ? 1.0 : 0.0,
        child: IgnorePointer(
          ignoring: !widget.hasActiveFilters,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onClearFilters,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.filter_alt_off_rounded,
                      size: 12,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Очистить',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 10,
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
        height: 36,
        margin: const EdgeInsets.only(right: 6),
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
              fontSize: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.blue.withOpacity(0.3),
                width: 1.2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Colors.blue,
              size: 16,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: Icon(
                Icons.clear_rounded,
                size: 16,
                color: Colors.blue.withOpacity(0.7),
              ),
              onPressed: _clearSearch,
              splashRadius: 14,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            )
                : null,
          ),
          style: TextStyle(
            color: Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          onChanged: _onSearchChanged,
        ),
      ),
    );
  }

  Widget _buildNormalTitle() {
    final hasNewMessages = (widget.newMessagesCount ?? 0) > 0;
    final horizontalPadding = _getHorizontalPadding(context);

    return Padding(
      padding: EdgeInsets.only(left: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(
                'Лента новостей',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.black87,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  'Beta',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 9,
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
                  size: 10,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 3),
                Text(
                  widget.userEmail,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (hasNewMessages) ...[
                  const SizedBox(width: 3),
                  Container(
                    width: 3,
                    height: 3,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = _getHorizontalPadding(context);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      shadowColor: Colors.black.withOpacity(0.05),
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      title: widget.isSearching
          ? Padding(
        padding: EdgeInsets.only(left: horizontalPadding),
        child: Row(
          children: [
            _buildSearchField(),
          ],
        ),
      )
          : _buildNormalTitle(),
      actions: [
        if (!widget.isSearching && widget.hasActiveFilters)
          _buildClearFiltersButton(),

        // Кнопка поиска/крестика
        Container(
          width: 36,
          height: 36,
          child: IconButton(
            icon: Icon(
              widget.isSearching ? Icons.close_rounded : Icons.search_rounded,
              color: Colors.blue,
              size: 18,
            ),
            onPressed: widget.onSearchToggled,
            tooltip: widget.isSearching ? 'Закрыть поиск' : 'Поиск',
            splashRadius: 18,
          ),
        ),

        // Аватар пользователя
        Padding(
          padding: EdgeInsets.only(right: horizontalPadding),
          child: _buildUserAvatar(),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.blue.withOpacity(0.1),
                Colors.blue.withOpacity(0.05),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}