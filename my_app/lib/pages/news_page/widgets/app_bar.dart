import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/news_theme.dart';

class NewsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String userEmail;
  final bool isSearching;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchToggled;
  final VoidCallback onProfilePressed;
  final VoidCallback? onClearFilters;
  final bool hasActiveFilters;
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
    this.hasActiveFilters = false,
    this.newMessagesCount = 0,
    this.profileImageUrl,
    this.profileImageFile,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  // АДАПТИВНЫЕ МЕТОДЫ ДЛЯ ОТСТУПОВ - ТАКИЕ ЖЕ КАК В ДРУГИХ СТРАНИЦАХ
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 200;
    if (width > 800) return 100;
    if (width > 600) return 60;
    return 0;
  }

  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <= 600;
  }

  // ФИКСИРОВАННАЯ МАКСИМАЛЬНАЯ ШИРИНА ДЛЯ ДЕСКТОПА
  double get _maxContentWidth => 1200;
  double get _minContentWidth => 320;

  // ОСНОВНОЙ LAYOUT С ФИКСИРОВАННОЙ ШИРИНОЙ
  Widget _buildDesktopLayout(Widget content) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _maxContentWidth,
          minWidth: _minContentWidth,
        ),
        child: content,
      ),
    );
  }

  Widget _buildUserAvatar() {
    final hasProfileImage = profileImageUrl != null || profileImageFile != null;

    if (hasProfileImage) {
      return GestureDetector(
        onTap: onProfilePressed,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1),
            image: _getProfileImageDecoration(),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.8),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      );
    } else {
      // Локальный аватар
      final name = userName.isNotEmpty ? userName : 'User';
      final firstLetter = name[0].toUpperCase();

      return GestureDetector(
        onTap: onProfilePressed,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF6366F1),
                Color(0xFF8B5CF6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.8),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              firstLetter,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    }
  }

  DecorationImage? _getProfileImageDecoration() {
    if (profileImageFile != null) {
      return DecorationImage(
        image: FileImage(profileImageFile!),
        fit: BoxFit.cover,
      );
    } else if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      return DecorationImage(
        image: NetworkImage(profileImageUrl!),
        fit: BoxFit.cover,
      );
    }
    return null;
  }

  Widget _buildSearchField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        autofocus: true,
        controller: TextEditingController(text: searchQuery),
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Поиск новостей...',
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 15),
          prefixIcon: Icon(Icons.search_rounded, size: 20, color: const Color(0xFF6366F1)),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear_rounded, size: 18, color: Colors.grey),
            onPressed: () => onSearchChanged(''),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        style: const TextStyle(fontSize: 15),
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.notifications_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
        if (newMessagesCount != null && newMessagesCount! > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                newMessagesCount! > 9 ? '9+' : newMessagesCount.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // КОМПАКТНЫЙ APP BAR В СТИЛЕ ДРУГИХ СТРАНИЦ
  Widget _buildCompactAppBar(BuildContext context, double horizontalPadding, bool isMobile) {
    // Вычисляем отступ для выравнивания с категориями
    final categoriesCardMargin = isMobile ? 12.0 : horizontalPadding;
    final categoriesContentPadding = isMobile ? 12.0 : 16.0;
    final categoriesTitlePadding = 4.0;

    // Общий отступ от левого края до текста "Категории"
    final totalCategoriesLeftPadding = categoriesCardMargin +
        categoriesContentPadding + categoriesTitlePadding;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : horizontalPadding,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isSearching
          ? _buildSearchAppBar(isMobile, horizontalPadding, totalCategoriesLeftPadding)
          : _buildMainAppBar(isMobile, horizontalPadding, totalCategoriesLeftPadding),
    );
  }

  Widget _buildMainAppBar(bool isMobile, double horizontalPadding, double totalCategoriesLeftPadding) {
    return Row(
      children: [
        // Заголовок "Лента новостей" с фоном и выравниванием по категориям
        Padding(
          padding: EdgeInsets.only(left: totalCategoriesLeftPadding - (isMobile ? 12 : horizontalPadding)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.newspaper_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Лента новостей',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        // Правый контент выровненный по правому краю категорий
        Container(
          margin: EdgeInsets.only(right: totalCategoriesLeftPadding - (isMobile ? 12 : horizontalPadding)),
          child: Row(
            children: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.search_rounded, color: Colors.white, size: 18),
                ),
                onPressed: onSearchToggled,
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: hasActiveFilters
                        ? Colors.white.withOpacity(0.3)
                        : Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasActiveFilters ? Icons.filter_alt_rounded : Icons.filter_alt_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                onPressed: () {
                  // Обработка фильтров
                },
              ),
              IconButton(
                icon: _buildNotificationButton(),
                onPressed: () {
                  // Обработка уведомлений
                },
              ),
              const SizedBox(width: 8),
              _buildUserAvatar(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAppBar(bool isMobile, double horizontalPadding, double totalCategoriesLeftPadding) {
    return Row(
      children: [
        // Поле поиска с выравниванием
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: totalCategoriesLeftPadding - (isMobile ? 12 : horizontalPadding),
              right: 8,
            ),
            child: _buildSearchField(),
          ),
        ),
        // Кнопка закрытия с выравниванием
        Padding(
          padding: EdgeInsets.only(right: totalCategoriesLeftPadding - (isMobile ? 12 : horizontalPadding)),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded, color: Colors.white, size: 18),
            ),
            onPressed: () {
              onSearchToggled();
              onSearchChanged('');
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = _getHorizontalPadding(context);
    final isMobile = _isMobile(context);

    // Для десктопа используем фиксированную ширину
    if (!isMobile) {
      return _buildDesktopLayout(
        _buildCompactAppBar(context, horizontalPadding, false),
      );
    }

    // Для мобильных используем обычный AppBar
    return AppBar(
      backgroundColor: const Color(0xFF6366F1),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 2,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6366F1),
              Color(0xFF8B5CF6),
            ],
          ),
        ),
      ),
      title: isSearching
          ? _buildSearchField()
          : Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Лента новостей',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (hasActiveFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.filter_alt_rounded, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'Фильтры',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: [
        if (!isSearching)
          Row(
            children: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: onSearchToggled,
              ),
              IconButton(
                icon: _buildNotificationButton(),
                onPressed: () {
                  // Обработка уведомлений
                },
              ),
              const SizedBox(width: 8),
              _buildUserAvatar(),
              const SizedBox(width: 8),
            ],
          ),
      ],
    );
  }
}