import 'package:flutter/material.dart';

import '../../utils/screen_utils.dart';

class SearchAppBar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onCancel;

  const SearchAppBar({
    Key? key,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmall = ScreenUtils.isSmallScreen(context);

    return Row(
      children: [
        Expanded(
          child: Container(
            height: isSmall ? 40 : 44,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(Icons.search, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Поиск событий, мест, категорий...',
                      hintStyle: TextStyle(fontSize: isSmall ? 14 : 16, color: Colors.grey[600]),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(fontSize: isSmall ? 14 : 16),
                  ),
                ),
                if (searchQuery.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.clear, size: 18, color: Colors.grey[600]),
                    onPressed: () {
                      searchController.clear();
                      onSearchChanged('');
                    },
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: onCancel,
          child: Text(
            'Отмена',
            style: TextStyle(
              fontSize: isSmall ? 14 : 16,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
}