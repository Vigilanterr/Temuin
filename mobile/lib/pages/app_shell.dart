import 'package:flutter/material.dart';

import '../controllers/posts_controller.dart';
import '../theme.dart';
import '../utils/responsive.dart';
import 'create_post.dart';
import 'home.dart';
import 'my_posts.dart';
import 'profile.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final PostsController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PostsController()..refresh();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _select(int index) {
    if (_index == index) return;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > Breakpoints.mobile;
        final pages = [
          HomePage(
            controller: _controller,
            onCreatePost: () => _select(2),
            onOpenProfile: () => _select(3),
          ),
          MyPostsPage(controller: _controller, onCreatePost: () => _select(2)),
          CreatePostPage(controller: _controller, onCreated: () => _select(0)),
          ProfilePage(
            controller: _controller,
            onOpenMyPosts: () => _select(1),
            onCreatePost: () => _select(2),
          ),
        ];

        return PopScope(
          canPop: _index == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && _index != 0) _select(0);
          },
          child: Scaffold(
            body: wide
                ? SafeArea(
                    child: Row(
                      children: [
                        _buildRail(context),
                        const VerticalDivider(width: 1),
                        Expanded(
                          child: IndexedStack(index: _index, children: pages),
                        ),
                      ],
                    ),
                  )
                : SafeArea(
                    bottom: false,
                    child: IndexedStack(index: _index, children: pages),
                  ),
            bottomNavigationBar: wide ? null : _buildNavigationBar(),
          ),
        );
      },
    );
  }

  Widget _buildRail(BuildContext context) {
    return NavigationRail(
      selectedIndex: _index,
      onDestinationSelected: _select,
      labelType: NavigationRailLabelType.all,
      minWidth: 84,
      leading: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 20),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.travel_explore_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: Text('Beranda'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.description_outlined),
          selectedIcon: Icon(Icons.description_rounded),
          label: Text('Laporan'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.add_circle_outline_rounded),
          selectedIcon: Icon(Icons.add_circle_rounded),
          label: Text('Buat'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: Text('Profil'),
        ),
      ],
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description_rounded),
            label: 'Laporan',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline_rounded),
            selectedIcon: Icon(Icons.add_circle_rounded),
            label: 'Buat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
