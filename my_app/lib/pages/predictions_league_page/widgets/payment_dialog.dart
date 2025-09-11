import 'package:flutter/material.dart';
import '../models/tournament_model.dart';

class PaymentDialog extends StatelessWidget {
  final Tournament tournament;
  final VoidCallback onPay;

  const PaymentDialog({
    super.key,
    required this.tournament,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Оплата участия'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Турнир: ${tournament.name}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Стоимость: ${tournament.entryFee} ₽'),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Номер карты',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Срок',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'CVV',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onPay();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          child: const Text('Оплатить'),
        ),
      ],
    );
  }
}