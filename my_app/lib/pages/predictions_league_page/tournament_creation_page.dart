import 'package:flutter/material.dart';
import './models/tournament_model.dart';
import './models/match_model.dart';
import './widgets/add_match_dialog.dart';
// Убедитесь что tournament_admin_panel.dart существует по этому пути
import './widgets/tournament_admin_panel.dart';

class TournamentCreationPage extends StatefulWidget {
  final Tournament? tournament;
  final Function(Tournament, List<Match>) onSaveTournament;
  final String userId;

  const TournamentCreationPage({
    super.key,
    this.tournament,
    required this.onSaveTournament,
    required this.userId,
  });

  @override
  State<TournamentCreationPage> createState() => _TournamentCreationPageState();
}

class _TournamentCreationPageState extends State<TournamentCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prizePoolController = TextEditingController();
  final _entryFeeController = TextEditingController();
  bool _isFree = true;
  final List<Match> _matches = [];

  @override
  void initState() {
    super.initState();
    if (widget.tournament != null) {
      _nameController.text = widget.tournament!.name;
      _descriptionController.text = widget.tournament!.description;
      _prizePoolController.text = widget.tournament!.prizePool.toString();
      _entryFeeController.text = widget.tournament!.entryFee.toString();
      _isFree = widget.tournament!.isFree;
    }
  }

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tournament == null ? 'Создание турнира' : 'Редактирование турнира'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTournament,
            tooltip: 'Сохранить турнир',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Основная информация о турнире
              _buildTournamentInfoSection(),
              const SizedBox(height: 24),

              // Статистика матчей
              _buildMatchesStats(),
              const SizedBox(height: 16),

              // Управление матчами
              TournamentAdminPanel(
                matches: _matches,
                onAddMatch: _addMatch,
                onEditMatch: _editMatch,
                onDeleteMatch: _deleteMatch,
              ),

              const SizedBox(height: 24),

              // Кнопка сохранения
              _buildSaveButton(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMatchDialog,
        child: const Icon(Icons.add),
        tooltip: 'Добавить матч',
      ),
    );
  }

  Widget _buildTournamentInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Информация о турнире',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Название турнира*',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.emoji_events),
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
                prefixIcon: Icon(Icons.description),
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
                const SizedBox(width: 16),
                Icon(
                  _isFree ? Icons.lock_open : Icons.lock,
                  color: _isFree ? Colors.green : Colors.amber,
                ),
              ],
            ),
            if (!_isFree) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _entryFeeController,
                decoration: const InputDecoration(
                  labelText: 'Стоимость участия (₽)*',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (!_isFree && (value == null || value.isEmpty)) {
                    return 'Введите стоимость участия';
                  }
                  if (!_isFree && int.tryParse(value ?? '0') == 0) {
                    return 'Стоимость должна быть больше 0';
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
                prefixIcon: Icon(Icons.account_balance_wallet),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите призовой фонд';
                }
                if (int.tryParse(value) == 0) {
                  return 'Призовой фонд должен быть больше 0';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchesStats() {
    final upcomingMatches = _matches.where((m) => m.status == 'scheduled').length;
    final liveMatches = _matches.where((m) => m.status == 'live').length;
    final finishedMatches = _matches.where((m) => m.status == 'finished').length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('Всего матчей', _matches.length.toString(), Icons.sports_soccer),
        _buildStatItem('Предстоит', upcomingMatches.toString(), Icons.access_time),
        _buildStatItem('Завершено', finishedMatches.toString(), Icons.check_circle),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurple),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveTournament,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.save),
          SizedBox(width: 8),
          Text(
            'СОХРАНИТЬ ТУРНИР',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showAddMatchDialog() {
    showDialog(
      context: context,
      builder: (context) => AddMatchDialog(onAddMatch: _addMatch),
    );
  }

  void _addMatch(Match match) {
    setState(() {
      _matches.add(match);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Матч "${match.matchTitle}" добавлен'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editMatch(Match match) {
    // Реализация редактирования матча
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактирование матча'),
        content: const Text('Функция редактирования матча будет реализована в следующем обновлении'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _deleteMatch(String matchId) {
    setState(() {
      _matches.removeWhere((match) => match.id == matchId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Матч удален'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _saveTournament() {
    if (_formKey.currentState!.validate()) {
      if (_matches.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Добавьте хотя бы один матч в турнир'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final tournament = Tournament(
        id: widget.tournament?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        entryFee: int.parse(_entryFeeController.text),
        prizePool: int.parse(_prizePoolController.text),
        participants: widget.tournament?.participants ?? 0,
        startDate: _getEarliestMatchDate(),
        endDate: _getLatestMatchDate(),
        isFree: _isFree,
        creatorId: widget.tournament?.creatorId ?? widget.userId,
      );

      widget.onSaveTournament(tournament, _matches);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Турнир "${tournament.name}" успешно ${widget.tournament == null ? 'создан' : 'обновлен'}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Возвращаемся назад через секунду
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }

  DateTime _getEarliestMatchDate() {
    if (_matches.isEmpty) return DateTime.now();
    return _matches.map((m) => m.matchTime).reduce(
          (a, b) => a.isBefore(b) ? a : b,
    );
  }

  DateTime _getLatestMatchDate() {
    if (_matches.isEmpty) return DateTime.now().add(const Duration(days: 30));
    return _matches.map((m) => m.matchTime).reduce(
          (a, b) => a.isAfter(b) ? a : b,
    );
  }
}