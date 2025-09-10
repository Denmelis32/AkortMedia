import 'package:flutter/material.dart';
import '../models/match.dart';

class AddPredictionForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<Map<String, dynamic>> leagues;
  final List<Match> matches;
  final String selectedLeague;
  final String selectedMatchId;
  final TextEditingController predictionController;
  final Function(String?) onLeagueChanged;
  final Function(String?) onMatchChanged;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const AddPredictionForm({
    super.key,
    required this.formKey,
    required this.leagues,
    required this.matches,
    required this.selectedLeague,
    required this.selectedMatchId,
    required this.predictionController,
    required this.onLeagueChanged,
    required this.onMatchChanged,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final availableMatches = matches.where((m) => !m.isFinished).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Новый прогноз',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 20),
        Form(
          key: formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: selectedLeague,
                decoration: InputDecoration(
                  labelText: 'Лига',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: leagues.map((league) {
                  return DropdownMenuItem<String>(
                    value: league['name'],
                    child: Text(league['name']),
                  );
                }).toList(),
                onChanged: onLeagueChanged,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedMatchId,
                decoration: InputDecoration(
                  labelText: 'Матч',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: availableMatches.map<DropdownMenuItem<String>>((match) {
                  return DropdownMenuItem<String>(
                    value: match.id,
                    child: Text(match.name),
                  );
                }).toList(),
                onChanged: onMatchChanged,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: predictionController,
                decoration: InputDecoration(
                  labelText: 'Прогноз (например: 2:1)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите прогноз';
                  }
                  if (!RegExp(r'^\d+:\d+$').hasMatch(value)) {
                    return 'Формат: число:число (например: 2:1)';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                child: Text(
                  'Отмена',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Добавить',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}