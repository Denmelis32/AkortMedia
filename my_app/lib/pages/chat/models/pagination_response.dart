import 'chat_message.dart';

class PaginationResponse<T> {
  final List<ChatMessage> messages;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasMore;

  const PaginationResponse({
    required this.messages,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.hasMore,
  });

  bool get isEmpty => messages.isEmpty;
  bool get isLastPage => !hasMore;
}