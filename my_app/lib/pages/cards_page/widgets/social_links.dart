import 'package:flutter/material.dart';
import '../models/channel.dart';

class SocialLinks extends StatelessWidget {
  final Channel channel;

  const SocialLinks({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'СОЦИАЛЬНЫЕ СЕТИ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildSocialButton(Icons.link, 'Website'),
            const SizedBox(width: 8),
            _buildSocialButton(Icons.youtube_searched_for, 'YouTube'),
            const SizedBox(width: 8),
            _buildSocialButton(Icons.telegram, 'Telegram'),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 16),
        label: Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}