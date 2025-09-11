import 'package:flutter/material.dart';
import '../models/tournament_model.dart';
import 'tournament_card.dart';

class TournamentList extends StatelessWidget {
  final List<Tournament> tournaments;
  final Set<String> joinedTournaments;
  final Function(Tournament) onJoinTournament;
  final Function(Tournament) onOpenTournamentDetails;

  const TournamentList({
    super.key,
    required this.tournaments,
    required this.joinedTournaments,
    required this.onJoinTournament,
    required this.onOpenTournamentDetails,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tournaments.length,
      itemBuilder: (context, index) {
        final tournament = tournaments[index];
        final isJoined = joinedTournaments.contains(tournament.id);

        return TournamentCard(
          tournament: tournament,
          isJoined: isJoined,
          onJoin: () => onJoinTournament(tournament),
          onOpenDetails: () => onOpenTournamentDetails(tournament),
        );
      },
    );
  }
}