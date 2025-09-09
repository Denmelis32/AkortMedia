import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String userName;
  final String userEmail;

  const ProfilePage({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        centerTitle: true,
        backgroundColor: const Color(0xFFA31525),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView( // Добавляем прокрутку
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Аватар пользователя
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFFA31525),
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

            // Статистика
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('23', 'Постов'),
                _buildStatItem('156', 'Лайков'),
                _buildStatItem('42', 'Комментариев'),
              ],
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
                _buildProfileButton(
                  icon: Icons.exit_to_app,
                  text: 'Выйти',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: Colors.red,
                ),
              ],
            ),

            // Добавляем дополнительное пространство внизу
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
            color: Color(0xFFA31525),
          ),
        ),
        const SizedBox(height: 4), // Добавляем отступ
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
      margin: const EdgeInsets.only(bottom: 8), // Уменьшаем отступ
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: color ?? const Color(0xFFA31525),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Уменьшаем padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Уменьшаем скругление
            side: BorderSide(color: Colors.grey[300]!),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Изменяем на min
          children: [
            Icon(icon, size: 20), // Уменьшаем размер иконки
            const SizedBox(width: 12),
            Expanded( // Добавляем Expanded для текста
              child: Text(
                text,
                style: const TextStyle(fontSize: 14), // Уменьшаем размер текста
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14), // Уменьшаем стрелку
          ],
        ),
      ),
    );
  }
}