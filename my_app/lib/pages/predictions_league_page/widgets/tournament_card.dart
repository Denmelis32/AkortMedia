import 'package:flutter/material.dart';
import '../models/tournament_model.dart';

class TournamentCard extends StatelessWidget {
  final Tournament tournament;
  final bool isJoined;
  final VoidCallback onJoin;
  final VoidCallback onOpenDetails;

  const TournamentCard({
    super.key,
    required this.tournament,
    required this.isJoined,
    required this.onJoin,
    required this.onOpenDetails,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isJoined ? onOpenDetails : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: isJoined
              ? Border.all(color: Colors.green, width: 2)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBadge(),
              const SizedBox(height: 16),
              _buildTitle(),
              const SizedBox(height: 8),
              _buildDescription(),
              const SizedBox(height: 16),
              _buildInfoRow(),
              const SizedBox(height: 16),
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: tournament.isFree
                ? Colors.green.shade400
                : Colors.amber.shade700,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            tournament.isFree ? 'БЕСПЛАТНО' : 'ПРЕМИУМ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (isJoined)
          const Icon(Icons.check_circle, color: Colors.green, size: 24),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      tournament.name,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      tournament.description,
      style: TextStyle(
        color: Colors.grey.shade700,
        fontSize: 14,
      ),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        _buildInfoItem(Icons.people, '${tournament.participants}'),
        const SizedBox(width: 16),
        _buildInfoItem(Icons.attach_money, '${tournament.prizePool.toStringAsFixed(0)} ₽'),
        const SizedBox(width: 16),
        _buildInfoItem(Icons.calendar_today, tournament.formattedStartDate),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: isJoined
          ? OutlinedButton(
        onPressed: onOpenDetails,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.green,
          side: const BorderSide(color: Colors.green),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          'ПЕРЕЙТИ К ТУРНИРУ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      )
          : ElevatedButton(
        onPressed: onJoin,
        style: ElevatedButton.styleFrom(
          backgroundColor: tournament.isFree
              ? Colors.deepPurple
              : Colors.amber.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        child: Text(
          tournament.isFree
              ? 'УЧАСТВОВАТЬ БЕСПЛАТНО'
              : 'УЧАСТВОВАТЬ ЗА ${tournament.entryFee} ₽',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}