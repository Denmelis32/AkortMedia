import 'package:flutter/material.dart';

class RoomsPage extends StatelessWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const RoomsPage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Страница комнат\nЗдесь будут чат-комнаты для обсуждения',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: Colors.grey[600]),
        ),
      ),
    );
  }
}