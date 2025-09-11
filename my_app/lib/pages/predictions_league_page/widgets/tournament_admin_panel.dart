import 'package:flutter/material.dart';
import '../models/match_model.dart';
import './add_match_dialog.dart';

class TournamentAdminPanel extends StatelessWidget {
  final List<Match> matches;
  final Function(Match) onAddMatch;
  final Function(Match) onEditMatch;
  final Function(String) onDeleteMatch;

  const TournamentAdminPanel({
    super.key,
    required this.matches,
    required this.onAddMatch,
    required this.onEditMatch,
    required this.onDeleteMatch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Управление матчами',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _showAddMatchDialog(context),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add),
              SizedBox(width: 8),
              Text('Добавить матч'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...matches.map((match) => _buildMatchItem(match, context)),
      ],
    );
  }

  Widget _buildMatchItem(Match match, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(match.matchTitle),
        subtitle: Text('${match.formattedDate} ${match.formattedTime}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _showEditMatchDialog(match, context),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => _confirmDeleteMatch(match, context),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMatchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddMatchDialog(onAddMatch: onAddMatch),
    );
  }

  void _showEditMatchDialog(Match match, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактирование матча'),
        content: const Text('Функция в разработке'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteMatch(Match match, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить матч?'),
        content: Text('Вы уверены, что хотите удалить матч "${match.matchTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              onDeleteMatch(match.id);
              Navigator.pop(context);
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}