// lib/pages/cards_pages/cards_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../cards_detail_page/channel_detail_page.dart';
import '../cards_detail_page/dialogs/channel_utils.dart';
import '../cards_detail_page/models/channel.dart';
import '../../providers/channel_state_provider.dart';
import '../cards_detail_page/dialogs/create_channel_dialog.dart';

// Импорты виджетов
import 'widgets/channel_card.dart';
import 'widgets/filters_panel.dart';
import 'widgets/search_app_bar.dart';
import 'models/channel_data.dart';
import 'models/ui_config.dart';
import 'utils/image_loader.dart';

class CardsPage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userAvatarUrl;
  final VoidCallback onLogout;

  const CardsPage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userAvatarUrl,
    required this.onLogout,
  });

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  // Контроллеры
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Состояние
  String _selectedCategoryId = 'all';
  String _searchQuery = '';
  String _selectedSort = 'newest';
  final Set<String> _activeFilters = {};
  bool _isLoading = false;
  bool _showSearchBar = false;
  bool _showFilters = false;
  bool _isMounted = false;

  // Данные
  late List<Channel> _channels;
  late final ChannelDataManager _dataManager;
  late final UIConfig _uiConfig;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _initializeData();
    _setupListeners();

    // Добавляем слушатель изменений провайдера
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ChannelStateProvider>(context, listen: false);
      provider.addListener(_onChannelStateChanged);
    });
  }

  void _initializeData() {
    _dataManager = ChannelDataManager();
    _uiConfig = UIConfig();
    _channels = _dataManager.createSampleChannels();
  }

  void _setupListeners() {
    _searchController.addListener(() {
      if (!_isMounted) return;
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  void _onChannelStateChanged() {
    if (_isMounted) {
      setState(() {
        // Принудительное обновление при изменении состояния каналов
      });
    }
  }

  @override
  void dispose() {
    _isMounted = false;
    final provider = Provider.of<ChannelStateProvider>(context, listen: false);
    provider.removeListener(_onChannelStateChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Основные методы
  List<Channel> _getFilteredChannels(ChannelStateProvider stateProvider) {
    if (stateProvider.isDisposed) {
      return _channels;
    }

    // Используем актуальное состояние из провайдера
    final filtered = _channels.map((channel) {
      final channelId = channel.id.toString();

      return channel.copyWith(
        isSubscribed: stateProvider.isSubscribed(channelId),
        subscribers: stateProvider.getSubscribers(channelId) ?? channel.subscribers,
        imageUrl: stateProvider.getAvatarForChannel(channelId) ?? channel.imageUrl,
      );
    }).where(_matchesFilters).toList();

    _sortChannels(filtered);
    return filtered;
  }

  bool _matchesFilters(Channel channel) {
    if (_selectedCategoryId != 'all' && channel.categoryId != _selectedCategoryId) {
      return false;
    }

    if (_activeFilters.contains('verified') && !channel.isVerified) return false;
    if (_activeFilters.contains('subscribed') && !channel.isSubscribed) return false;
    if (_activeFilters.contains('favorites') && !channel.isFavorite) return false;

    if (_searchQuery.isNotEmpty) {
      return channel.title.toLowerCase().contains(_searchQuery) ||
          channel.description.toLowerCase().contains(_searchQuery) ||
          (channel.tags ?? []).any((tag) => tag.toLowerCase().contains(_searchQuery));
    }

    return true;
  }

  void _sortChannels(List<Channel> channels) {
    switch (_selectedSort) {
      case 'newest':
        channels.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'popular':
        channels.sort((a, b) => b.views.compareTo(a.views));
        break;
      case 'subscribers':
        channels.sort((a, b) => b.subscribers.compareTo(a.subscribers));
        break;
    }
  }

  // Создание нового канала через диалог
  void _createNewChannel() {
    if (!_isMounted) return;

    showDialog(
      context: context,
      builder: (context) => CreateChannelDialog(
        userName: widget.userName,
        userAvatarUrl: widget.userAvatarUrl,
        categories: _dataManager.categories,
        onCreateChannel: _addNewChannel,
      ),
    );
  }

  // Добавление нового канала в список
  void _addNewChannel(String title, String description, String categoryId,
      String? avatarUrl, String? coverUrl) {
    if (!_isMounted) return;

    final newChannel = ChannelUtils.createNewChannel(
      id: _channels.length + 1,
      title: title,
      description: description,
      categoryId: categoryId,
      userName: widget.userName,
      userAvatarUrl: widget.userAvatarUrl,
      customAvatarUrl: avatarUrl,
      customCoverUrl: coverUrl,
    );

    setState(() {
      _channels.insert(0, newChannel);
    });

    // Сохраняем в провайдер
    final stateProvider = Provider.of<ChannelStateProvider>(context, listen: false);
    final channelId = newChannel.id.toString();
    if (avatarUrl != null) {
      stateProvider.setAvatarForChannel(channelId, avatarUrl);
    }
    if (coverUrl != null) {
      stateProvider.setCoverForChannel(channelId, coverUrl);
    }

    if (_isMounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Канал "$title" успешно создан!'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Открыть',
            onPressed: () {
              if (!_isMounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChannelDetailPage(channel: newChannel),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  // Вспомогательные методы
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = _uiConfig.getHorizontalPadding(context);
    final isMobile = _uiConfig.isMobile(context);

    return Consumer<ChannelStateProvider>(
      builder: (context, channelStateProvider, child) {
        // Проверяем состояние провайдера перед использованием
        if (channelStateProvider.isDisposed) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Загрузка каналов...',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          );
        }

        // Принудительно обновляем каналы при каждом изменении состояния
        final channels = _getFilteredChannels(channelStateProvider);

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            constraints: BoxConstraints(
              minWidth: _uiConfig.minContentWidth,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _uiConfig.backgroundColor,
                  _uiConfig.backgroundColor.withOpacity(0.9),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: isMobile
                  ? _buildMobileLayout(horizontalPadding, channelStateProvider, channels)
                  : _uiConfig.buildDesktopLayout(_buildDesktopContent(
                  horizontalPadding, channelStateProvider, channels)),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _createNewChannel,
            backgroundColor: _uiConfig.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add, size: 28),
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(double horizontalPadding,
      ChannelStateProvider stateProvider, List<Channel> channels) {
    return Column(
      children: [
        // КОМПАКТНЫЙ APP BAR
        SearchAppBar(
          searchController: _searchController,
          showSearchBar: _showSearchBar,
          onSearchBarToggle: (value) => setState(() => _showSearchBar = value),
          onFiltersToggle: () => setState(() => _showFilters = !_showFilters),
          onSortPressed: _showSortBottomSheet,
          uiConfig: _uiConfig,
          isMobile: true,
          horizontalPadding: horizontalPadding,
        ),
        // Контент
        Expanded(
          child: Container(
            width: double.infinity,
            child: _buildMobileContent(stateProvider, horizontalPadding, channels),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileContent(ChannelStateProvider stateProvider,
      double horizontalPadding, List<Channel> channels) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Фильтры
        SliverToBoxAdapter(
          child: FiltersPanel(
            showFilters: _showFilters,
            activeFilters: _activeFilters,
            selectedCategoryId: _selectedCategoryId,
            onFilterToggle: (filterId) {
              setState(() {
                if (_activeFilters.contains(filterId)) {
                  _activeFilters.remove(filterId);
                } else {
                  _activeFilters.add(filterId);
                }
              });
            },
            onCategorySelected: (categoryId) => setState(() => _selectedCategoryId = categoryId),
            dataManager: _dataManager,
            uiConfig: _uiConfig,
            isMobile: true,
            horizontalPadding: horizontalPadding,
          ),
        ),

        // Разделитель
        SliverToBoxAdapter(
          child: Container(
            height: 1,
            margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
            color: Colors.grey.shade100,
          ),
        ),

        // Карточки каналов
        _buildChannelsGrid(stateProvider, horizontalPadding, channels, true),
      ],
    );
  }

  Widget _buildDesktopContent(double horizontalPadding,
      ChannelStateProvider stateProvider, List<Channel> channels) {
    return Column(
      children: [
        // КОМПАКТНЫЙ APP BAR
        SearchAppBar(
          searchController: _searchController,
          showSearchBar: _showSearchBar,
          onSearchBarToggle: (value) => setState(() => _showSearchBar = value),
          onFiltersToggle: () => setState(() => _showFilters = !_showFilters),
          onSortPressed: _showSortBottomSheet,
          uiConfig: _uiConfig,
          isMobile: false,
          horizontalPadding: horizontalPadding,
        ),
        // Контент
        Expanded(
          child: Container(
            width: double.infinity,
            child: _buildDesktopContentBody(stateProvider, horizontalPadding, channels),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopContentBody(ChannelStateProvider stateProvider,
      double horizontalPadding, List<Channel> channels) {
    return _uiConfig.buildDesktopLayout(
      CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Фильтры и категории
          SliverToBoxAdapter(
            child: FiltersPanel(
              showFilters: _showFilters,
              activeFilters: _activeFilters,
              selectedCategoryId: _selectedCategoryId,
              onFilterToggle: (filterId) {
                setState(() {
                  if (_activeFilters.contains(filterId)) {
                    _activeFilters.remove(filterId);
                  } else {
                    _activeFilters.add(filterId);
                  }
                });
              },
              onCategorySelected: (categoryId) => setState(() => _selectedCategoryId = categoryId),
              dataManager: _dataManager,
              uiConfig: _uiConfig,
              isMobile: false,
              horizontalPadding: horizontalPadding,
            ),
          ),

          // Разделитель
          SliverToBoxAdapter(
            child: Container(
              height: 1,
              margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
              color: Colors.grey.shade100,
            ),
          ),

          // Карточки каналов
          _buildChannelsGrid(stateProvider, horizontalPadding, channels, false),
        ],
      ),
    );
  }

  Widget _buildChannelsGrid(ChannelStateProvider stateProvider,
      double horizontalPadding, List<Channel> channels, bool isMobile) {
    if (channels.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.play_circle_filled_rounded,
                      size: 48, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 16),
                Text(
                  'Каналы не найдены',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                      color: _uiConfig.textColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Попробуйте изменить параметры поиска\nили выбрать другую категорию',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ДЛЯ МОБИЛЬНЫХ - ИСПОЛЬЗУЕМ SliverList
    if (isMobile) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            if (index >= channels.length) return const SizedBox.shrink();

            final channel = channels[index];
            // Обновляем канал актуальным состоянием
            final updatedChannel = channel.copyWith(
              isSubscribed: stateProvider.isSubscribed(channel.id.toString()),
              subscribers: stateProvider.getSubscribers(channel.id.toString()) ?? channel.subscribers,
            );

            return ChannelCard(
              channel: updatedChannel,
              index: index,
              stateProvider: stateProvider,
              uiConfig: _uiConfig,
              dataManager: _dataManager,
              onTap: () {
                if (!_isMounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChannelDetailPage(channel: updatedChannel),
                  ),
                );
              },
              onSubscribe: () => _toggleSubscription(index, stateProvider),
              isMobile: true,
            );
          },
          childCount: channels.length,
        ),
      );
    }

    // ДЛЯ ПЛАНШЕТОВ И КОМПЬЮТЕРОВ - ИСПОЛЬЗУЕМ SliverGrid
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _uiConfig.getCrossAxisCount(context),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 360 / 460,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            if (index >= channels.length) return const SizedBox.shrink();

            final channel = channels[index];
            // Обновляем канал актуальным состоянием
            final updatedChannel = channel.copyWith(
              isSubscribed: stateProvider.isSubscribed(channel.id.toString()),
              subscribers: stateProvider.getSubscribers(channel.id.toString()) ?? channel.subscribers,
            );

            return Padding(
              padding: const EdgeInsets.all(2),
              child: ChannelCard(
                channel: updatedChannel,
                index: index,
                stateProvider: stateProvider,
                uiConfig: _uiConfig,
                dataManager: _dataManager,
                onTap: () {
                  if (!_isMounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChannelDetailPage(channel: updatedChannel),
                    ),
                  );
                },
                onSubscribe: () => _toggleSubscription(index, stateProvider),
                isMobile: false,
              ),
            );
          },
          childCount: channels.length,
        ),
      ),
    );
  }

  void _toggleSubscription(int index, ChannelStateProvider stateProvider) {
    if (!_isMounted || stateProvider.isDisposed) return;

    final filteredChannels = _getFilteredChannels(stateProvider);
    final channel = filteredChannels[index];
    final channelId = channel.id.toString();

    // Получаем актуальное количество подписчиков
    final currentSubscribers = stateProvider.getSubscribers(channelId) ?? channel.subscribers;

    // Переключаем подписку через ChannelStateProvider
    stateProvider.toggleSubscription(channelId, currentSubscribers);

    // Принудительно обновляем состояние
    if (_isMounted) {
      setState(() {
        // Обновляем локальный список каналов
        final originalIndex = _channels.indexWhere((c) => c.id == channel.id);
        if (originalIndex != -1) {
          _channels[originalIndex] = _channels[originalIndex].copyWith(
            isSubscribed: stateProvider.isSubscribed(channelId),
            subscribers: stateProvider.getSubscribers(channelId) ?? _channels[originalIndex].subscribers,
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            stateProvider.isSubscribed(channelId)
                ? '✅ Подписались на ${channel.title}'
                : '❌ Отписались от ${channel.title}',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSortBottomSheet() {
    if (!_isMounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: _uiConfig.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Сортировка',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                  color: _uiConfig.textColor),
            ),
            const SizedBox(height: 16),
            ..._dataManager.sortOptions.map((option) => ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _uiConfig.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(option.icon, size: 20, color: _uiConfig.primaryColor),
              ),
              title: Text(
                option.title,
                style: TextStyle(fontSize: 15, color: _uiConfig.textColor,
                    fontWeight: FontWeight.w500),
              ),
              trailing: _selectedSort == option.id
                  ? Icon(Icons.check, color: _uiConfig.primaryColor, size: 20)
                  : null,
              onTap: () {
                if (!_isMounted) return;
                setState(() => _selectedSort = option.id);
                Navigator.pop(context);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}