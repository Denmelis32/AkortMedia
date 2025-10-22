import 'package:flutter/material.dart';
import 'package:my_app/pages/articles_pages/services/layout_service.dart';
import 'package:my_app/pages/articles_pages/widgets/article_card.dart';
import 'package:my_app/pages/articles_pages/services/article_service.dart';

class ArticlesGrid extends StatelessWidget {
  final List<Map<String, dynamic>> articles;
  final bool isLoadingMore;
  final bool isSelectionMode;
  final Set<String> selectedArticles;
  final Set<String> favoriteArticleIds;
  final Function(Map<String, dynamic>) onArticleTap;
  final Function(String) onArticleLongPress;
  final Function(Map<String, dynamic>) onArticleQuickPreview;
  final VoidCallback onSelectionModeToggled;
  final Function(String) onFavoriteToggled;

  const ArticlesGrid({
    super.key,
    required this.articles,
    required this.isLoadingMore,
    required this.isSelectionMode,
    required this.selectedArticles,
    required this.favoriteArticleIds,
    required this.onArticleTap,
    required this.onArticleLongPress,
    required this.onArticleQuickPreview,
    required this.onSelectionModeToggled,
    required this.onFavoriteToggled,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = LayoutService.isMobile(context);

    if (articles.isEmpty) {
      return _buildEmptyState();
    }

    if (isMobile) {
      return _buildMobileList(context);
    }

    return _buildDesktopGrid(context);
  }

  Widget _buildEmptyState() {
    return const SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_rounded, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Статьи не найдены',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Попробуйте изменить параметры поиска',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileList(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          if (index >= articles.length) return const SizedBox.shrink();

          final articleData = articles[index];
          final article = ArticleService.articleFromMap(articleData);

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: GestureDetector(
              onLongPress: () => onArticleQuickPreview(articleData),
              child: Stack(
                children: [
                  ArticleCard(
                    key: ValueKey(article.id),
                    article: article,
                    onTap: () => onArticleTap(articleData),
                    onLongPress: () {
                      if (!isSelectionMode) {
                        onSelectionModeToggled();
                      }
                      onArticleLongPress(article.id);
                    },
                    cardPadding: LayoutService.getCardPadding(context),
                  ),
                  if (isSelectionMode)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Checkbox(
                          value: selectedArticles.contains(article.id),
                          onChanged: (_) => onArticleLongPress(article.id),
                          fillColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  if (favoriteArticleIds.contains(article.id))
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => onFavoriteToggled(article.id),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.favorite_rounded, size: 16, color: Colors.red),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
        childCount: articles.length,
      ),
    );
  }

  Widget _buildDesktopGrid(BuildContext context) {
    final horizontalPadding = LayoutService.getHorizontalPadding(context);
    final gridSpacing = LayoutService.getGridSpacing(context);

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: LayoutService.getCrossAxisCount(context),
          crossAxisSpacing: gridSpacing,
          mainAxisSpacing: gridSpacing,
          childAspectRatio: LayoutService.calculateFixedAspectRatio(context),
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            if (index == articles.length && isLoadingMore) {
              return const Center(child: CircularProgressIndicator());
            }
            if (index >= articles.length) return const SizedBox.shrink();

            final articleData = articles[index];
            final article = ArticleService.articleFromMap(articleData);

            return GestureDetector(
              onLongPress: () => onArticleQuickPreview(articleData),
              child: Container(
                margin: const EdgeInsets.all(2),
                child: Stack(
                  children: [
                    ArticleCard(
                      key: ValueKey(article.id),
                      article: article,
                      onTap: () => onArticleTap(articleData),
                      onLongPress: () {
                        if (!isSelectionMode) {
                          onSelectionModeToggled();
                        }
                        onArticleLongPress(article.id);
                      },
                      cardPadding: LayoutService.getCardPadding(context),
                    ),
                    if (isSelectionMode)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Checkbox(
                            value: selectedArticles.contains(article.id),
                            onChanged: (_) => onArticleLongPress(article.id),
                            fillColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
                          ),
                        ),
                      ),
                    if (favoriteArticleIds.contains(article.id))
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => onFavoriteToggled(article.id),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.favorite_rounded, size: 16, color: Colors.red),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
          childCount: articles.length + (isLoadingMore ? 1 : 0),
        ),
      ),
    );
  }
}