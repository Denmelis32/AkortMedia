import 'package:flutter/material.dart';
import 'package:my_app/pages/communities/tabs/events_tab.dart';
import 'package:my_app/pages/communities/tabs/info_tab.dart';
import 'package:my_app/pages/communities/tabs/members_tab.dart';
import 'package:my_app/pages/communities/tabs/rooms_tab.dart';
import 'package:my_app/pages/communities/widgets/community_header.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'models/community.dart';

class CommunityDetailPage extends StatefulWidget {
  final Community community;
  final int initialTab;

  const CommunityDetailPage({
    super.key,
    required this.community,
    this.initialTab = 0,
  });

  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _communityTabs = ['Комнаты', 'Участники', 'Информация', 'События'];
  final ScrollController _scrollController = ScrollController();

  late Community _currentCommunity;
  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    _currentCommunity = widget.community;
    _tabController = TabController(
      length: _communityTabs.length,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final newShowTitle = _scrollController.offset > 200;
    if (newShowTitle != _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = newShowTitle;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildTabContent() {
    switch (_tabController.index) {
      case 0: return RoomsTab(community: _currentCommunity);
      case 1: return MembersTab(community: _currentCommunity);
      case 2: return InfoTab(community: _currentCommunity);
      case 3: return EventsTab(community: _currentCommunity);
      default: return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _showAppBarTitle
              ? Text(
            _currentCommunity.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          )
              : const SizedBox.shrink(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: _communityTabs.map((tab) => Tab(text: tab)).toList(),
          isScrollable: true,
        ),
      ),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: CommunityHeader(community: _currentCommunity),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: List.generate(_communityTabs.length, (index) => _buildTabContent()),
        ),
      ),
    );
  }
}