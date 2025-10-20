import 'package:flutter/material.dart';

class ProfileAppBar extends StatelessWidget {
  final bool showSearchBar;
  final TextEditingController searchController;
  final VoidCallback onBackPressed;
  final VoidCallback onSearchToggled;
  final VoidCallback onProfileMenuPressed;
  final Color userColor;

  const ProfileAppBar({
    super.key,
    required this.showSearchBar,
    required this.searchController,
    required this.onBackPressed,
    required this.onSearchToggled,
    required this.onProfileMenuPressed,
    required this.userColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back, color: userColor, size: 18),
            ),
            onPressed: onBackPressed,
          ),
          const SizedBox(width: 8),
          if (!showSearchBar) ...[
            Text(
              'Профиль',
              style: TextStyle(
                color: userColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
          ],
          if (showSearchBar)
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildSearchField()),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: userColor, size: 18),
                    ),
                    onPressed: onSearchToggled,
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.search, color: userColor, size: 18),
                  ),
                  onPressed: onSearchToggled,
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.more_vert, color: userColor, size: 18),
                  ),
                  onPressed: onProfileMenuPressed,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Поиск в профиле...',
          prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
            onPressed: () => searchController.clear(),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}