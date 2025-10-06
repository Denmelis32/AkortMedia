import 'package:flutter/material.dart';

class NewsPageState with ChangeNotifier {
  int _currentFilter = 0;
  String _searchQuery = '';
  bool _isSearching = false;
  final ScrollController scrollController = ScrollController();

  int get currentFilter => _currentFilter;
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;

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

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}