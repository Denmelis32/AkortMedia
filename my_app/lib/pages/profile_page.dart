import 'package:flutter/material.dart';
import 'package:my_app/pages/profile/profile_menu_page.dart' as enhanced_profile;


class ProfilePage extends StatelessWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const ProfilePage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    // Используй улучшенную версию профиля
    return enhanced_profile.ProfilePage(
      userName: userName,
      userEmail: userEmail,
      onLogout: onLogout,
      newMessagesCount: 0,
      onMessagesTap: () {
        // Обработчик сообщений
      },
      onSettingsTap: () {
        // Обработчик настроек
      },
      onHelpTap: () {
        // Обработчик помощи
      },
      onAboutTap: () {
        // Обработчик информации о приложении
      },
    );
  }
}