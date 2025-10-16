import 'package:flutter/material.dart';
import '../utils/screen_utils.dart';

class CustomAppBar extends StatelessWidget {
  final bool showSearchBar;
  final String searchQuery;
  final TextEditingController searchController;
  final int activeFiltersCount;
  final DateTime? selectedDate;
  final VoidCallback onSearchToggle;
  final VoidCallback onSearchCancel;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onCalendarTap;
  final VoidCallback onFiltersTap;
  final VoidCallback onMoreOptionsTap;

  const CustomAppBar({
    Key? key,
    required this.showSearchBar,
    required this.searchQuery,
    required this.searchController,
    required this.activeFiltersCount,
    required this.selectedDate,
    required this.onSearchToggle,
    required this.onSearchCancel,
    required this.onSearchChanged,
    required this.onCalendarTap,
    required this.onFiltersTap,
    required this.onMoreOptionsTap,
  }) : super(key: key);

  // 🆕 Метод для определения горизонтальных отступов как в CardsPage
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 200;
    if (width > 800) return 100;
    if (width > 600) return 60;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;
    final horizontalPadding = _getHorizontalPadding(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : horizontalPadding,
        vertical: 8, // 🆕 Такие же отступы как в CardsPage
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: _buildAppBarContent(context, isMobile),
    );
  }

  Widget _buildAppBarContent(BuildContext context, bool isMobile) {
    if (showSearchBar) {
      return _buildSearchAppBar(context);
    }

    return Row(
      children: [
        // 🆕 Заголовок слева как в CardsPage
        const Text(
          'Афиша', // 🆕 Изменил на "Афиша" вместо "События"
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),

        // 🆕 Кнопки действий как в CardsPage
        Row(
          children: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6), // 🆕 Такие же отступы
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search,
                  color: Colors.black,
                  size: 18, // 🆕 Такие же размеры иконок
                ),
              ),
              onPressed: onSearchToggle,
            ),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  activeFiltersCount > 0 ? Icons.filter_alt : Icons.filter_alt_outlined,
                  color: Colors.black,
                  size: 18,
                ),
              ),
              onPressed: onFiltersTap,
            ),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sort,
                  color: Colors.black,
                  size: 18,
                ),
              ),
              onPressed: onCalendarTap, // 🆕 Используем для сортировки
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAppBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildSearchField(),
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
          onPressed: onSearchCancel,
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 40, // 🆕 Такая же высота как в CardsPage
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20), // 🆕 Такие же скругления
      ),
      child: TextField(
        controller: searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Поиск событий...', // 🆕 Изменил текст
          prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
            onPressed: () => searchController.clear(),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        style: const TextStyle(fontSize: 16),
        onChanged: onSearchChanged,
      ),
    );
  }
}