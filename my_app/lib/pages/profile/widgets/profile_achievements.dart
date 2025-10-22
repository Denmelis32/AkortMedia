import 'package:flutter/material.dart';
import '../utils/profile_utils.dart';

class ProfileAchievements extends StatefulWidget {
  final Map<String, dynamic> achievements;
  final double contentMaxWidth;
  final Color userColor;
  final Map<String, int>? progressData;

  const ProfileAchievements({
    super.key,
    required this.achievements,
    required this.contentMaxWidth,
    required this.userColor,
    this.progressData,
  });

  @override
  State<ProfileAchievements> createState() => _ProfileAchievementsState();
}

class _ProfileAchievementsState extends State<ProfileAchievements> {
  bool _isExpanded = false;

  final Map<String, _AchievementInfo> _achievementConfig = {
    'first_post': _AchievementInfo(
      '🎯 Первый пост',
      'Опубликуйте свой первый пост',
      Icons.create_rounded,
      1,
      'Создайте первую публикацию в ленте',
    ),
    'popular_author': _AchievementInfo(
      '📈 Популярный автор',
      'Соберите 100 лайков',
      Icons.trending_up_rounded,
      100,
      'Ваши посты нравятся сообществу',
    ),
    'active_commenter': _AchievementInfo(
      '💬 Активный комментатор',
      'Оставьте 50 комментариев',
      Icons.chat_bubble_rounded,
      50,
      'Активно участвуйте в обсуждениях',
    ),
    'week_streak': _AchievementInfo(
      '🔥 Неделя активности',
      'Будьте активны 7 дней подряд',
      Icons.local_fire_department_rounded,
      7,
      'Регулярная активность в приложении',
    ),
    'social_butterfly': _AchievementInfo(
      '🦋 Социальная бабочка',
      'Получите 10 подписчиков',
      Icons.people_alt_rounded,
      10,
      'Расширяйте свою аудиторию',
    ),
    'early_adopter': _AchievementInfo(
      '🚀 Первопроходец',
      'Будьте в приложении с первого дня',
      Icons.rocket_launch_rounded,
      1,
      'Осваивайте новые функции первым',
    ),
  };

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  int _getCurrentProgress(String achievementId) {
    return widget.progressData?[achievementId] ?? 0;
  }

  double _getProgressPercentage(String achievementId) {
    final config = _achievementConfig[achievementId]!;
    final progress = _getCurrentProgress(achievementId);
    return progress / config.goal;
  }

  @override
  Widget build(BuildContext context) {
    final utils = ProfileUtils();
    final isMobile = ProfileUtils.isMobile(context);

    final achievedCount = widget.achievements.values.where((achieved) => achieved == true).length;
    final totalCount = widget.achievements.length;

    return Container(
      constraints: BoxConstraints(maxWidth: widget.contentMaxWidth),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
          ],
        ),
        borderRadius: utils.getAdaptiveBorderRadius(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: utils.getAdaptiveValue(context, mobile: 12, tablet: 14, desktop: 16),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: utils.getAdaptivePadding(context),
        child: Column(
          children: [
            _buildHeaderSection(utils, context, achievedCount, totalCount),
            if (_isExpanded)
              _buildAchievementsContent(utils, context, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(ProfileUtils utils, BuildContext context, int achievedCount, int totalCount) {
    return GestureDetector(
      onTap: _toggleExpanded,
      child: Container(
        padding: EdgeInsets.all(utils.getAdaptiveValue(context, mobile: 12, tablet: 14, desktop: 16)),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: utils.getAdaptiveBorderRadius(context),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: utils.getAdaptiveValue(context, mobile: 1.2, tablet: 1.3, desktop: 1.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: utils.getAdaptiveValue(context, mobile: 3, tablet: 3.5, desktop: 4),
              height: utils.getAdaptiveValue(context, mobile: 20, tablet: 22, desktop: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 1.5, tablet: 1.8, desktop: 2)),
              ),
            ),
            SizedBox(width: utils.getAdaptiveValue(context, mobile: 8, tablet: 10, desktop: 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Достижения',
                    style: TextStyle(
                      fontSize: utils.getAdaptiveFontSize(context, mobile: 16, tablet: 17, desktop: 18),
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: utils.getAdaptiveValue(context, mobile: 1, tablet: 2, desktop: 2)),
                  Text(
                    'Откройте все награды за активность',
                    style: TextStyle(
                      fontSize: utils.getAdaptiveFontSize(context, mobile: 12, tablet: 13, desktop: 13),
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Бейдж с прогрессом
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: utils.getAdaptiveValue(context, mobile: 10, tablet: 11, desktop: 12),
                vertical: utils.getAdaptiveValue(context, mobile: 4, tablet: 5, desktop: 6),
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 10, tablet: 11, desktop: 12)),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '$achievedCount/$totalCount',
                style: TextStyle(
                  fontSize: utils.getAdaptiveFontSize(context, mobile: 12, tablet: 13, desktop: 14),
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: utils.getAdaptiveValue(context, mobile: 8, tablet: 10, desktop: 12)),
            // Стрелочка для раскрытия
            Icon(
              _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              color: Colors.white,
              size: utils.getAdaptiveIconSize(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsContent(ProfileUtils utils, BuildContext context, bool isMobile) {
    return Column(
      children: [
        SizedBox(height: utils.getAdaptiveSpacing(context)),
        // Прогресс-бар выполнения
        _buildOverallProgressBar(utils, context),
        SizedBox(height: utils.getAdaptiveSpacing(context)),
        // Сетка достижений
        _buildAchievementsGrid(utils, context, isMobile),
      ],
    );
  }

  Widget _buildOverallProgressBar(ProfileUtils utils, BuildContext context) {
    final achievedCount = widget.achievements.values.where((achieved) => achieved == true).length;
    final totalCount = widget.achievements.length;
    final percentage = totalCount > 0 ? achievedCount / totalCount : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Общий прогресс',
              style: TextStyle(
                fontSize: utils.getAdaptiveFontSize(context, mobile: 11, tablet: 12, desktop: 12),
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(percentage * 100).round()}%',
              style: TextStyle(
                fontSize: utils.getAdaptiveFontSize(context, mobile: 11, tablet: 12, desktop: 12),
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        SizedBox(height: utils.getAdaptiveValue(context, mobile: 6, tablet: 7, desktop: 8)),
        Container(
          height: utils.getAdaptiveValue(context, mobile: 5, tablet: 5.5, desktop: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 2, tablet: 2.5, desktop: 3)),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: MediaQuery.of(context).size.width * percentage * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 2, tablet: 2.5, desktop: 3)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsGrid(ProfileUtils utils, BuildContext context, bool isMobile) {
    final achievementEntries = _achievementConfig.entries.toList();
    final crossAxisCount = utils.getGridCrossAxisCount(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: utils.getAdaptiveValue(context, mobile: 8, tablet: 10, desktop: 12),
        mainAxisSpacing: utils.getAdaptiveValue(context, mobile: 8, tablet: 10, desktop: 12),
        childAspectRatio: _getChildAspectRatio(context, isMobile),
      ),
      itemCount: achievementEntries.length,
      itemBuilder: (context, index) {
        final entry = achievementEntries[index];
        final achievementId = entry.key;
        final config = entry.value;
        final achieved = widget.achievements[achievementId] ?? false;
        final progress = _getCurrentProgress(achievementId);
        final progressPercentage = _getProgressPercentage(achievementId);

        return _buildAchievementCard(
          utils,
          context,
          config,
          achieved,
          progress,
          progressPercentage,
          isMobile,
        );
      },
    );
  }

  double _getChildAspectRatio(BuildContext context, bool isMobile) {
    if (isMobile) return 1.1;
    if (ProfileUtils.isTablet(context)) return 1.2;
    return 1.3;
  }

  Widget _buildAchievementCard(
      ProfileUtils utils,
      BuildContext context,
      _AchievementInfo config,
      bool achieved,
      int progress,
      double progressPercentage,
      bool isMobile,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 12, tablet: 14, desktop: 16)),
        border: Border.all(
          color: achieved
              ? Colors.white.withOpacity(0.6)
              : Colors.white.withOpacity(0.3),
          width: achieved ? utils.getAdaptiveValue(context, mobile: 1.5, tablet: 1.8, desktop: 2) : 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(utils.getAdaptiveValue(context, mobile: 10, tablet: 11, desktop: 12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Иконка и статус
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(utils.getAdaptiveValue(context, mobile: 4, tablet: 5, desktop: 6)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 8, tablet: 9, desktop: 10)),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    config.emoji,
                    style: TextStyle(
                      fontSize: utils.getAdaptiveFontSize(context, mobile: 14, tablet: 15, desktop: 16),
                    ),
                  ),
                ),
                const Spacer(),
                // Иконка статуса
                Container(
                  padding: EdgeInsets.all(utils.getAdaptiveValue(context, mobile: 3, tablet: 3.5, desktop: 4)),
                  decoration: BoxDecoration(
                    color: achieved ? Colors.white : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    achieved ? Icons.check_rounded : Icons.lock_rounded,
                    color: achieved ? Color(0xFF6366F1) : Colors.white.withOpacity(0.5),
                    size: utils.getAdaptiveValue(context, mobile: 14, tablet: 15, desktop: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: utils.getAdaptiveValue(context, mobile: 6, tablet: 7, desktop: 8)),
            // Заголовок
            Text(
              config.title,
              style: TextStyle(
                fontSize: utils.getAdaptiveFontSize(context, mobile: 11, tablet: 12, desktop: 13),
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: utils.getAdaptiveValue(context, mobile: 3, tablet: 4, desktop: 4)),
            // Прогресс-бар
            if (!achieved)
              Column(
                children: [
                  Container(
                    height: utils.getAdaptiveValue(context, mobile: 3, tablet: 3.5, desktop: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 1, tablet: 1.5, desktop: 2)),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: MediaQuery.of(context).size.width * progressPercentage * 0.2,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 1, tablet: 1.5, desktop: 2)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: utils.getAdaptiveValue(context, mobile: 2, tablet: 3, desktop: 4)),
                  Text(
                    '$progress/${config.goal}',
                    style: TextStyle(
                      fontSize: utils.getAdaptiveFontSize(context, mobile: 9, tablet: 10, desktop: 10),
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            else
              SizedBox(height: utils.getAdaptiveValue(context, mobile: 8, tablet: 9, desktop: 10)),
            // Описание
            SizedBox(height: utils.getAdaptiveValue(context, mobile: 4, tablet: 5, desktop: 6)),
            Text(
              config.description,
              style: TextStyle(
                fontSize: utils.getAdaptiveFontSize(context, mobile: 9, tablet: 10, desktop: 11),
                color: Colors.white.withOpacity(0.8),
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// Класс: Информация о достижении
class _AchievementInfo {
  final String title;
  final String subtitle;
  final IconData icon;
  final int goal;
  final String description;
  final String emoji;

  const _AchievementInfo(
      this.title,
      this.subtitle,
      this.icon,
      this.goal,
      this.description, {
        this.emoji = '🏆',
      });
}