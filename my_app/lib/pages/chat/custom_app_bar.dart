// lib/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color backgroundColor;
  final double elevation;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor = Colors.white,
    this.elevation = 0,
  });

  // Метод для получения отступов адаптированных под телефоны
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 200;
    if (width > 800) return 100;
    if (width > 600) return 60;
    if (width > 400) return 16;  // средние телефоны
    return 12; // маленькие телефоны
  }

  // Адаптивный размер шрифта
  double _getTitleFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) return 20;
    if (width > 400) return 18;
    return 16; // маленькие телефоны
  }

  // Адаптивный размер иконки
  double _getIconSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) return 18;
    return 16; // телефоны
  }

  // Адаптивный паддинг иконки
  EdgeInsets _getIconPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) return const EdgeInsets.all(6);
    return const EdgeInsets.all(5); // телефоны
  }

  // Адаптивная высота AppBar
  double _getAppBarHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) return kToolbarHeight;
    return 56; // стандартная высота для мобильных
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;
    final horizontalPadding = _getHorizontalPadding(context);
    final titleFontSize = _getTitleFontSize(context);
    final iconSize = _getIconSize(context);
    final iconPadding = _getIconPadding(context);
    final appBarHeight = _getAppBarHeight(context);

    return Container(
      height: appBarHeight,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          if (elevation > 0)
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              icon: Container(
                padding: iconPadding,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, color: Colors.black, size: iconSize),
              ),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
            ),
          if (showBackButton)
            SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.black,
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actions != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: actions!
                  .map((action) => Padding(
                padding: EdgeInsets.only(left: isMobile ? 8 : 12),
                child: action,
              ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}