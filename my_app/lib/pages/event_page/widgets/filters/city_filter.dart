import 'package:flutter/material.dart';

class CityFilter extends StatelessWidget {
  final String selectedCity;
  final List<String> cities;
  final ValueChanged<String> onCityChanged;

  const CityFilter({
    Key? key,
    required this.selectedCity,
    required this.cities,
    required this.onCityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Город', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: cities.map((city) => _buildFilterChip(city, selectedCity == city)).toList(),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool selected) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (value) => onCityChanged(label),
      backgroundColor: Colors.grey[100],
      selectedColor: Colors.blue.withOpacity(0.2),
      checkmarkColor: Colors.blue,
      labelStyle: TextStyle(color: selected ? Colors.blue : Colors.black87),
    );
  }
}