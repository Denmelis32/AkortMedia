import 'package:flutter/material.dart';
import '../theme/news_theme.dart';

class NewsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String userEmail;
  final bool isSearching;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchToggled;
  final VoidCallback onProfilePressed;

  const NewsAppBar({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.isSearching,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onSearchToggled,
    required this.onProfilePressed,
  });

  Widget _buildUserAvatar() {
    return GestureDetector(
      onTap: onProfilePressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [NewsTheme.primaryColor, NewsTheme.secondaryColor],
          ),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            userName[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: isSearching
          ? TextField(
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Поиск новостей...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: NewsTheme.textColor.withOpacity(0.5)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => onSearchChanged(''),
          ),
        ),
        style: const TextStyle(color: NewsTheme.textColor),
        onChanged: onSearchChanged,
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Новости',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: NewsTheme.textColor,
            ),
          ),
          Text(
            userEmail,
            style: const TextStyle(
              fontSize: 12,
              color: NewsTheme.secondaryTextColor,
            ),
          ),
        ],
      ),
      backgroundColor: NewsTheme.cardColor,
      elevation: 1,
      centerTitle: false,
      actions: [
        IconButton(
          icon: Icon(isSearching ? Icons.close : Icons.search),
          onPressed: onSearchToggled,
          color: NewsTheme.primaryColor,
        ),
        if (!isSearching) ...[
          const SizedBox(width: 8),
          _buildUserAvatar(),
          const SizedBox(width: 12),
        ]
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}