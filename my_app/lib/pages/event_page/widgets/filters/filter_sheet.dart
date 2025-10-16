import 'package:flutter/material.dart';
import 'package:my_app/pages/event_page/widgets/filters/city_filter.dart';
import 'package:my_app/pages/event_page/widgets/filters/date_filter.dart';
import 'package:my_app/pages/event_page/widgets/filters/price_filter.dart';
import 'package:my_app/pages/event_page/widgets/filters/sort_filter.dart';
import 'package:my_app/pages/event_page/widgets/filters/tags_filter.dart';

class FilterBottomSheet extends StatefulWidget {
  final DateTime? selectedDate;
  final double priceRange;
  final String selectedCity;
  final List<String> selectedTags;
  final String sortBy;
  final bool showFreeOnly;
  final bool showOnlineOnly;
  final List<String> cities;
  final List<String> popularTags;
  final ValueChanged<DateTime?> onDateChanged;
  final ValueChanged<double> onPriceRangeChanged;
  final ValueChanged<String> onCityChanged;
  final ValueChanged<List<String>> onTagsChanged;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<bool> onFreeOnlyChanged;
  final ValueChanged<bool> onOnlineOnlyChanged;
  final VoidCallback onReset;
  final VoidCallback onApply;

  const FilterBottomSheet({
    Key? key,
    required this.selectedDate,
    required this.priceRange,
    required this.selectedCity,
    required this.selectedTags,
    required this.sortBy,
    required this.showFreeOnly,
    required this.showOnlineOnly,
    required this.cities,
    required this.popularTags,
    required this.onDateChanged,
    required this.onPriceRangeChanged,
    required this.onCityChanged,
    required this.onTagsChanged,
    required this.onSortChanged,
    required this.onFreeOnlyChanged,
    required this.onOnlineOnlyChanged,
    required this.onReset,
    required this.onApply,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late DateTime? _selectedDate;
  late double _priceRange;
  late String _selectedCity;
  late List<String> _selectedTags;
  late String _sortBy;
  late bool _showFreeOnly;
  late bool _showOnlineOnly;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _priceRange = widget.priceRange;
    _selectedCity = widget.selectedCity;
    _selectedTags = List.from(widget.selectedTags);
    _sortBy = widget.sortBy;
    _showFreeOnly = widget.showFreeOnly;
    _showOnlineOnly = widget.showOnlineOnly;
  }

  void _applyChanges() {
    widget.onDateChanged(_selectedDate);
    widget.onPriceRangeChanged(_priceRange);
    widget.onCityChanged(_selectedCity);
    widget.onTagsChanged(_selectedTags);
    widget.onSortChanged(_sortBy);
    widget.onFreeOnlyChanged(_showFreeOnly);
    widget.onOnlineOnlyChanged(_showOnlineOnly);
    widget.onApply();
  }

  void _resetAll() {
    setState(() {
      _selectedDate = null;
      _priceRange = 5000;
      _selectedCity = 'Москва';
      _selectedTags.clear();
      _sortBy = 'date';
      _showFreeOnly = false;
      _showOnlineOnly = false;
    });
    widget.onReset();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Фильтры и сортировка',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Сортировка
                  SortFilter(
                    sortBy: _sortBy,
                    onSortChanged: (value) => setState(() => _sortBy = value),
                  ),
                  const SizedBox(height: 24),

                  // Фильтры по дате
                  DateFilter(
                    selectedDate: _selectedDate,
                    onDateChanged: (date) => setState(() => _selectedDate = date),
                  ),
                  const SizedBox(height: 24),

                  // Фильтр по цене
                  PriceFilter(
                    priceRange: _priceRange,
                    onPriceRangeChanged: (value) => setState(() => _priceRange = value),
                  ),
                  const SizedBox(height: 24),

                  // Фильтр по городу
                  CityFilter(
                    selectedCity: _selectedCity,
                    cities: widget.cities,
                    onCityChanged: (city) => setState(() => _selectedCity = city),
                  ),
                  const SizedBox(height: 24),

                  // Дополнительные фильтры
                  _buildAdditionalFilters(),
                  const SizedBox(height: 24),

                  // Фильтр по тегам
                  TagsFilter(
                    selectedTags: _selectedTags,
                    popularTags: widget.popularTags,
                    onTagsChanged: (tags) => setState(() => _selectedTags = tags),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildAdditionalFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Дополнительно', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildSwitchFilter(
                'Только бесплатные',
                _showFreeOnly,
                    (value) => setState(() => _showFreeOnly = value),
              ),
            ),
            Expanded(
              child: _buildSwitchFilter(
                'Только онлайн',
                _showOnlineOnly,
                    (value) => setState(() => _showOnlineOnly = value),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSwitchFilter(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.blue,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _resetAll,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Сбросить все'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _applyChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Применить фильтры'),
            ),
          ),
        ],
      ),
    );
  }
}