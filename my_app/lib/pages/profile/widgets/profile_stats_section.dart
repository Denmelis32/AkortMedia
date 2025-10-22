import 'package:flutter/material.dart';
import 'dart:math';
import '../utils/profile_utils.dart';

class ProfileStatsSection extends StatefulWidget {
  final Map<String, int> stats;
  final double contentMaxWidth;
  final Color userColor;
  final Function(String)? onStatsTap;
  final Map<String, List<int>>? weeklyData;

  const ProfileStatsSection({
    super.key,
    required this.stats,
    required this.contentMaxWidth,
    required this.userColor,
    this.onStatsTap,
    this.weeklyData,
  });

  @override
  State<ProfileStatsSection> createState() => _ProfileStatsSectionState();
}

class _ProfileStatsSectionState extends State<ProfileStatsSection> {
  bool _isExpanded = false;

  final Map<String, _StatInfo> _statConfig = {
    'posts': _StatInfo('Посты', Icons.article_rounded, 'публикаций'),
    'likes': _StatInfo('Лайки', Icons.favorite_rounded, 'оценок'),
    'comments': _StatInfo('Комментарии', Icons.chat_rounded, 'комментариев'),
  };

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final utils = ProfileUtils();
    final isMobile = ProfileUtils.isMobile(context);

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
            _buildHeaderSection(utils, context, isMobile),
            if (_isExpanded)
              _buildStatsContent(utils, context, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(ProfileUtils utils, BuildContext context, bool isMobile) {
    final total = (widget.stats['posts'] ?? 0) +
        (widget.stats['likes'] ?? 0) +
        (widget.stats['comments'] ?? 0);

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
                    'Статистика профиля',
                    style: TextStyle(
                      fontSize: utils.getAdaptiveFontSize(context, mobile: 16, tablet: 17, desktop: 18),
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: utils.getAdaptiveValue(context, mobile: 1, tablet: 2, desktop: 2)),
                  Text(
                    'Обзор активности и аналитика',
                    style: TextStyle(
                      fontSize: utils.getAdaptiveFontSize(context, mobile: 12, tablet: 13, desktop: 13),
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Общая активность
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
                '$total',
                style: TextStyle(
                  fontSize: utils.getAdaptiveFontSize(context, mobile: 14, tablet: 15, desktop: 16),
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

  Widget _buildStatsContent(ProfileUtils utils, BuildContext context, bool isMobile) {
    return Column(
      children: [
        SizedBox(height: utils.getAdaptiveSpacing(context)),
        // Компактная статистика
        _buildCompactStats(utils, context, isMobile),
        SizedBox(height: utils.getAdaptiveSpacing(context)),
        // Расширенная статистика
        _buildExpandedView(utils, context, isMobile),
      ],
    );
  }

  Widget _buildCompactStats(ProfileUtils utils, BuildContext context, bool isMobile) {
    return Container(
      padding: utils.getAdaptivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 14, tablet: 15, desktop: 16)),
        border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: utils.getAdaptiveValue(context, mobile: 1.2, tablet: 1.3, desktop: 1.5)
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(utils, context, 'posts', isMobile),
          _buildStatItem(utils, context, 'likes', isMobile),
          _buildStatItem(utils, context, 'comments', isMobile),
        ],
      ),
    );
  }

  Widget _buildStatItem(ProfileUtils utils, BuildContext context, String statType, bool isMobile) {
    final config = _statConfig[statType]!;
    final value = widget.stats[statType] ?? 0;

    final iconSize = utils.getAdaptiveValue(context, mobile: 40, tablet: 42, desktop: 44);
    final iconInnerSize = utils.getAdaptiveIconSize(context);

    return GestureDetector(
      onTap: () => widget.onStatsTap?.call(statType),
      child: Container(
        padding: EdgeInsets.all(utils.getAdaptiveValue(context, mobile: 8, tablet: 10, desktop: 12)),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 12, tablet: 14, desktop: 16)),
        ),
        child: Column(
          children: [
            // Иконка
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                config.icon,
                color: Colors.white,
                size: iconInnerSize,
              ),
            ),
            SizedBox(height: utils.getAdaptiveValue(context, mobile: 6, tablet: 7, desktop: 8)),
            // Значение
            Text(
              _formatNumber(value),
              style: TextStyle(
                fontSize: utils.getAdaptiveFontSize(context, mobile: 15, tablet: 16, desktop: 18),
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            SizedBox(height: utils.getAdaptiveValue(context, mobile: 2, tablet: 3, desktop: 4)),
            Text(
              config.label,
              style: TextStyle(
                fontSize: utils.getAdaptiveFontSize(context, mobile: 10, tablet: 11, desktop: 11),
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedView(ProfileUtils utils, BuildContext context, bool isMobile) {
    return Container(
      padding: utils.getAdaptivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 14, tablet: 15, desktop: 16)),
        border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: utils.getAdaptiveValue(context, mobile: 1.2, tablet: 1.3, desktop: 1.5)
        ),
      ),
      child: Column(
        children: [
          // Мини-графики для каждой статистики
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatWithChart(utils, context, 'posts', isMobile),
              _buildStatWithChart(utils, context, 'likes', isMobile),
              _buildStatWithChart(utils, context, 'comments', isMobile),
            ],
          ),
          SizedBox(height: utils.getAdaptiveValue(context, mobile: 12, tablet: 14, desktop: 16)),
          // Прогресс-бары сравнения
          _buildComparisonBars(utils, context, isMobile),
        ],
      ),
    );
  }

  Widget _buildStatWithChart(ProfileUtils utils, BuildContext context, String statType, bool isMobile) {
    final config = _statConfig[statType]!;
    final value = widget.stats[statType] ?? 0;
    final weeklyValues = widget.weeklyData?[statType] ?? List.filled(7, 0);

    final chartWidth = utils.getAdaptiveValue(context, mobile: 60, tablet: 70, desktop: 80);
    final chartHeight = utils.getAdaptiveValue(context, mobile: 25, tablet: 28, desktop: 30);

    return GestureDetector(
      onTap: () => widget.onStatsTap?.call(statType),
      child: Column(
        children: [
          // Мини-график
          Container(
            width: chartWidth,
            height: chartHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 6, tablet: 7, desktop: 8)),
              color: Colors.white.withOpacity(0.1),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: CustomPaint(
              painter: _MiniChartPainter(
                data: weeklyValues,
                color: Colors.white,
                maxValue: weeklyValues.isNotEmpty ? weeklyValues.reduce(max) : 1,
              ),
            ),
          ),
          SizedBox(height: utils.getAdaptiveValue(context, mobile: 6, tablet: 7, desktop: 8)),
          Text(
            _formatNumber(value),
            style: TextStyle(
              fontSize: utils.getAdaptiveFontSize(context, mobile: 14, tablet: 15, desktop: 16),
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            config.label,
            style: TextStyle(
              fontSize: utils.getAdaptiveFontSize(context, mobile: 9, tablet: 10, desktop: 10),
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonBars(ProfileUtils utils, BuildContext context, bool isMobile) {
    final maxValue = widget.stats.values.reduce((a, b) => a > b ? a : b);

    return Column(
      children: _statConfig.entries.map((entry) {
        final statType = entry.key;
        final config = entry.value;
        final value = widget.stats[statType] ?? 0;
        final percentage = maxValue > 0 ? value / maxValue : 0;

        return Padding(
          padding: EdgeInsets.symmetric(vertical: utils.getAdaptiveValue(context, mobile: 3, tablet: 3.5, desktop: 4)),
          child: Row(
            children: [
              Icon(
                config.icon,
                size: utils.getAdaptiveIconSize(context),
                color: Colors.white,
              ),
              SizedBox(width: utils.getAdaptiveValue(context, mobile: 6, tablet: 7, desktop: 8)),
              Expanded(
                flex: 2,
                child: Text(
                  config.extendedLabel,
                  style: TextStyle(
                    fontSize: utils.getAdaptiveFontSize(context, mobile: 11, tablet: 12, desktop: 12),
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  height: utils.getAdaptiveValue(context, mobile: 6, tablet: 7, desktop: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 3, tablet: 3.5, desktop: 4)),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: MediaQuery.of(context).size.width * percentage * 0.3,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(utils.getAdaptiveValue(context, mobile: 3, tablet: 3.5, desktop: 4)),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: utils.getAdaptiveValue(context, mobile: 6, tablet: 7, desktop: 8)),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: utils.getAdaptiveFontSize(context, mobile: 11, tablet: 12, desktop: 12),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

// Класс: Информация о статистике
class _StatInfo {
  final String label;
  final IconData icon;
  final String extendedLabel;

  const _StatInfo(this.label, this.icon, this.extendedLabel);
}

// Класс: Отрисовщик мини-графика
class _MiniChartPainter extends CustomPainter {
  final List<int> data;
  final Color color;
  final int maxValue;

  const _MiniChartPainter({
    required this.data,
    required this.color,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width > 60 ? 1.5 : 1.2
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final points = <Offset>[];
    final stepX = size.width / (data.length - 1);

    // Создаем точки графика
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i] / maxValue) * size.height;
      points.add(Offset(x, y));
    }

    // Рисуем заполнение под графиком
    final path = Path();
    path.moveTo(0, size.height);
    for (final point in points) {
      path.lineTo(point.dx, point.dy);
    }
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, fillPaint);

    // Рисуем линию графика
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}