import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../models/user_stats.dart';

class UserRanking extends StatelessWidget {
  final List<UserStats> userStats;
  final String currentUserId;

  const UserRanking({
    super.key,
    required this.userStats,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final sortedUsers = userStats.sorted((a, b) => b.points.compareTo(a.points));

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏆 ТУРНИРНАЯ ТАБЛИЦА',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          if (sortedUsers.isEmpty)
            const Text(
              'Пока нет результатов',
              style: TextStyle(color: Colors.grey),
            )
          else
            ...sortedUsers.map((user) {
              final isCurrentUser = user.userId == currentUserId;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Container(
                  decoration: isCurrentUser
                      ? BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue, width: 1),
                  )
                      : null,
                  padding: isCurrentUser
                      ? const EdgeInsets.all(8)
                      : EdgeInsets.zero,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: isCurrentUser
                            ? Colors.blue[200]
                            : Colors.blue[100],
                        radius: 16,
                        child: Text(
                          user.userAvatar,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.userName,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: isCurrentUser
                                    ? Colors.blue[800]
                                    : Colors.black87,
                              ),
                            ),
                            Text(
                              '${user.wins}-${user.draws}-${user.losses} | Угадано: ${user.correctPredictions}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCurrentUser
                              ? Colors.blue[100]
                              : Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCurrentUser
                                ? Colors.blue
                                : Colors.green,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${user.points} очков',
                          style: TextStyle(
                            color: isCurrentUser
                                ? Colors.blue[800]
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}