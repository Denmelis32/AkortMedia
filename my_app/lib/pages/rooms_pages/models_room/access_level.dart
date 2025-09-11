import 'package:flutter/material.dart';

enum AccessLevel {
  everyone('Для всех', Icons.public, Colors.green),
  seniorOnly('Только сеньоры', Icons.engineering, Colors.blue),
  longTermFans('Долгосрочные фанаты', Icons.favorite, Colors.pink);

  final String label;
  final IconData icon;
  final Color color;

  const AccessLevel(this.label, this.icon, this.color);
}