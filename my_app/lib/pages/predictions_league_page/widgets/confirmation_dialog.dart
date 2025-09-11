import 'package:flutter/material.dart';
import '../models/tournament_model.dart';

class ConfirmationDialog extends StatelessWidget {
  final Tournament tournament;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.tournament,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Присоединиться к турниру'),
      content: Text(
        'Вы уверены, что хотите присоединиться к турниру "${tournament.name}"?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: const Text('Присоединиться'),
        ),
      ],
    );
  }
}