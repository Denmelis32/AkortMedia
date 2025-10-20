import 'package:flutter/material.dart';

class ProfileMenuModal extends StatelessWidget {
  final VoidCallback onShareProfile;
  final VoidCallback onShowQrCode;
  final VoidCallback onReport;
  final VoidCallback onEditProfile;

  const ProfileMenuModal({
    super.key,
    required this.onShareProfile,
    required this.onShowQrCode,
    required this.onReport,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDragHandle(),
            const SizedBox(height: 12),
            _buildMenuOption(
              Icons.edit_rounded,
              'Редактировать профиль',
              Colors.blue,
              onEditProfile,
            ),
            const SizedBox(height: 12),
            _buildMenuOption(
              Icons.share_rounded,
              'Поделиться профилем',
              Colors.green,
              onShareProfile,
            ),
            const SizedBox(height: 12),
            _buildMenuOption(
              Icons.qr_code_rounded,
              'QR-код профиля',
              Colors.purple,
              onShowQrCode,
            ),
            const SizedBox(height: 12),
            _buildMenuOption(
              Icons.report_rounded,
              'Пожаловаться',
              Colors.orange,
              onReport,
            ),
            const SizedBox(height: 20),
            _buildCancelButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildMenuOption(IconData icon, String text, Color color, VoidCallback onTap) {
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
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 16),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.pop(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.grey[700],
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text('Отмена'),
      ),
    );
  }
}