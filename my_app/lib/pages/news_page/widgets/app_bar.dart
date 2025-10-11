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

  Widget _buildUserAvatar() {
    final hasProfileImage = profileImageUrl != null || profileImageFile != null;

    if (hasProfileImage) {
      return GestureDetector(
        onTap: onProfilePressed,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.blue,
            image: _getProfileImageDecoration(),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
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
            color: Colors.blue,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
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

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: isSearching
          ? _buildSearchField()
          : Row(
        children: [
          Text(
            'Лента новостей',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Beta',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (!isSearching)
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search,
                color: Colors.black,
                size: 18,
              ),
            ),
            onPressed: onSearchToggled,
          ),
        _buildUserAvatar(),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              autofocus: true,
              controller: TextEditingController(text: searchQuery),
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Поиск новостей...',
                prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                  onPressed: () => onSearchChanged(''),
                )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.black,
                size: 18,
              ),
            ),
            onPressed: onSearchToggled,
          ),
        ],
      ),
    );
  }
}