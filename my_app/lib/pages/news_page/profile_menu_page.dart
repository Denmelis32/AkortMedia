import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:my_app/pages/news_page/theme/news_theme.dart';

class ProfilePage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;
  final int? newMessagesCount;
  final String? profileImageUrl;
  final File? profileImageFile;
  final Function(String?)? onProfileImageUrlChanged;
  final Function(File?)? onProfileImageFileChanged;
  final VoidCallback? onMessagesTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onHelpTap;
  final VoidCallback? onAboutTap;
  final VoidCallback? onBack;

  const ProfilePage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
    this.newMessagesCount = 0,
    this.profileImageUrl,
    this.profileImageFile,
    this.onProfileImageUrlChanged,
    this.onProfileImageFileChanged,
    this.onMessagesTap,
    this.onSettingsTap,
    this.onHelpTap,
    this.onAboutTap,
    this.onBack,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NewsTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Заголовок с кнопкой назад
            Container(
              decoration: BoxDecoration(
                color: NewsTheme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: NewsTheme.primaryColor,
                        size: 20,
                      ),
                      onPressed: () {
                        widget.onBack?.call();
                        Navigator.pop(context);
                      },
                      splashRadius: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Профиль',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: NewsTheme.textColor,
                      ),
                    ),
                    const Spacer(),
                    if (widget.newMessagesCount != null && widget.newMessagesCount! > 0)
                      _buildMessageBadge(widget.newMessagesCount!),
                  ],
                ),
              ),
            ),

            // Основное содержимое
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Аватар и информация
                    Column(
                      children: [
                        _buildProfileAvatar(context),
                        const SizedBox(height: 16),
                        Text(
                          widget.userName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: NewsTheme.textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.userEmail,
                          style: TextStyle(
                            fontSize: 16,
                            color: NewsTheme.secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Online',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Меню опций
                    _buildMenuSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context) {
    final gradientColors = _getAvatarGradient(widget.userName);
    final hasProfileImage = widget.profileImageUrl != null || widget.profileImageFile != null;

    return GestureDetector(
      onTap: () => _showImagePickerModal(context),
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: hasProfileImage ? null : LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              image: _getProfileImageDecoration(),
              shape: BoxShape.circle,
              border: Border.all(
                color: NewsTheme.primaryColor,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: (hasProfileImage ? Colors.black : gradientColors[0]).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: hasProfileImage ? null : Center(
              child: Text(
                widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: NewsTheme.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.edit_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    final hasNewMessages = (widget.newMessagesCount ?? 0) > 0;

    return Column(
      children: [
        _buildMenuButton(
          icon: Icons.message_rounded,
          text: 'Сообщения',
          subtitle: hasNewMessages ? '${widget.newMessagesCount} новых сообщений' : 'Нет новых сообщений',
          onTap: () => _handleMessagesTap(context),
          iconColor: Colors.blue,
          trailing: hasNewMessages ? _buildMessageBadge(widget.newMessagesCount!) : null,
        ),

        _buildMenuButton(
          icon: Icons.settings_rounded,
          text: 'Настройки',
          subtitle: 'Внешний вид, уведомления',
          onTap: () => _handleSettingsTap(context),
          iconColor: Colors.purple,
        ),

        _buildMenuButton(
          icon: Icons.help_rounded,
          text: 'Помощь',
          subtitle: 'Частые вопросы и поддержка',
          onTap: () => _handleHelpTap(context),
          iconColor: Colors.orange,
        ),

        _buildMenuButton(
          icon: Icons.info_rounded,
          text: 'О приложении',
          subtitle: 'Версия 1.0.0 Beta',
          onTap: () => _handleAboutTap(context),
          iconColor: Colors.teal,
        ),

        const SizedBox(height: 24),

        // Кнопка выхода
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleLogout(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Выйти из аккаунта',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.red.withOpacity(0.6),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String text,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: NewsTheme.secondaryTextColor.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (iconColor ?? NewsTheme.primaryColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? NewsTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: TextStyle(
                          color: NewsTheme.textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: NewsTheme.secondaryTextColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing,
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: NewsTheme.secondaryTextColor.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count > 9 ? '9+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // Остальные методы остаются без изменений
  void _handleMessagesTap(BuildContext context) {
    widget.onMessagesTap?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Переход к сообщениям'),
        backgroundColor: NewsTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleSettingsTap(BuildContext context) {
    widget.onSettingsTap?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Переход к настройкам'),
        backgroundColor: NewsTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleHelpTap(BuildContext context) {
    widget.onHelpTap?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Переход к разделу помощи'),
        backgroundColor: NewsTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleAboutTap(BuildContext context) {
    widget.onAboutTap?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Информация о приложении'),
        backgroundColor: NewsTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    widget.onLogout();
  }

  // Методы для работы с изображениями остаются без изменений
  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null && widget.onProfileImageFileChanged != null) {
        widget.onProfileImageFileChanged!(File(image.path));
        if (widget.onProfileImageUrlChanged != null) {
          widget.onProfileImageUrlChanged!(null);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Фото профиля обновлено'),
              backgroundColor: NewsTheme.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: NewsTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _showImagePickerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: NewsTheme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Выберите фото профиля',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: NewsTheme.textColor,
                ),
              ),
              const SizedBox(height: 20),

              _buildImageSourceButton(
                context,
                Icons.link_rounded,
                'Загрузить по ссылке',
                Colors.purple,
                    () => _showUrlInputDialog(context),
              ),

              const SizedBox(height: 12),

              _buildImageSourceButton(
                context,
                Icons.photo_library_rounded,
                'Выбрать из галереи',
                Colors.blue,
                    () => _pickImage(ImageSource.gallery, context),
              ),

              const SizedBox(height: 12),

              _buildImageSourceButton(
                context,
                Icons.photo_camera_rounded,
                'Сделать фото',
                Colors.green,
                    () => _pickImage(ImageSource.camera, context),
              ),

              const SizedBox(height: 12),

              if (widget.profileImageUrl != null || widget.profileImageFile != null)
                _buildImageSourceButton(
                  context,
                  Icons.delete_rounded,
                  'Удалить фото',
                  Colors.red,
                      () {
                    if (widget.onProfileImageFileChanged != null) {
                      widget.onProfileImageFileChanged!(null);
                    }
                    if (widget.onProfileImageUrlChanged != null) {
                      widget.onProfileImageUrlChanged!(null);
                    }
                    Navigator.pop(context);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Фото профиля удалено'),
                          backgroundColor: NewsTheme.successColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  },
                ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: NewsTheme.secondaryTextColor,
                    side: BorderSide(color: NewsTheme.secondaryTextColor.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Отмена'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceButton(
      BuildContext context,
      IconData icon,
      String text,
      Color color,
      VoidCallback onTap,
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
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 16),
              Text(
                text,
                style: TextStyle(
                  color: NewsTheme.textColor,
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

  void _showUrlInputDialog(BuildContext context) {
    final TextEditingController urlController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: NewsTheme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Введите ссылку на фото',
            style: TextStyle(
              color: NewsTheme.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(NewsTheme.primaryColor),
                  ),
                ),
              TextField(
                controller: urlController,
                decoration: InputDecoration(
                  hintText: 'https://example.com/photo.jpg',
                  hintStyle: TextStyle(
                    color: NewsTheme.secondaryTextColor.withOpacity(0.6),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: NewsTheme.secondaryTextColor.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: NewsTheme.primaryColor),
                  ),
                ),
                style: TextStyle(color: NewsTheme.textColor),
              ),
              if (!isLoading) ...[
                const SizedBox(height: 12),
                Text(
                  'Поддерживаются: JPG, PNG, WebP',
                  style: TextStyle(
                    color: NewsTheme.secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text(
                'Отмена',
                style: TextStyle(color: NewsTheme.secondaryTextColor),
              ),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                final url = urlController.text.trim();
                if (url.isNotEmpty && widget.onProfileImageUrlChanged != null) {
                  setState(() => isLoading = true);

                  try {
                    String validatedUrl = url;
                    if (!url.startsWith('http')) {
                      validatedUrl = 'https://$url';
                    }

                    final testResponse = await http.get(Uri.parse(validatedUrl));
                    if (testResponse.statusCode == 200) {
                      widget.onProfileImageUrlChanged!(validatedUrl);
                      if (widget.onProfileImageFileChanged != null) {
                        widget.onProfileImageFileChanged!(null);
                      }

                      Navigator.pop(context);
                      Navigator.pop(context);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Фото загружено по ссылке'),
                            backgroundColor: NewsTheme.successColor,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    } else {
                      throw Exception('HTTP ${testResponse.statusCode}');
                    }
                  } catch (e) {
                    setState(() => isLoading = false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ошибка загрузки: $e'),
                          backgroundColor: NewsTheme.errorColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: NewsTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isLoading
                  ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text(
                'Загрузить',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DecorationImage? _getProfileImageDecoration() {
    if (widget.profileImageFile != null) {
      return DecorationImage(
        image: FileImage(widget.profileImageFile!),
        fit: BoxFit.cover,
      );
    } else if (widget.profileImageUrl != null && widget.profileImageUrl!.isNotEmpty) {
      return DecorationImage(
        image: NetworkImage(widget.profileImageUrl!),
        fit: BoxFit.cover,
        onError: (exception, stackTrace) {
          print('❌ Error loading profile image from URL: $exception');
        },
      );
    }
    return null;
  }

  List<Color> _getAvatarGradient(String name) {
    final colors = [
      [const Color(0xFF667eea), const Color(0xFF764ba2)],
      [const Color(0xFFf093fb), const Color(0xFFf5576c)],
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
      [const Color(0xFFfa709a), const Color(0xFFfee140)],
      [const Color(0xFF30cfd0), const Color(0xFF330867)],
    ];

    final index = name.isEmpty ? 0 : name.codeUnits.reduce((a, b) => a + b) % colors.length;
    return colors[index];
  }
}