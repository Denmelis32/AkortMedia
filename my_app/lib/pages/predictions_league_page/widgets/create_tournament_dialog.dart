import 'package:flutter/material.dart';
import '../models/tournament_model.dart';

class CreateTournamentDialog extends StatefulWidget {
  final Function(Tournament) onCreateTournament;
  final String userId; // Добавляем userId

  const CreateTournamentDialog({
    super.key,
    required this.onCreateTournament,
    required this.userId, // Обязательный параметр
  });

  @override
  State<CreateTournamentDialog> createState() => _CreateTournamentDialogState();
}

class _CreateTournamentDialogState extends State<CreateTournamentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prizePoolController = TextEditingController(text: '0');
  final _entryFeeController = TextEditingController(text: '0');
  bool _isFree = true;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _prizePoolController.dispose();
    _entryFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Создать турнир'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Название турнира*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите название турнира';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание турнира*',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите описание турнира';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isFree,
                    onChanged: (value) {
                      setState(() {
                        _isFree = value!;
                      });
                    },
                  ),
                  const Text('Бесплатный турнир'),
                ],
              ),
              if (!_isFree) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _entryFeeController,
                  decoration: const InputDecoration(
                    labelText: 'Стоимость участия (₽)*',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (!_isFree && (value == null || value.isEmpty)) {
                      return 'Введите стоимость участия';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _prizePoolController,
                decoration: const InputDecoration(
                  labelText: 'Призовой фонд (₽)*',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите призовой фонд';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _createTournament,
          child: const Text('Создать'),
        ),
      ],
    );
  }

  void _createTournament() {
    if (_formKey.currentState!.validate()) {
      final tournament = Tournament(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        entryFee: int.parse(_entryFeeController.text),
        prizePool: int.parse(_prizePoolController.text),
        participants: 0,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        isFree: _isFree,
        creatorId: widget.userId, // Добавляем creatorId
      );

      widget.onCreateTournament(tournament);
      Navigator.pop(context);
    }
  }
}