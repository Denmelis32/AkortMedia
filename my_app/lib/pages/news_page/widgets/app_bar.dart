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
  final VoidCallback? onAdvancedSearchPressed;
  final bool hasActiveFilters;
  final int? unreadNotificationsCount;
  final List<String>? recentSearches;
  final ValueChanged<String>? onRecentSearchSelected;
  final int? newMessagesCount;
  final String? profileImageUrl; // Новое: URL фото профиля
  final File? profileImageFile; // Новое: файл с фото профиля

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
    this.profileImageUrl, // Новое: URL фото
    this.profileImageFile, // Новое: файл фото
  });

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
    final gradientColors = _getAvatarGradient(userName);
    final hasNewMessages = (newMessagesCount ?? 0) > 0;
    final hasProfileImage = profileImageUrl != null || profileImageFile != null;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onProfilePressed,
        child: Stack(
          children: [
            // Основной контейнер аватара
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 46,
              height: 46,
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
                  width: hasNewMessages ? 3.0 : 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (hasProfileImage ? Colors.black : gradientColors[0]).withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: hasProfileImage ? null : Center(
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black26,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Бейдж онлайн-статуса
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: NewsTheme.cardColor,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),

            // Бейдж новых сообщений
            if (hasNewMessages)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: newMessagesCount! > 9 ? 22 : 20,
                  height: newMessagesCount! > 9 ? 22 : 20,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: NewsTheme.cardColor,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      newMessagesCount! > 9 ? '9+' : newMessagesCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),

            // Иконка камеры для фото профиля
            if (hasProfileImage)
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: NewsTheme.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: NewsTheme.cardColor,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.photo_camera_rounded,
                    size: 8,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
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

  // Остальные методы без изменений
  Widget _buildClearFiltersButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: hasActiveFilters ? 1.0 : 0.0,
        child: IgnorePointer(
          ignoring: !hasActiveFilters,
          child: Material(
            color: NewsTheme.primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onClearFilters,
              borderRadius: BorderRadius.circular(12),
              splashColor: NewsTheme.primaryColor.withOpacity(0.2),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.filter_alt_off_rounded,
                      size: 16,
                      color: NewsTheme.primaryColor,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Очистить',
                      style: TextStyle(
                        color: NewsTheme.primaryColor,
                        fontSize: 12,
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

  Widget _buildSearchField(BuildContext context) {
    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        autofocus: true,
        controller: TextEditingController(text: searchQuery),
        decoration: InputDecoration(
          filled: true,
          fillColor: NewsTheme.backgroundColor.withOpacity(0.9),
          hintText: 'Поиск новостей, авторов, хештегов...',
          hintStyle: TextStyle(
            color: NewsTheme.secondaryTextColor.withOpacity(0.7),
            fontSize: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: NewsTheme.primaryColor.withOpacity(0.4),
              width: 2.0,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: NewsTheme.primaryColor,
            size: 20,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (searchQuery.isNotEmpty)
                _buildAnimatedIconButton(
                  icon: Icons.clear_rounded,
                  onPressed: () => onSearchChanged(''),
                  tooltip: 'Очистить',
                ),
              if (searchQuery.isNotEmpty)
                Container(
                  width: 1,
                  height: 20,
                  color: NewsTheme.secondaryTextColor.withOpacity(0.2),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                ),
              _buildAnimatedIconButton(
                icon: Icons.filter_list_rounded,
                onPressed: onAdvancedSearchPressed,
                tooltip: 'Расширенный поиск',
              ),
            ],
          ),
        ),
        style: TextStyle(
          color: NewsTheme.textColor,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        onChanged: onSearchChanged,
        onSubmitted: (value) {
          FocusScope.of(context).unfocus();
        },
      ),
    );
  }

  Widget _buildAnimatedIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: tooltip,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: onPressed != null
                ? NewsTheme.primaryColor.withOpacity(0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: Icon(
              icon,
              size: 18,
              color: onPressed != null
                  ? NewsTheme.primaryColor.withOpacity(0.8)
                  : NewsTheme.secondaryTextColor.withOpacity(0.4),
            ),
            onPressed: onPressed,
            splashRadius: 18,
            padding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildNormalTitle() {
    final hasNewMessages = (newMessagesCount ?? 0) > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  NewsTheme.primaryColor,
                  NewsTheme.primaryColor.withOpacity(0.7),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds),
              child: const Text(
                'Лента новостей',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  color: Colors.white,
                  letterSpacing: -0.8,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    NewsTheme.primaryColor.withOpacity(0.9),
                    NewsTheme.primaryColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: NewsTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'Beta',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onProfilePressed,
            child: Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 12,
                  color: NewsTheme.secondaryTextColor.withOpacity(0.7),
                ),
                const SizedBox(width: 6),
                Text(
                  userEmail,
                  style: TextStyle(
                    fontSize: 13,
                    color: NewsTheme.secondaryTextColor.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (hasNewMessages) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActionButtons() {
    return [
      if (!isSearching && hasActiveFilters)
        _buildClearFiltersButton(),

      Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSearching
                  ? NewsTheme.primaryColor.withOpacity(0.15)
                  : NewsTheme.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: isSearching
                  ? Border.all(color: NewsTheme.primaryColor.withOpacity(0.3))
                  : null,
            ),
            child: IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isSearching ? Icons.close_rounded : Icons.search_rounded,
                  key: ValueKey<bool>(isSearching),
                  color: isSearching
                      ? NewsTheme.primaryColor
                      : NewsTheme.primaryColor.withOpacity(0.9),
                  size: 22,
                ),
              ),
              onPressed: onSearchToggled,
              tooltip: isSearching ? 'Закрыть поиск' : 'Поиск',
              splashRadius: 20,
            ),
          ),
        ),
      ),

      if (!isSearching) ...[
        const SizedBox(width: 8),
        _buildUserAvatar(),
        const SizedBox(width: 12),
      ]
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: isSearching ? _buildSearchField(context) : _buildNormalTitle(),
      backgroundColor: NewsTheme.cardColor,
      elevation: 1.0,
      shadowColor: Colors.black.withOpacity(0.1),
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      actions: _buildActionButtons(),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                NewsTheme.primaryColor.withOpacity(0.2),
                NewsTheme.primaryColor.withOpacity(0.1),
                NewsTheme.primaryColor.withOpacity(0.05),
                Colors.transparent,
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(0),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}