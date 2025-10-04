// utils/community_navigation.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../rooms_pages/community_detail_page.dart';
import '../models/community.dart';
import '../../../providers/user_provider.dart';
import '../widgets/create_community_bottom_sheet.dart';

class CommunityNavigation {
  void createNewCommunity(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateCommunityBottomSheet(
        onCommunityCreated: (newCommunity) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Сообщество "${newCommunity.name}" создано! 🎉'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Открыть',
                onPressed: () {
                  openCommunityDetail(
                    context: context,
                    community: newCommunity,
                    selectedTab: 0,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void openCommunityDetail({
    required BuildContext context,
    required Community community,
    required int selectedTab,
  }) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => CommunityDetailPage(
          community: community,
          initialTab: selectedTab,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutQuart;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void joinCommunity(BuildContext context, Community community) {
    final userProvider = context.read<UserProvider>();

    // TODO: Реализовать логику присоединения к сообществу
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Вы присоединились к сообществу "${community.name}" 🎉'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Открыть',
          onPressed: () {
            openCommunityDetail(
              context: context,
              community: community,
              selectedTab: 0,
            );
          },
        ),
      ),
    );
  }

  void leaveCommunity(BuildContext context, Community community) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Покинуть сообщество'),
        content: Text('Вы уверены, что хотите покинуть сообщество "${community.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Реализовать логику выхода из сообщества
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Вы покинули сообщество "${community.name}"'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Покинуть'),
          ),
        ],
      ),
    );
  }

  void shareCommunity(BuildContext context, Community community) {
    // TODO: Реализовать шаринг сообщества
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ссылка на сообщество "${community.name}" скопирована'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void reportCommunity(BuildContext context, Community community) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Пожаловаться на сообщество'),
        content: const Text('Выберите причину жалобы:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Жалоба отправлена модераторам'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Отправить'),
          ),
        ],
      ),
    );
  }

  void showCommunityQuickActions(BuildContext context, Community community) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_rounded),
              title: const Text('Информация о сообществе'),
              onTap: () {
                Navigator.pop(context);
                _showCommunityInfo(context, community);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded),
              title: const Text('Поделиться'),
              onTap: () {
                Navigator.pop(context);
                shareCommunity(context, community);
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_rounded),
              title: const Text('Пожаловаться'),
              onTap: () {
                Navigator.pop(context);
                reportCommunity(context, community);
              },
            ),
            if (community.canManage)
              ListTile(
                leading: const Icon(Icons.settings_rounded),
                title: const Text('Управление'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Переход к управлению сообществом
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showCommunityInfo(BuildContext context, Community community) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(community.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Категория: ${community.category}'),
              const SizedBox(height: 8),
              Text('Участников: ${community.memberCount}'),
              const SizedBox(height: 8),
              Text('Создано: ${community.formattedCreatedAt}'),
              if (community.rules != null) ...[
                const SizedBox(height: 8),
                const Text('Правила:'),
                Text(community.rules!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}