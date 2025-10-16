import 'package:flutter/material.dart';

class PriceFilter extends StatelessWidget {
  final double priceRange;
  final ValueChanged<double> onPriceRangeChanged;

  const PriceFilter({
    Key? key,
    required this.priceRange,
    required this.onPriceRangeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Максимальная цена', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text(
              priceRange == 0 ? 'Бесплатно' : '${priceRange.toInt()} ₽',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: priceRange,
          min: 0,
          max: 10000,
          divisions: 20,
          onChanged: onPriceRangeChanged,
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0 ₽', style: TextStyle(color: Colors.grey)),
            Text('10 000 ₽', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}