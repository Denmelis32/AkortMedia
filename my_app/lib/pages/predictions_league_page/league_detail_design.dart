import 'package:flutter/material.dart';
import 'models/match_model.dart';

class LeagueDetailDesign {
  static const Color primaryColor = Color(0xFF4361EE);
  static const Color secondaryColor = Color(0xFF7209B7);
  static const Color accentColor = Color(0xFF06D6A0);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF212529);
  static const Color secondaryTextColor = Color(0xFF6C757D);
  static const Color successColor = Color(0xFF4CC9F0);
  static const Color warningColor = Color(0xFFFFD166);
  static const Color errorColor = Color(0xFFEF476F);

  // НОВЫЙ МЕТОД: Компактная карточка для управления матчами (2 в ряд)
  static Widget buildManageableMatchCard(
      Match match,
      Function(Match) onEditPressed,
      Function(int) onDeletePressed,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Компактная информация о матче
            Row(
              children: [
                Icon(Icons.sports, size: 16, color: primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${match.teamHome} - ${match.teamAway}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Дата и лига
            Text(
              '${formatMatchDate(match.date)} • ${match.league}',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // Кнопки действий
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (match.status == MatchStatus.upcoming)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => onEditPressed(match),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => onDeletePressed(match.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  // НОВЫЙ МЕТОД: Сетка для управления матчами (2 в ряд)


  static Widget buildManageableMatchesGrid(
      List<Match> matches,
      Function(Match) onEditPressed,
      Function(int) onDeletePressed,
      ) {
    if (matches.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.sports_soccer, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'Матчи для управления',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Матчей нет',
              style: TextStyle(fontSize: 14, color: secondaryTextColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Рассчитываем высоту на основе количества элементов
    final rowCount = (matches.length / 2).ceil();
    final itemHeight = 140;
    final totalHeight = rowCount * itemHeight + (rowCount - 1) * 12;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: totalHeight.toDouble(),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: matches.length,
        itemBuilder: (context, index) {
          return buildManageableMatchCard(
            matches[index],
            onEditPressed,
            onDeletePressed,
          );
        },
      ),
    );
  }

  static Widget buildTabSection(
      List<String> tabs,
      int selectedTab,
      bool isCreator,
      Function(int) onTabChanged,
      ) {
    final visibleTabs = isCreator ? tabs : tabs.sublist(0, 3);

    return Container(
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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: visibleTabs.map((tab) {
          final index = visibleTabs.indexOf(tab);
          final isActive = index == selectedTab;
          return Expanded(
            child: _buildTabButton(tab, isActive, () {
              onTabChanged(index);
            }),
          );
        }).toList(),
      ),
    );
  }

  static Widget _buildTabButton(
      String text,
      bool isActive,
      VoidCallback onTap,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? primaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      margin: const EdgeInsets.all(4),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? primaryColor : secondaryTextColor,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }

  static Widget buildLeagueHeader(
      String leagueName,
      String logoUrl,
      int participants,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.8),
            secondaryColor.withOpacity(0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.network(
                logoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  padding: const EdgeInsets.all(16),
                  child: Icon(Icons.emoji_events, color: primaryColor),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leagueName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$participants участников',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.share, color: Colors.white.withOpacity(0.8)),
          const SizedBox(width: 12),
          Icon(Icons.info_outline, color: Colors.white.withOpacity(0.8)),
        ],
      ),
    );
  }

  static Widget buildLeagueStats(List<Match> matches) {
    final totalPoints = matches.fold(0, (sum, match) => sum + match.points);
    final finishedMatches = matches
        .where((m) => m.status == MatchStatus.finished)
        .length;
    final accuracy = finishedMatches > 0
        ? ((matches.where((m) => m.points > 0).length / finishedMatches) * 100)
        .round()
        : 0;
    final currentStreak = _calculateCurrentStreak(matches);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.15),
            secondaryColor.withOpacity(0.1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('${matches.length}', 'Матчей', Icons.sports_score),
          _buildStatItem('$finishedMatches', 'Завершено', Icons.check_circle),
          _buildStatItem('$accuracy%', 'Точность', Icons.track_changes),
          _buildStatItem('$totalPoints', 'Очков', Icons.emoji_events),
          _buildStatItem(
            '$currentStreak',
            'Серия',
            Icons.local_fire_department,
          ),
        ],
      ),
    );
  }

  static int _calculateCurrentStreak(List<Match> matches) {
    int streak = 0;
    final sortedMatches = List.from(matches)
      ..sort((a, b) => b.date.compareTo(a.date));

    for (var match in sortedMatches) {
      if (match.status == MatchStatus.finished) {
        if (match.points > 0) {
          streak++;
        } else {
          break;
        }
      }
    }

    return streak;
  }

  static Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: primaryColor),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: secondaryTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Обновленная версия для отображения матчей в виде сетки 2x2
  static Widget buildMatchesGrid(
      List<Match> matches,
      bool isCreator,
      Function(Match) onPredictionPressed,
      Function(Match) onResultInputPressed,
      ) {
    if (matches.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.sports_soccer, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'Матчи',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Матчей нет',
              style: TextStyle(fontSize: 14, color: secondaryTextColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: matches.length,
        itemBuilder: (context, index) {
          return _buildCompactMatchCard(
            matches[index],
            isCreator,
            onPredictionPressed,
            onResultInputPressed,
          );
        },
      ),
    );
  }

  // Компактная карточка матча для сетки 2x2
  static Widget _buildCompactMatchCard(
      Match match,
      bool isCreator,
      Function(Match) onPredictionPressed,
      Function(Match) onResultInputPressed,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusBackgroundColor(match.status),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    formatMatchTime(match.date),
                    style: TextStyle(
                      color: _getStatusTextColor(match.status),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusTextColor(match.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    getMatchStatusText(match.status).substring(0, 1),
                    style: TextStyle(
                      color: _getStatusTextColor(match.status),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Teams and score
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Home team
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.network(
                            match.imageHome,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.sports,
                                    size: 14,
                                    color: primaryColor,
                                  ),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          match.teamHome,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Score
                  if (match.status == MatchStatus.finished)
                    Text(
                      match.actualScore,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                      ),
                    )
                  else if (match.status == MatchStatus.live)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: errorColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: errorColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'LIVE',
                            style: TextStyle(
                              color: errorColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Text(
                      formatMatchTime(match.date),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Away team
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.network(
                            match.imageAway,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.sports,
                                    size: 14,
                                    color: primaryColor,
                                  ),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          match.teamAway,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Prediction button or result
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade100, width: 1),
              ),
            ),
            child: _buildCompactMatchAction(
              match,
              isCreator,
              onPredictionPressed,
              onResultInputPressed,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildCompactMatchAction(
      Match match,
      bool isCreator,
      Function(Match) onPredictionPressed,
      Function(Match) onResultInputPressed,
      ) {
    if (match.userPrediction.isNotEmpty) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.tips_and_updates, size: 12, color: successColor),
          const SizedBox(width: 4),
          Text(
            match.userPrediction,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: successColor,
            ),
          ),
        ],
      );
    } else if (match.status == MatchStatus.upcoming) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => onPredictionPressed(match),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 6),
            elevation: 0,
          ),
          child: const Text(
            'Прогноз',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ),
      );
    } else if (isCreator && match.status == MatchStatus.upcoming) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => onResultInputPressed(match),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: secondaryColor),
            foregroundColor: secondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 4),
          ),
          child: const Text(
            'Результат',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }


  static Widget buildMatchCard(
    Match match,
    bool isCreator,
    Function(Match) onPredictionPressed,
    Function(Match) onResultInputPressed,
  ) {
    // Старая реализация (оставлена для обратной совместимости)
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with league and date
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: _getStatusBackgroundColor(match.status),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      size: 16,
                      color: _getStatusTextColor(match.status),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      match.league,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _getStatusTextColor(match.status),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Text(
                  formatMatchDate(match.date),
                  style: TextStyle(
                    color: _getStatusTextColor(match.status).withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Match content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Teams and score
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Home team
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.grey.shade100,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.network(
                                match.imageHome,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      child: const Icon(
                                        Icons.sports,
                                        color: primaryColor,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            match.teamHome,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: textColor,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Score/time
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          if (match.status == MatchStatus.finished)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                match.actualScore,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: primaryColor,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            )
                          else if (match.status == MatchStatus.live)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: errorColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: errorColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'LIVE',
                                    style: TextStyle(
                                      color: errorColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Column(
                              children: [
                                Text(
                                  formatMatchTime(match.date),
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: primaryColor,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    getMatchStatusText(match.status),
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    // Away team
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.grey.shade100,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.network(
                                match.imageAway,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      child: const Icon(
                                        Icons.sports,
                                        color: primaryColor,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            match.teamAway,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: textColor,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // User prediction section
                if (match.userPrediction.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: successColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.tips_and_updates,
                              size: 18,
                              color: successColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Ваш прогноз: ${match.userPrediction}',
                              style: TextStyle(
                                color: successColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),

                        if (match.status == MatchStatus.finished) ...[
                          const SizedBox(height: 8),
                          Text(
                            match.userPrediction == match.actualScore
                                ? '✅ Вы угадали результат! +${match.points} очков'
                                : '❌ Прогноз не совпал',
                            style: TextStyle(
                              color: match.userPrediction == match.actualScore
                                  ? successColor
                                  : errorColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  )
                else if (match.status == MatchStatus.upcoming)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => onPredictionPressed(match),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: const Text(
                        'Сделать прогноз',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),

                // Points badge
                if (match.points > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: warningColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: warningColor.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: warningColor, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '+${match.points} очков',
                          style: TextStyle(
                            color: warningColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Result input button for creator
                if (isCreator && match.status == MatchStatus.upcoming)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    child: ElevatedButton(
                      onPressed: () => onResultInputPressed(match),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Ввести результат'),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Color _getStatusBackgroundColor(MatchStatus status) {
    switch (status) {
      case MatchStatus.upcoming:
        return primaryColor.withOpacity(0.15);
      case MatchStatus.live:
        return errorColor.withOpacity(0.15);
      case MatchStatus.finished:
        return successColor.withOpacity(0.15);
      case MatchStatus.completed:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  static Color _getStatusTextColor(MatchStatus status) {
    switch (status) {
      case MatchStatus.upcoming:
        return primaryColor;
      case MatchStatus.live:
        return errorColor;
      case MatchStatus.finished:
        return successColor;
      case MatchStatus.completed:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  static Widget buildPredictionCard(Match match) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${match.teamHome} - ${match.teamAway}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _getPredictionIconColor(match).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getPredictionIcon(match),
                  size: 18,
                  color: _getPredictionIconColor(match),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Прогноз: ${match.userPrediction}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _getPredictionTextColor(match),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (match.status == MatchStatus.finished) ...[
            const SizedBox(height: 8),
            Text(
              'Результат: ${match.actualScore}',
              style: TextStyle(
                fontSize: 14,
                color: secondaryTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (match.points > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.emoji_events, size: 16, color: warningColor),
                const SizedBox(width: 6),
                Text(
                  'Очки: +${match.points}',
                  style: TextStyle(
                    color: warningColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 12),
          Text(
            'Дата: ${formatMatchDate(match.date)}',
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  static IconData _getPredictionIcon(Match match) {
    if (match.status == MatchStatus.finished) {
      return match.points > 0 ? Icons.check_circle : Icons.cancel;
    }
    return Icons.access_time;
  }

  static Color _getPredictionIconColor(Match match) {
    if (match.status == MatchStatus.finished) {
      return match.points > 0 ? successColor : errorColor;
    }
    return warningColor;
  }

  static Color _getPredictionTextColor(Match match) {
    if (match.status == MatchStatus.finished) {
      return match.points > 0 ? successColor : errorColor;
    }
    return primaryColor;
  }









  static Widget buildRatingList(List<Match> matches) {
    final List<Map<String, dynamic>> leaders = [
      {
        'name': 'Алексей Иванов',
        'points': 245,
        'accuracy': '85%',
        'avatar': 'https://example.com/avatar1.jpg',
      },
      {
        'name': 'Мария Петрова',
        'points': 228,
        'accuracy': '82%',
        'avatar': 'https://example.com/avatar2.jpg',
      },
      {
        'name': 'Иван Сидоров',
        'points': 215,
        'accuracy': '80%',
        'avatar': 'https://example.com/avatar3.jpg',
      },
      {
        'name': 'Вы',
        'points': matches.fold(0, (sum, match) => sum + match.points),
        'accuracy': '78%',
        'avatar': 'https://example.com/avatar_user.jpg',
      },
      {
        'name': 'Дмитрий Козлов',
        'points': 210,
        'accuracy': '77%',
        'avatar': 'https://example.com/avatar4.jpg',
      },
      {
        'name': 'Ольга Новикова',
        'points': 195,
        'accuracy': '76%',
        'avatar': 'https://example.com/avatar5.jpg',
      },
      {
        'name': 'Сергей Васильев',
        'points': 185,
        'accuracy': '75%',
        'avatar': 'https://example.com/avatar6.jpg',
      },
      {
        'name': 'Екатерина Смирнова',
        'points': 180,
        'accuracy': '74%',
        'avatar': 'https://example.com/avatar7.jpg',
      },
      {
        'name': 'Андрей Павлов',
        'points': 175,
        'accuracy': '73%',
        'avatar': 'https://example.com/avatar8.jpg',
      },
      {
        'name': 'Наталья Орлова',
        'points': 170,
        'accuracy': '72%',
        'avatar': 'https://example.com/avatar9.jpg',
      },
    ];

    leaders.sort((a, b) => b['points'].compareTo(a['points']));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Text(
              'Рейтинг участников',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
          // УБИРАЕМ ConstrainedBox и исправляем ListView
          ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shrinkWrap: true, // Важно для вложенных списков
            physics: const NeverScrollableScrollPhysics(), // Отключаем скролл
            itemCount: leaders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final leader = leaders[index];
              final isCurrentUser = leader['name'] == 'Вы';
              final isTopThree = index < 3;

              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: isCurrentUser
                      ? primaryColor.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: isCurrentUser
                      ? Border.all(color: primaryColor.withOpacity(0.3))
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Position number with special badges for top 3
                    if (isTopThree)
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: _getTopThreeGradient(index + 1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          index == 0
                              ? Icons.emoji_events
                              : index == 1
                              ? Icons.workspace_premium
                              : Icons.workspace_premium,
                          color: Colors.white,
                          size: 18,
                        ),
                      )
                    else
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isCurrentUser
                              ? primaryColor.withOpacity(0.2)
                              : Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: isCurrentUser
                                ? primaryColor
                                : secondaryTextColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    const SizedBox(width: 16),

                    // Avatar
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCurrentUser
                              ? primaryColor
                              : Colors.grey.shade300,
                          width: isCurrentUser ? 2 : 1,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          leader['avatar'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey.shade200,
                                child: Icon(
                                  Icons.person,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            leader['name'] ?? 'Неизвестный',
                            style: TextStyle(
                              fontWeight: isCurrentUser
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isCurrentUser ? primaryColor : textColor,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${leader['accuracy']} точность',
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Points
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isTopThree
                            ? _getTopThreeColor(index + 1).withOpacity(0.1)
                            : isCurrentUser
                            ? primaryColor.withOpacity(0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${leader['points']}',
                        style: TextStyle(
                          color: isTopThree
                              ? _getTopThreeColor(index + 1)
                              : isCurrentUser
                              ? primaryColor
                              : textColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }








  static LinearGradient _getTopThreeGradient(int position) {
    switch (position) {
      case 1:
        return const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFC400)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 2:
        return const LinearGradient(
          colors: [Color(0xFFC0C0C0), Color(0xFFA0A0A0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 3:
        return const LinearGradient(
          colors: [Color(0xFFCD7F32), Color(0xFFB87333)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      default:
        return const LinearGradient(
          colors: [primaryColor, primaryColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
    }
  }

  static Color _getTopThreeColor(int position) {
    switch (position) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return primaryColor;
    }
  }

  static Widget buildUpcomingMatches(List<Match> upcomingMatches) {
    if (upcomingMatches.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.calendar_today, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'Ближайшие матчи',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'На этой неделе матчей нет',
              style: TextStyle(fontSize: 14, color: secondaryTextColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              'Ближайшие матчи',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
          ...upcomingMatches
              .take(3)
              .map((match) => _buildUpcomingMatchItem(match)),
          if (upcomingMatches.length > 3)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Еще ${upcomingMatches.length - 3} матчей',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static Widget _buildUpcomingMatchItem(Match match) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade100, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              match.teamHome,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              formatMatchTime(match.date),
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              match.teamAway,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  static String formatMatchDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  static String formatMatchTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String getMatchStatusText(MatchStatus status) {
    switch (status) {
      case MatchStatus.upcoming:
        return 'Предстоящий';
      case MatchStatus.live:
        return 'В прямом эфире';
      case MatchStatus.finished:
        return 'Завершен';
      case MatchStatus.completed:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  static Color getStatusColor(MatchStatus status) {
    switch (status) {
      case MatchStatus.upcoming:
        return primaryColor;
      case MatchStatus.live:
        return errorColor;
      case MatchStatus.finished:
        return successColor;
      case MatchStatus.completed:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}
