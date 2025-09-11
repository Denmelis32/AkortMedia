import 'package:intl/intl.dart';

class Tournament {
  final String id;
  final String name;
  final String description;
  final int entryFee;
  final int prizePool;
  final int participants;
  final DateTime startDate;
  final DateTime endDate;
  final bool isFree;
  final String creatorId; // Добавляем поле создателя

  Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.entryFee,
    required this.prizePool,
    required this.participants,
    required this.startDate,
    required this.endDate,
    required this.isFree,
    required this.creatorId, // Обязательное поле
  });

  String get formattedStartDate => DateFormat('dd.MM').format(startDate);
  String get formattedFullStartDate => DateFormat('dd.MM.yyyy').format(startDate);
  String get formattedEndDate => DateFormat('dd.MM.yyyy').format(endDate);
}