import 'package:flutter/material.dart';

class ProfileInfoSection extends StatelessWidget {
  final double contentMaxWidth;
  final String userName;
  final String userEmail;
  final int newMessagesCount;
  final VoidCallback? onMessagesTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onHelpTap;
  final VoidCallback? onAboutTap;
  final VoidCallback onLogout;

  const ProfileInfoSection({
    super.key,
    required this.contentMaxWidth,
    required this.userName,
    required this.userEmail,
    required this.newMessagesCount,
    this.onMessagesTap,
    this.onSettingsTap,
    this.onHelpTap,
    this.onAboutTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: contentMaxWidth),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildActionItem(
                'Сообщения',
                'Новых: $newMessagesCount',
                Icons.message_rounded,
                Colors.blue,
                    () => onMessagesTap?.call(),
              ),
              const SizedBox(height: 12),
              _buildActionItem(
                'Настройки',
                'Внешний вид, уведомления',
                Icons.settings_rounded,
                Colors.purple,
                    () => onSettingsTap?.call(),
              ),
              const SizedBox(height: 12),
              _buildActionItem(
                'Помощь',
                'Частые вопросы и поддержка',
                Icons.help_rounded,
                Colors.orange,
                    () => onHelpTap?.call(),
              ),
              const SizedBox(height: 12),
              _buildActionItem(
                'О приложении',
                'Версия 1.0.0 Beta',
                Icons.info_rounded,
                Colors.teal,
                    () => onAboutTap?.call(),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Colors.red),
                  title: const Text(
                    'Выйти из аккаунта',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.red),
                  onTap: onLogout,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem(
      String title,
      String subtitle,
      IconData icon,
      Color color,
      VoidCallback? onTap,
      ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.withOpacity(0.6)),
            ],
          ),
        ),
      ),
    );
  }
}