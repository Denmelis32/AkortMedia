// 🎯 УТИЛИТЫ ДЛЯ РАБОТЫ С РАЗМЕТКОЙ И АДАПТИВНЫМ ДИЗАЙНОМ

import 'package:flutter/material.dart';
import '../models/news_card_models.dart';
import '../models/news_card_enums.dart';

/// 🎪 КЛАСС ДЛЯ РАБОТЫ С АДАПТИВНОЙ РАЗМЕТКОЙ
/// Содержит методы для расчета размеров, отступов и декораций
/// в зависимости от размера экрана и контекста
class LayoutUtils {

  // 📱 БРЕЙКПОИНТЫ ДЛЯ АДАПТИВНОГО ДИЗАЙНА
  static const double mobileBreakpoint = 700;    // 📱 Мобильные устройства
  static const double tabletBreakpoint = 1000;   // 📟 Планшеты
  static const double desktopBreakpoint = 1400;  // 💻 Десктопы

  /// 📏 ПОЛУЧАЕТ ГОРИЗОНТАЛЬНЫЕ ОТСТУПЫ ДЛЯ КАРТОЧКИ
  /// Рассчитывает отступы слева и справа в зависимости от ширины экрана
  static double getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > desktopBreakpoint) return 280;   // 💻 Большие экраны - широкие отступы
    if (width > tabletBreakpoint) return 80;     // 📟 Планшеты - средние отступы
    return 0;                                    // 📱 Мобильные - без отступов
  }

  /// 📐 ПОЛУЧАЕТ МАКСИМАЛЬНУЮ ШИРИНУ КОНТЕНТА
  /// Ограничивает ширину контента для удобства чтения
  static double getContentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > desktopBreakpoint) return 600;   // 💻 Большие экраны - фиксированная ширина
    if (width > tabletBreakpoint) return 600;    // 📟 Планшеты - фиксированная ширина
    if (width > mobileBreakpoint) return 600;    // 📱 Большие мобильные - фиксированная ширина
    return double.infinity;                      // 📱 Мобильные - на всю ширину
  }

  /// 👤 ПОЛУЧАЕТ РАЗМЕР АВАТАРКИ
  /// Размер аватарки зависит от размера экрана
  static double getAvatarSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > mobileBreakpoint ? 40 : 44;   // 📱 На мобильных аватарки чуть больше
  }

  /// 📰 ПОЛУЧАЕТ РАЗМЕР ШРИФТА ДЛЯ ЗАГОЛОВКА
  /// Адаптивный размер шрифта в зависимости от экрана
  static double getTitleFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > mobileBreakpoint ? 15 : 15;   // 🔤 Единый размер для читаемости
  }

  /// 📝 ПОЛУЧАЕТ РАЗМЕР ШРИФТА ДЛЯ ОПИСАНИЯ
  static double getDescriptionFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > mobileBreakpoint ? 15 : 14;   // 🔤 Чуть меньше на мобильных
  }

  /// 🎪 ПОЛУЧАЕТ РАДИУС СКРУГЛЕНИЯ КАРТОЧКИ
  /// На мобильных карточки без скругления для экономии места
  static double getCardBorderRadius(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > mobileBreakpoint ? 20.0 : 0.0; // 📱 На мобильных - прямоугольные
  }

  /// 📦 ПОЛУЧАЕТ ВНЕШНИЕ ОТСТУПЫ ДЛЯ КАРТОЧКИ
  static EdgeInsets getCardMargin(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = getHorizontalPadding(context);

    return EdgeInsets.only(
      left: horizontalPadding,
      right: horizontalPadding,
      bottom: width > mobileBreakpoint ? 20.0 : 0.0, // 📱 На мобильных - без отступов снизу
    );
  }

  /// 📍 ПОЛУЧАЕТ ВНУТРЕННИЕ ОТСТУПЫ ДЛЯ КОНТЕНТА
  static EdgeInsets getContentPadding(BuildContext context) {
    return const EdgeInsets.fromLTRB(20, 16, 20, 20); // 🎯 Фиксированные отступы
  }

  /// 📏 ПОЛУЧАЕТ ВЫСОТУ СЕКЦИИ ТЕГОВ
  static double getTagsSectionHeight(BuildContext context) {
    return 28; // 🎯 Фиксированная высота для одной строки тегов
  }

  /// 🔍 ОПРЕДЕЛЯЕТ НУЖНО ЛИ ПОКАЗЫВАТЬ ВЕРХНЮЮ ЛИНИЮ
  /// Верхняя линия разделителя показывается только на мобильных
  static bool shouldShowTopLine(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width <= mobileBreakpoint; // 📱 Только на мобильных
  }

  /// 🎨 ПОЛУЧАЕТ ДИЗАЙН КАРТОЧКИ НА ОСНОВЕ ДАННЫХ НОВОСТИ
  /// Выбирает дизайн из предустановленных на основе ID новости
  static CardDesign getCardDesign(Map<String, dynamic> news) {
    final id = news['id']?.hashCode ?? 0;
    return _cardDesigns[id % _cardDesigns.length];
  }

  /// 📊 ОПРЕДЕЛЯЕТ ТИП КОНТЕНТА НА ОСНОВЕ ТЕКСТА
  static ContentType getContentType(Map<String, dynamic> news) {
    final title = _getStringValue(news['title']).toLowerCase();
    final description = _getStringValue(news['description']).toLowerCase();

    if (title.contains('важн') || title.contains('срочн')) return ContentType.important;
    if (title.contains('новость') || description.contains('новость')) return ContentType.news;
    if (title.contains('спорт') || description.contains('спорт')) return ContentType.sports;
    if (title.contains('техн') || description.contains('техн')) return ContentType.tech;
    if (title.contains('развлеч') || description.contains('развлеч')) return ContentType.entertainment;
    if (title.contains('образован') || description.contains('образован')) return ContentType.education;

    return ContentType.general;
  }

  /// 🎨 ПОЛУЧАЕТ ЦВЕТ ВЫБРАННОГО ТЕГА
  static Color getSelectedTagColor(Map<String, dynamic> news, CardDesign cardDesign) {
    if (news['tag_color'] != null) {
      try {
        return Color(news['tag_color']);
      } catch (e) {
        print('❌ Ошибка парсинга цвета тега: $e');
      }
    }
    return cardDesign.accentColor;
  }

  /// 🎪 СОЗДАЕТ ДЕКОРАЦИЮ ДЛЯ КАРТОЧКИ
  static BoxDecoration getCardDecoration({
    required BuildContext context,
    required CardDesign cardDesign,
    required bool isHovered,
    required bool isRepost,
  }) {
    return BoxDecoration(
      color: cardDesign.backgroundColor,
      borderRadius: BorderRadius.circular(getCardBorderRadius(context)),
      border: isRepost
          ? Border.all(color: Colors.blue.withOpacity(0.3), width: 1.5)
          : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isHovered ? 0.15 : 0.08),
          blurRadius: isHovered ? 25 : 16,
          offset: Offset(0, isHovered ? 8 : 4),
          spreadRadius: isHovered ? 1 : 0,
        ),
      ],
    );
  }

  /// 🌈 СОЗДАЕТ ДЕКОРАТИВНЫЕ ЭЛЕМЕНТЫ ДЛЯ КАРТОЧКИ
  static List<Widget> buildCardDecorations(CardDesign cardDesign, bool isHovered) {
    return [
      // 🔵 ВЕРХНИЙ ПРАВЫЙ КРУГ
      Positioned(
        top: -60,
        right: -60,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          width: isHovered ? 160 : 120,
          height: isHovered ? 160 : 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                cardDesign.gradient[0].withOpacity(isHovered ? 0.12 : 0.08),
                cardDesign.gradient[0].withOpacity(0.02),
              ],
              stops: const [0.1, 1.0],
            ),
          ),
        ),
      ),

      // 🟣 НИЖНИЙ ЛЕВЫЙ КРУГ
      Positioned(
        bottom: -40,
        left: -40,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                cardDesign.gradient[1].withOpacity(0.06),
                cardDesign.gradient[1].withOpacity(0.01),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  /// 📏 СОЗДАЕТ ВЕРХНЮЮ ЛИНИЮ-РАЗДЕЛИТЕЛЬ
  static Widget buildTopLine(BuildContext context, CardDesign cardDesign) {
    final isMobile = MediaQuery.of(context).size.width <= mobileBreakpoint;

    return Container(
      height: 1,
      margin: EdgeInsets.only(
        left: isMobile ? (getAvatarSize(context) + 12 + 16) : 0,
        right: isMobile ? 16 : 0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            cardDesign.gradient[0].withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  /// 🔤 ПОЛУЧАЕТ ИКОНКУ ДЛЯ ТИПА КОНТЕНТА
  static IconData getContentIcon(ContentType contentType) {
    switch (contentType) {
      case ContentType.important:
        return Icons.warning_amber_rounded;
      case ContentType.news:
        return Icons.article_rounded;
      case ContentType.sports:
        return Icons.sports_soccer_rounded;
      case ContentType.tech:
        return Icons.memory_rounded;
      case ContentType.entertainment:
        return Icons.movie_rounded;
      case ContentType.education:
        return Icons.school_rounded;
      default:
        return Icons.trending_up_rounded;
    }
  }

  /// 🎨 ПОЛУЧАЕТ ЦВЕТ ДЛЯ ТИПА КОНТЕНТА
  static Color getContentColor(ContentType contentType, CardDesign cardDesign) {
    switch (contentType) {
      case ContentType.important:
        return const Color(0xFFE74C3C);
      case ContentType.news:
        return const Color(0xFF3498DB);
      case ContentType.tech:
        return const Color(0xFF9B59B6);
      case ContentType.entertainment:
        return const Color(0xFFE67E22);
      default:
        return cardDesign.accentColor;
    }
  }

  /// 📝 ПОЛУЧАЕТ ТЕКСТОВОЕ ОПИСАНИЕ ТИПА КОНТЕНТА
  static String getContentTypeText(ContentType contentType) {
    switch (contentType) {
      case ContentType.important:
        return 'Важное';
      case ContentType.news:
        return 'Новости';
      case ContentType.sports:
        return 'Спорт';
      case ContentType.tech:
        return 'Технологии';
      case ContentType.entertainment:
        return 'Развлечения';
      case ContentType.education:
        return 'Образование';
      default:
        return 'Общее';
    }
  }

  // 🎯 ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
  static String _getStringValue(dynamic value) {
    if (value is String) return value;
    if (value != null) return value.toString();
    return '';
  }

  // 🎨 ПРЕДУСТАНОВЛЕННЫЕ ДИЗАЙНЫ КАРТОЧЕК
  static const List<CardDesign> _cardDesigns = [
    CardDesign(
      gradient: [Color(0xFF667eea), Color(0xFF764ba2)],
      pattern: PatternStyle.minimal,
      decoration: DecorationStyle.modern,
      accentColor: Color(0xFF667eea),
      backgroundColor: Color(0xFFFAFBFF),
    ),
    CardDesign(
      gradient: [Color(0xFF4facfe), Color(0xFF00f2fe)],
      pattern: PatternStyle.geometric,
      decoration: DecorationStyle.modern,
      accentColor: Color(0xFF4facfe),
      backgroundColor: Color(0xFFF7FDFF),
    ),
    CardDesign(
      gradient: [Color(0xFFfa709a), Color(0xFFfee140)],
      pattern: PatternStyle.geometric,
      decoration: DecorationStyle.modern,
      accentColor: Color(0xFFfa709a),
      backgroundColor: Color(0xFFFFFBF9),
    ),
    CardDesign(
      gradient: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
      pattern: PatternStyle.minimal,
      decoration: DecorationStyle.modern,
      accentColor: Color(0xFF8E2DE2),
      backgroundColor: Color(0xFFFBF7FF),
    ),
    CardDesign(
      gradient: [Color(0xFF3A1C71), Color(0xFFD76D77), Color(0xFFFFAF7B)],
      pattern: PatternStyle.geometric,
      decoration: DecorationStyle.modern,
      accentColor: Color(0xFF3A1C71),
      backgroundColor: Color(0xFFFDF7FB),
    ),
  ];
}