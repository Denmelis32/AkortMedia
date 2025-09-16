import 'package:flutter/material.dart';
import 'league_detail_page.dart';
import 'models/league_model.dart';
import 'models/match_model.dart';

class PredictionsLeaguePage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const PredictionsLeaguePage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  State<PredictionsLeaguePage> createState() => _PredictionsLeaguePageState();
}

class _PredictionsLeaguePageState extends State<PredictionsLeaguePage> {
  final List<League> _leagues = [
    League(
      id: 1,
      title: 'Премьер-Лига Англии',
      description: 'Прогнозы на матчи английской премьер-лиги',
      imageUrl: 'https://images.unsplash.com/photo-1596510913920-85d87a1800d2?w=400',
      participants: 12450,
      matches: [
        Match(
          id: 1,
          teamHome: 'Манчестер Юнайтед',
          teamAway: 'Ливерпуль',
          league: 'Премьер-Лига',
          date: DateTime.now().add(const Duration(days: 2)),
          imageHome: 'https://logos-world.net/wp-content/uploads/2020/06/Manchester-United-Logo.png',
          imageAway: 'https://logos-world.net/wp-content/uploads/2020/06/Liverpool-Logo.png',
          userPrediction: '',
          actualScore: '',
          status: MatchStatus.upcoming,
        ),
      ],
      isJoined: true,
      colorValue: Colors.blue.shade800.value,
      categoryId: 'football',
      creatorId: 'system',
    ),
    League(
      id: 2,
      title: 'НБА Прогнозы',
      description: 'Предсказания результатов матчей NBA',
      imageUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=400',
      participants: 8900,
      matches: [
        Match(
          id: 2,
          teamHome: 'Лейкерс',
          teamAway: 'Уорриорз',
          league: 'НБА',
          date: DateTime.now().add(const Duration(days: 3)),
          imageHome: 'https://logos-world.net/wp-content/uploads/2020/05/Los-Angeles-Lakers-Logo.png',
          imageAway: 'https://logos-world.net/wp-content/uploads/2020/05/Golden-State-Warriors-Logo.png',
          userPrediction: '',
          actualScore: '',
          status: MatchStatus.upcoming,
        ),
      ],
      isJoined: false,
      colorValue: Colors.purple.shade700.value,
      categoryId: 'basketball',
      creatorId: 'system',
    ),
  ];

  final List<LeagueCategory> _categories = [
    LeagueCategory(
      id: 'all',
      title: 'Все',
      icon: Icons.all_inclusive,
      color: Colors.blue,
    ),
    LeagueCategory(
      id: 'football',
      title: 'Футбол',
      description: 'Футбольные лиги и турниры',
      icon: Icons.sports_soccer,
      color: Colors.green,
    ),
    LeagueCategory(
      id: 'basketball',
      title: 'Баскетбол',
      description: 'NBA и другие баскетбольные лиги',
      icon: Icons.sports_basketball,
      color: Colors.orange,
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  int _currentTabIndex = 0;
  String _selectedCategoryId = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<League> get _filteredLeagues {
    List<League> filtered = _leagues;

    if (_selectedCategoryId != 'all') {
      filtered = filtered
          .where((league) => league.categoryId == _selectedCategoryId)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((league) {
        return league.title.toLowerCase().contains(_searchQuery) ||
            league.description.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    return filtered;
  }

  Widget _buildTabItem(LeagueCategory category, int index) {
    final isSelected = _currentTabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentTabIndex = index;
          _selectedCategoryId = category.id;
          _searchController.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isSelected ? category.color : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 18,
              color: isSelected ? category.color : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              category.title,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLeagueDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String selectedCategory = 'football';
    List<Match> newMatches = [];
    int matchCounter = 100;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Создать новую лигу'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Название лиги',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Описание',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: [
                        DropdownMenuItem(
                          value: 'football',
                          child: Row(
                            children: [
                              Icon(Icons.sports_soccer, color: Colors.green),
                              const SizedBox(width: 8),
                              const Text('Футбол'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'basketball',
                          child: Row(
                            children: [
                              Icon(Icons.sports_basketball, color: Colors.orange),
                              const SizedBox(width: 8),
                              const Text('Баскетбол'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Категория',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Раздел для добавления матчей
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Матчи лиги (${newMatches.length})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.blue),
                          onPressed: () => _showAddMatchDialog(
                            context,
                            setState,
                            newMatches,
                            matchCounter,
                          ),
                        ),
                      ],
                    ),

                    if (newMatches.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Добавьте матчи в лигу',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      ...newMatches.map((match) => _buildMatchPreview(match)).toList(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty &&
                        descriptionController.text.isNotEmpty &&
                        newMatches.isNotEmpty) {

                      final newLeague = League(
                        id: _leagues.length + 1,
                        title: titleController.text,
                        description: descriptionController.text,
                        imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
                        participants: 1,
                        matches: newMatches,
                        isJoined: true,
                        colorValue: _getRandomColor().value,
                        categoryId: selectedCategory,
                        creatorId: widget.userEmail,
                      );

                      setState(() {
                        _leagues.add(newLeague);
                      });

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Лига "${titleController.text}" создана!'),
                        ),
                      );
                    }
                  },
                  child: const Text('Создать лигу'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddMatchDialog(BuildContext context, StateSetter setState,
      List<Match> matches, int matchCounter) {

    final TextEditingController homeController = TextEditingController();
    final TextEditingController awayController = TextEditingController();
    final TextEditingController leagueController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Добавить матч'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: homeController,
                  decoration: const InputDecoration(
                    labelText: 'Хозяева',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: awayController,
                  decoration: const InputDecoration(
                    labelText: 'Гости',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: leagueController,
                  decoration: const InputDecoration(
                    labelText: 'Турнир',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                        child: Text(
                          '${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (pickedTime != null) {
                            setState(() {
                              selectedTime = pickedTime;
                            });
                          }
                        },
                        child: Text(
                          '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                if (homeController.text.isNotEmpty && awayController.text.isNotEmpty) {
                  final matchDateTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );

                  final newMatch = Match(
                    id: matchCounter++,
                    teamHome: homeController.text,
                    teamAway: awayController.text,
                    league: leagueController.text.isNotEmpty
                        ? leagueController.text
                        : 'Турнир',
                    date: matchDateTime,
                    imageHome: 'https://via.placeholder.com/60',
                    imageAway: 'https://via.placeholder.com/60',
                    userPrediction: '',
                    actualScore: '',
                    status: MatchStatus.upcoming,
                  );

                  setState(() {
                    matches.add(newMatch);
                  });

                  Navigator.pop(context);
                }
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMatchPreview(Match match) {
    return ListTile(
      leading: const Icon(Icons.sports),
      title: Text('${match.teamHome} - ${match.teamAway}'),
      subtitle: Text(_formatMatchDate(match.date)),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () {
          // Удаление матча из списка
        },
      ),
    );
  }

  String _formatMatchDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getRandomColor() {
    final colors = [
      Colors.blue.shade800,
      Colors.purple.shade700,
      Colors.red.shade700,
      Colors.green.shade700,
      Colors.orange.shade700,
      Colors.teal.shade700,
    ];
    return colors[_leagues.length % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLeagueDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 100.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              title: const Text(
                'Лига прогнозов',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.black),
                  onPressed: _showAddLeagueDialog,
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: ColoredBox(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.asMap().entries.map((entry) {
                        final index = entry.key;
                        final category = entry.value;
                        return _buildTabItem(category, index);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Поиск лиг...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 22),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 22),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                          : null,
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: _buildCategoryContent(),
      ),
    );
  }

  Widget _buildCategoryContent() {
    final categoryLeagues = _filteredLeagues;

    if (categoryLeagues.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 64, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'Лиги не найдены',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Нажмите + чтобы добавить первую лигу',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: categoryLeagues.length,
      itemBuilder: (context, index) {
        final league = categoryLeagues[index];
        return _buildLeagueCard(context, league);
      },
    );
  }

  Widget _buildLeagueCard(BuildContext context, League league) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LeagueDetailPage(
              league: league,
              onLeagueUpdated: (updatedLeague) {
                setState(() {
                  final index = _leagues.indexWhere((l) => l.id == updatedLeague.id);
                  if (index != -1) {
                    _leagues[index] = updatedLeague;
                  }
                });
              },
            ),
          ),
        );
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                league.cardColor,
                league.cardColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    '${league.participants} участников',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(league.imageUrl),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      league.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      league.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.sports,
                          color: Colors.white.withOpacity(0.8),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${league.matches.length} матчей',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LeagueCategory {
  final String id;
  final String title;
  final String? description;
  final IconData icon;
  final Color color;

  LeagueCategory({
    required this.id,
    required this.title,
    this.description,
    required this.icon,
    required this.color,
  });
}