import 'package:flutter/foundation.dart';

@immutable
class PaginationState {
  final int currentPage;
  final int itemsPerPage;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final int totalItems;
  final DateTime? lastUpdated;

  const PaginationState({
    this.currentPage = 1,
    this.itemsPerPage = 50,
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.totalItems = 0,
    this.lastUpdated,
  });

  PaginationState copyWith({
    int? currentPage,
    int? itemsPerPage,
    bool? isLoading,
    bool? hasMore,
    String? error,
    int? totalItems,
    DateTime? lastUpdated,
  }) {
    return PaginationState(
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      totalItems: totalItems ?? this.totalItems,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaginationState &&
        other.currentPage == currentPage &&
        other.itemsPerPage == itemsPerPage &&
        other.isLoading == isLoading &&
        other.hasMore == hasMore &&
        other.error == error &&
        other.totalItems == totalItems &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return Object.hash(
      currentPage,
      itemsPerPage,
      isLoading,
      hasMore,
      error,
      totalItems,
      lastUpdated,
    );
  }

  bool get canLoadMore => hasMore && !isLoading;
  bool get hasError => error != null;
  int get loadedItems => (currentPage - 1) * itemsPerPage;
  double get progress => totalItems > 0 ? loadedItems / totalItems : 0.0;
}