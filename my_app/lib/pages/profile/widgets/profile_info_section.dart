import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileInfoSection extends StatefulWidget {
  final double contentMaxWidth;
  final String userName;
  final String userEmail;
  final int newMessagesCount;
  final VoidCallback? onMessagesTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onHelpTap;
  final VoidCallback? onAboutTap;
  final VoidCallback onLogout;
  final Color userColor; // НОВОЕ: цвет пользователя для темы

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
    required this.userColor, // НОВОЕ
  });

  @override
  State<ProfileInfoSection> createState() => _ProfileInfoSectionState();
}

class _ProfileInfoSectionState extends State<ProfileInfoSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  int _hoveredItem = -1;
  int _pressedItem = -1;

  final List<_ActionItem> _actionItems = [
    _ActionItem(
      'Сообщения',
      Icons.message_rounded,
      Colors.blue,
      'Общение с пользователями',
    ),
    _ActionItem(
      'Настройки',
      Icons.settings_rounded,
      Colors.purple,
      'Внешний вид и уведомления',
    ),
    _ActionItem(
      'Помощь',
      Icons.help_rounded,
      Colors.orange,
      'Частые вопросы и поддержка',
    ),
    _ActionItem(
      'О приложении',
      Icons.info_rounded,
      Colors.teal,
      'Версия и информация',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getAppVersion() {
    // Заглушка для получения версии приложения
    return '1.0.0 Beta';
  }

  String _getMessagesSubtitle() {
    if (widget.newMessagesCount == 0) {
      return 'Нет новых сообщений';
    } else if (widget.newMessagesCount == 1) {
      return '1 новое сообщение';
    } else if (widget.newMessagesCount < 5) {
      return '$widget.newMessagesCount новых сообщения';
    } else {
      return '$widget.newMessagesCount новых сообщений';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              constraints: BoxConstraints(maxWidth: widget.contentMaxWidth),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // НОВОЕ: Улучшенный заголовок
                      _buildHeaderSection(),
                      const SizedBox(height: 20),
                      // НОВОЕ: Сетка действий
                      _buildActionsGrid(),
                      const SizedBox(height: 20),
                      // НОВОЕ: Улучшенная кнопка выхода
                      _buildLogoutButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.userColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.account_circle_rounded, color: widget.userColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Управление аккаунтом',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Настройки и действия профиля',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // НОВОЕ: Быстрые действия
        _buildQuickActions(),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        // НОВОЕ: Копирование email
        _buildQuickActionButton(
          Icons.copy_rounded,
          'Скопировать email',
              () {
            Clipboard.setData(ClipboardData(text: widget.userEmail));
            _showSnackBar('Email скопирован в буфер');
          },
        ),
        const SizedBox(width: 8),
        // НОВОЕ: Поделиться профилем
        _buildQuickActionButton(
          Icons.share_rounded,
          'Поделиться профилем',
              () {
            _showSnackBar('Ссылка на профиль скопирована');
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Icon(icon, size: 18, color: Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  Widget _buildActionsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: _actionItems.length,
      itemBuilder: (context, index) {
        final item = _actionItems[index];
        return _buildActionCard(item, index);
      },
    );
  }

  Widget _buildActionCard(_ActionItem item, int index) {
    final isHovered = _hoveredItem == index;
    final isPressed = _pressedItem == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredItem = index),
      onExit: (_) => setState(() => _hoveredItem = -1),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressedItem = index),
        onTapUp: (_) => setState(() => _pressedItem = -1),
        onTapCancel: () => setState(() => _pressedItem = -1),
        onTap: _getActionCallback(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isPressed
                ? item.color.withOpacity(0.15)
                : isHovered
                ? item.color.withOpacity(0.08)
                : item.color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovered
                  ? item.color.withOpacity(0.3)
                  : item.color.withOpacity(0.2),
              width: isHovered ? 1.5 : 1,
            ),
            boxShadow: isHovered ? [
              BoxShadow(
                color: item.color.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ] : [],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Иконка
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(item.icon, color: item.color, size: 18),
                    ),
                    const SizedBox(height: 12),
                    // Заголовок
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Описание
                    Text(
                      _getActionSubtitle(item.title),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // НОВОЕ: Бейдж для сообщений
              if (item.title == 'Сообщения' && widget.newMessagesCount > 0)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      widget.newMessagesCount > 99 ? '99+' : widget.newMessagesCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getActionSubtitle(String title) {
    switch (title) {
      case 'Сообщения':
        return _getMessagesSubtitle();
      case 'Настройки':
        return 'Внешний вид, уведомления';
      case 'Помощь':
        return 'FAQ и поддержка';
      case 'О приложении':
        return 'Версия ${_getAppVersion()}';
      default:
        return '';
    }
  }

  VoidCallback? _getActionCallback(int index) {
    switch (index) {
      case 0: return widget.onMessagesTap;
      case 1: return widget.onSettingsTap;
      case 2: return widget.onHelpTap;
      case 3: return widget.onAboutTap;
      default: return null;
    }
  }

  Widget _buildLogoutButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onLogout,
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.red.withOpacity(0.2),
        highlightColor: Colors.red.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withOpacity(0.2)),
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
                child: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Выйти из аккаунта',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Завершить текущую сессию',
                      style: TextStyle(
                        color: Colors.red.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// НОВЫЙ КЛАСС: Информация о действии
class _ActionItem {
  final String title;
  final IconData icon;
  final Color color;
  final String description;

  const _ActionItem(this.title, this.icon, this.color, this.description);
}