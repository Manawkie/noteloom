import 'package:flutter/material.dart';

import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:school_app/src/pages/addnote/addnote.dart';
import 'package:school_app/src/pages/find_notes/findnotes.dart';
import 'package:school_app/src/pages/settings/settings.dart';
import 'package:school_app/src/pages/home/homepage.dart';

class PageWithDrawer extends StatefulWidget {
  const PageWithDrawer({super.key});

  @override
  State<PageWithDrawer> createState() => _PageWithDrawerState();
}

class _PageWithDrawerState extends State<PageWithDrawer>
    with TickerProviderStateMixin {
  late PersistentTabController _tabController;
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    super.initState();
    _tabController = PersistentTabController(initialIndex: 0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hello world"),
      ),
      body: PersistentTabView(
        context,
        controller: _tabController,
        screens: const [
          HomePage(),
          FindNotes(),
          SettingsPage(),
          AddNote(),
        ],
        confineInSafeArea: true,
        handleAndroidBackButtonPress: true,
        items: _items,
        navBarStyle: NavBarStyle.style12,
        screenTransitionAnimation: const ScreenTransitionAnimation(
            animateTabTransition: true,
            curve: Curves.easeOut,
            duration: Durations.medium4),
            hideNavigationBarWhenKeyboardShows: true,
      ),
    );
  }

  final List<PersistentBottomNavBarItem> _items = [
    PersistentBottomNavBarItem(icon: const Icon(Icons.home), title: "Home"),
    PersistentBottomNavBarItem(icon: const Icon(Icons.search), title: "Search"),
    PersistentBottomNavBarItem(icon: const Icon(Icons.book), title: "Subjects"),
    PersistentBottomNavBarItem(
        icon: const Icon(Icons.plagiarism_rounded), title: "Notes"),
  ];
}
