import 'package:flutter/material.dart';
import '../models/tournament_model.dart';
import 'tournament_card.dart';

class TournamentList extends StatelessWidget {
  final List<Tournament> tournaments;
  final Set<String> joinedTournaments;
  final Function(Tournament) onJoinTournament;
  final Function(Tournament) onOpenTournamentDetails;
  final Function(Tournament)? onEditTournament; // Делаем необязательным
  final String? userId; // Добавляем userId
  final bool showEditOptions; // Флаг для показа кнопок редактирования

  const TournamentList({
    super.key,
    required this.tournaments,
    required this.joinedTournaments,
    required this.onJoinTournament,
    required this.onOpenTournamentDetails,
    this.onEditTournament,
    this.userId,
    this.showEditOptions = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tournaments.length,
      itemBuilder: (context, index) {
        final tournament = tournaments[index];
        final isJoined = joinedTournaments.contains(tournament.id);
        final isCreator = userId != null && tournament.creatorId == userId;

        return TournamentCard(
          tournament: tournament,
          isJoined: isJoined,
          isCreator: isCreator,
          showEditOptions: showEditOptions && isCreator,
          onJoin: () => onJoinTournament(tournament),
          onOpenDetails: () => onOpenTournamentDetails(tournament),
          onEdit: onEditTournament != null ? () => onEditTournament!(tournament) : null,
        );
      },
    );
  }
}