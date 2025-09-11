import 'package:flutter/material.dart';
import '../models/match_model.dart';

class PredictionDialog extends StatefulWidget {
  final Match match;
  final Function(int homeScore, int awayScore) onSavePrediction;

  const PredictionDialog({
    super.key,
    required this.match,
    required this.onSavePrediction,
  });

  @override
  State<PredictionDialog> createState() => _PredictionDialogState();
}

class _PredictionDialogState extends State<PredictionDialog> {
  final _homeController = TextEditingController();
  final _awayController = TextEditingController();

  @override
  void dispose() {
    _homeController.dispose();
    _awayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Сделать прогноз'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.match.matchTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Счет домашней команды
              SizedBox(
                width: 60,
                child: TextField(
                  controller: _homeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    labelText: 'Дома',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  ':',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              // Счет гостевой команды
              SizedBox(
                width: 60,
                child: TextField(
                  controller: _awayController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    labelText: 'Гости',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Введите предполагаемый счет матча',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _savePrediction,
          child: const Text('Сохранить'),
        ),
      ],
    );
  }

  void _savePrediction() {
    final homeScore = int.tryParse(_homeController.text) ?? 0;
    final awayScore = int.tryParse(_awayController.text) ?? 0;

    if (homeScore >= 0 && awayScore >= 0) {
      widget.onSavePrediction(homeScore, awayScore);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, введите корректный счет'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}