import 'package:flutter/material.dart';

class EditProfileModal extends StatefulWidget {
  final String currentBio;
  final String currentLocation;
  final String currentWebsite;
  final Function(String, String, String) onSave;

  const EditProfileModal({
    super.key,
    required this.currentBio,
    required this.currentLocation,
    required this.currentWebsite,
    required this.onSave,
  });

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  late TextEditingController _websiteController;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.currentBio);
    _locationController = TextEditingController(text: widget.currentLocation);
    _websiteController = TextEditingController(text: widget.currentWebsite);
  }

  @override
  void dispose() {
    _bioController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Заголовок
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Редактировать профиль',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Сохранить'),
                ),
              ],
            ),
          ),
          // Форма
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildFormField(
                    'Биография',
                    'Расскажите о себе...',
                    _bioController,
                    maxLines: 4,
                    icon: Icons.description_rounded,
                  ),
                  const SizedBox(height: 20),
                  _buildFormField(
                    'Местоположение',
                    'Ваш город или страна',
                    _locationController,
                    icon: Icons.location_on_rounded,
                  ),
                  const SizedBox(height: 20),
                  _buildFormField(
                    'Веб-сайт',
                    'https://example.com',
                    _websiteController,
                    icon: Icons.link_rounded,
                  ),
                  const SizedBox(height: 30),
                  _buildTipsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(
      String label,
      String hint,
      TextEditingController controller, {
        int maxLines = 1,
        IconData? icon,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              const Text(
                'Советы по заполнению',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Расскажите о своих интересах и увлечениях\n'
                '• Укажите реальное местоположение для поиска единомышленников\n'
                '• Добавьте ссылку на ваш блог или портфолио',
            style: TextStyle(
              color: Colors.blue[700],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _saveProfile() {
    final bio = _bioController.text.trim();
    final location = _locationController.text.trim();
    final website = _websiteController.text.trim();

    widget.onSave(
      bio.isEmpty ? 'Расскажите о себе...' : bio,
      location.isEmpty ? 'Город не указан' : location,
      website,
    );
    Navigator.pop(context);
  }
}