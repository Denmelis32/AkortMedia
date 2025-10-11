import 'package:flutter/material.dart';

class NewsPageState with ChangeNotifier {
  int _currentFilter = 0;
  String _searchQuery = '';
  bool _isSearching = false;
  final ScrollController scrollController = ScrollController();
  final List<String> _recentSearches = []; // Добавляем список последних поисков

  int get currentFilter => _currentFilter;
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;
  List<String> get recentSearches => _recentSearches; // Геттер для recentSearches

  void setFilter(int filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSearching(bool searching) {
    _isSearching = searching;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _isSearching = false;
    notifyListeners();
  }

  // Метод для добавления в историю поиска
  void addToRecentSearches(String query) {
    if (query.trim().isNotEmpty) {
      // Удаляем дубликаты
      _recentSearches.remove(query);
      // Добавляем в начало
      _recentSearches.insert(0, query);
      // Ограничиваем размер истории (максимум 5 записей)
      if (_recentSearches.length > 5) {
        _recentSearches.removeLast();
      }
      notifyListeners();
    }
  }

  // Метод для очистки истории поиска
  void clearRecentSearches() {
    _recentSearches.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}