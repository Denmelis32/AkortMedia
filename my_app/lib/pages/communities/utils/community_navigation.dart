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
}