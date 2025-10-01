// lib/pages/rooms_pages/advanced_filters_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/room_provider.dart';
import '../../models/room.dart';
import '../../models/room_filters.dart';
import '../chips/tag_chip.dart';

class AdvancedFiltersBottomSheet extends StatefulWidget {
  final VoidCallback onFiltersApplied;

  const AdvancedFiltersBottomSheet({
    super.key,
    required this.onFiltersApplied,
  });

  @override
  State<AdvancedFiltersBottomSheet> createState() => _AdvancedFiltersBottomSheetState();
}

class _AdvancedFiltersBottomSheetState extends State<AdvancedFiltersBottomSheet> {
  late RoomFilters _tempFilters;
  final Set<String> _selectedTags = {};
  final Map<String, bool> _additionalFilters = {
    'hasMedia': false,
    'isVerified': false,
    'isPinned': false,
    'isJoined': false,
  };

  @override
  void initState() {
    super.initState();
    final roomProvider = context.read<RoomProvider>();
    _tempFilters = roomProvider.activeFilters;
    _selectedTags.addAll(roomProvider.selectedTags);

    // Инициализация дополнительных фильтров
    _additionalFilters['hasMedia'] = _tempFilters.hasMedia;
    _additionalFilters['isVerified'] = _tempFilters.isVerified;
    _additionalFilters['isPinned'] = _tempFilters.isPinned;
    _additionalFilters['isJoined'] = _tempFilters.isJoined;
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.watch<RoomProvider>();
    final theme = Theme.of(context);
    final popularTags = roomProvider.getPopularTags(limit: 15);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeader(theme),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Базовые фильтры
                  _buildBasicFilters(roomProvider, theme),

                  // Фильтр по участникам
                  _buildParticipantsFilter(theme),

                  // Фильтр по рейтингу
                  _buildRatingFilter(theme),

                  // Фильтр по дате
                  _buildDateFilter(theme),

                  // Фильтр по тегам
                  _buildTagsFilter(theme, popularTags),

                  // Дополнительные фильтры
                  _buildAdditionalFilters(theme),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildActionButtons(roomProvider),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        const Text(
          'Расширенные фильтры',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildBasicFilters(RoomProvider roomProvider, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Основные настройки',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        // Переключение "Только мои обсуждения"
        SwitchListTile(
          title: const Text('Только мои обсуждения'),
          value: roomProvider.showJoinedOnly,
          onChanged: (value) {
            roomProvider.toggleShowJoinedOnly();
            widget.onFiltersApplied();
          },
        ),

        // Переключение "Только активные комнаты"
        SwitchListTile(
          title: const Text('Только активные комнаты'),
          value: roomProvider.showActiveOnly,
          onChanged: (value) {
            roomProvider.toggleShowActiveOnly();
            widget.onFiltersApplied();
          },
        ),

        // Переключение "Показывать закрепленные первыми"
        SwitchListTile(
          title: const Text('Закрепленные вначале'),
          value: roomProvider.showPinnedFirst,
          onChanged: (value) {
            roomProvider.toggleShowPinnedFirst();
            widget.onFiltersApplied();
          },
        ),
      ],
    );
  }

  Widget _buildParticipantsFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Количество участников',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('От'),
                  TextField(
                    decoration: InputDecoration(
                      hintText: '0',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _tempFilters = _tempFilters.copyWith(
                          minParticipants: int.tryParse(value) ?? 0,
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('До'),
                  TextField(
                    decoration: InputDecoration(
                      hintText: '1000',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _tempFilters = _tempFilters.copyWith(
                          maxParticipants: int.tryParse(value) ?? 1000,
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Минимальный рейтинг',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        Slider(
          value: _tempFilters.minRating,
          min: 0,
          max: 5,
          divisions: 10,
          label: _tempFilters.minRating.toStringAsFixed(1),
          onChanged: (value) {
            setState(() {
              _tempFilters = _tempFilters.copyWith(minRating: value);
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('0.0'),
            Text(
              _tempFilters.minRating.toStringAsFixed(1),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const Text('5.0'),
          ],
        ),
      ],
    );
  }

  Widget _buildDateFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Создано после',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        OutlinedButton(
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _tempFilters.createdAfter ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                _tempFilters = _tempFilters.copyWith(createdAfter: picked);
              });
            }
          },
          child: Text(
            _tempFilters.createdAfter != null
                ? '${_tempFilters.createdAfter!.day}.${_tempFilters.createdAfter!.month}.${_tempFilters.createdAfter!.year}'
                : 'Выберите дату',
          ),
        ),

        if (_tempFilters.createdAfter != null) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _tempFilters = _tempFilters.copyWith(createdAfter: null);
              });
            },
            child: const Text('Очистить дату'),
          ),
        ],
      ],
    );
  }

  Widget _buildTagsFilter(ThemeData theme, Map<String, int> popularTags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Теги',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text(
          'Выберите теги для фильтрации:',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: popularTags.entries.map((entry) {
            final tag = entry.key;
            final count = entry.value;
            final isSelected = _selectedTags.contains(tag);

            return TagChip(
              tag: '$tag ($count)',
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedTags.remove(tag);
                  } else {
                    _selectedTags.add(tag);
                  }
                });
              },
            );
          }).toList(),
        ),

        if (_selectedTags.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Выбранные теги:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedTags.map((tag) {
              return TagChip(
                tag: tag,
                isSelected: true,
                isRemovable: true,
                onTap: () {
                  setState(() {
                    _selectedTags.remove(tag);
                  });
                },
                onRemove: () {
                  setState(() {
                    _selectedTags.remove(tag);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildAdditionalFilters(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Дополнительные фильтры',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        CheckboxListTile(
          title: const Text('С медиафайлами'),
          value: _additionalFilters['hasMedia'],
          onChanged: (value) {
            setState(() {
              _additionalFilters['hasMedia'] = value!;
              _tempFilters = _tempFilters.copyWith(hasMedia: value);
            });
          },
        ),

        CheckboxListTile(
          title: const Text('Проверенные комнаты'),
          value: _additionalFilters['isVerified'],
          onChanged: (value) {
            setState(() {
              _additionalFilters['isVerified'] = value!;
              _tempFilters = _tempFilters.copyWith(isVerified: value);
            });
          },
        ),

        CheckboxListTile(
          title: const Text('Только закрепленные'),
          value: _additionalFilters['isPinned'],
          onChanged: (value) {
            setState(() {
              _additionalFilters['isPinned'] = value!;
              _tempFilters = _tempFilters.copyWith(isPinned: value);
            });
          },
        ),

        CheckboxListTile(
          title: const Text('Только присоединенные'),
          value: _additionalFilters['isJoined'],
          onChanged: (value) {
            setState(() {
              _additionalFilters['isJoined'] = value!;
              _tempFilters = _tempFilters.copyWith(isJoined: value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(RoomProvider roomProvider) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Сбросить все'), // Исправлено: child -> label
                onPressed: () {
                  roomProvider.resetAllFilters();
                  widget.onFiltersApplied();
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Применить'), // Исправлено: child -> label
                onPressed: () {
                  // Применяем расширенные фильтры
                  roomProvider.setFilters(_tempFilters);

                  // Применяем выбранные теги
                  for (final tag in roomProvider.selectedTags.toList()) {
                    if (!_selectedTags.contains(tag)) {
                      roomProvider.toggleTag(tag);
                    }
                  }
                  for (final tag in _selectedTags) {
                    if (!roomProvider.selectedTags.contains(tag)) {
                      roomProvider.toggleTag(tag);
                    }
                  }

                  widget.onFiltersApplied();
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}