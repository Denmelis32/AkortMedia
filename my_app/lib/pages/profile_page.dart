// lib/pages/profile_page.dart
import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Аватар пользователя
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Имя пользователя
            Text(
              userName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Email
            Text(
              userEmail,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Статистика в карточках
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('23', 'Тем'),
                    _buildStatItem('156', 'Сообщений'),
                    _buildStatItem('42', 'Лайков'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Настройки профиля
            Column(
              children: [
                _buildProfileButton(
                  icon: Icons.edit,
                  text: 'Редактировать профиль',
                  onPressed: () {},
                ),
                _buildProfileButton(
                  icon: Icons.notifications,
                  text: 'Уведомления',
                  onPressed: () {},
                ),
                _buildProfileButton(
                  icon: Icons.settings,
                  text: 'Настройки',
                  onPressed: () {},
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 2,
                  color: Colors.red[50],
                  child: _buildProfileButton(
                    icon: Icons.exit_to_app,
                    text: 'Выйти из аккаунта',
                    onPressed: onLogout,
                    color: Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 1),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: color ?? Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color ?? Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: color ?? Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}