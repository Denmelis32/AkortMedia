import 'package:flutter/material.dart';
import './models/tournament_model.dart';
import './widgets/tournament_list.dart';
import './widgets/confirmation_dialog.dart';
import './widgets/payment_dialog.dart';
import './tournament_details_page.dart';

class PredictionsLeaguePage extends StatefulWidget {
  final String userId;
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const PredictionsLeaguePage({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  State<PredictionsLeaguePage> createState() => _PredictionsLeaguePageState();
}

class _PredictionsLeaguePageState extends State<PredictionsLeaguePage> {
  final List<Tournament> tournaments = [
    Tournament(
      id: '1',
      name: 'Чемпионат Премьер-Лиги',
      description: 'Прогнозируйте результаты матчей АПЛ',
      entryFee: 0,
      prizePool: 10000,
      participants: 2450,
      startDate: DateTime.now().add(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 30)),
      isFree: true,
    ),
    Tournament(
      id: '2',
      name: 'Кубок Лиги Чемпионов',
      description: 'Эксклюзивный турнир для профессионалов',
      entryFee: 500,
      prizePool: 50000,
      participants: 890,
      startDate: DateTime.now().add(const Duration(days: 5)),
      endDate: DateTime.now().add(const Duration(days: 45)),
      isFree: false,
    ),
    Tournament(
      id: '3',
      name: 'Лига Европы Прогнозов',
      description: 'Турнир для настоящих знатоков футбола',
      entryFee: 0,
      prizePool: 15000,
      participants: 3120,
      startDate: DateTime.now().add(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 25)),
      isFree: true,
    ),
    Tournament(
      id: '4',
      name: 'Премиум Кубок',
      description: 'Только для избранных прогнозистов',
      entryFee: 1000,
      prizePool: 100000,
      participants: 450,
      startDate: DateTime.now().add(const Duration(days: 7)),
      endDate: DateTime.now().add(const Duration(days: 60)),
      isFree: false,
    ),
  ];

  final Set<String> _joinedTournaments = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Лига Прогнозов',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 8,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout,
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.deepPurple.shade50,
                Colors.blue.shade50,
              ],
            ),
          ),
          child: TournamentList(
            tournaments: tournaments,
            joinedTournaments: _joinedTournaments,
            onJoinTournament: _joinTournament,
            onOpenTournamentDetails: _openTournamentDetails,
          ),
        ),
      ),
    );
  }

  void _joinTournament(Tournament tournament) {
    if (tournament.isFree) {
      _showConfirmationDialog(tournament);
    } else {
      _showPaymentDialog(tournament);
    }
  }

  void _showConfirmationDialog(Tournament tournament) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        tournament: tournament,
        onConfirm: () => _completeRegistration(tournament),
      ),
    );
  }

  void _showPaymentDialog(Tournament tournament) {
    showDialog(
      context: context,
      builder: (context) => PaymentDialog(
        tournament: tournament,
        onPay: () => _completeRegistration(tournament),
      ),
    );
  }

  void _completeRegistration(Tournament tournament) {
    setState(() {
      _joinedTournaments.add(tournament.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Вы успешно присоединились к турниру "${tournament.name}"!',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'Перейти',
          textColor: Colors.white,
          onPressed: () => _openTournamentDetails(tournament),
        ),
      ),
    );
  }

  void _openTournamentDetails(Tournament tournament) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TournamentDetailsPage(
          tournament: tournament,
          userName: widget.userName,
        ),
      ),
    );
  }
}