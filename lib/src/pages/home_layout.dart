import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:school_app/src/pages/addnote/addnote.dart';
import 'package:school_app/src/pages/find_notes/findnotes.dart';
import 'package:school_app/src/pages/mynotes/mynotes.dart';
import 'package:school_app/src/pages/mysubjects/mysubjects.dart';
import 'package:school_app/src/pages/settings/settings.dart';
import 'package:school_app/src/pages/home/homepage.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
        leading: IconButton(
          icon: Icon(Icons.add, color: Theme.of(context).iconTheme.color,),
          onPressed: () => context.go("/addnote"),
        ),
        actions: [
          IconButton(
              onPressed: () {
                context.go("/settings");
              },
              icon: CircleAvatar(
                backgroundImage: NetworkImage(Auth.currentUser!.photoURL ?? ""),
              ))
        ],
      ),
      body: PersistentTabView(
        context,
        controller: _tabController,
        screens: const [
          HomePage(),
          FindNotes(),
          PrioritySubjects(),
          MyNotesPage(),
        ],
        backgroundColor: Theme.of(context).navigationBarTheme.backgroundColor!,
        decoration: NavBarDecoration(
            borderRadius: BorderRadius.circular(10.0),
            colorBehindNavBar: Colors.white.withAlpha(0)),
        margin: const EdgeInsets.all(8),
        popActionScreens: PopActionScreensType.all,
        confineInSafeArea: true,
        handleAndroidBackButtonPress: true,
        items: _items,
        navBarStyle: NavBarStyle.style12,
        itemAnimationProperties: const ItemAnimationProperties(
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: const ScreenTransitionAnimation(
            animateTabTransition: true,
            curve: Curves.easeOut,
            duration: Durations.medium4),
        hideNavigationBarWhenKeyboardShows: true,
      ),
    );
  }

  final List<PersistentBottomNavBarItem> _items = [
    PersistentBottomNavBarItem(
        icon: const Icon(
          Icons.home,
        ),
        title: "Home"),
    PersistentBottomNavBarItem(
        icon: const Icon(
          Icons.search,
        ),
        title: "Search"),
    PersistentBottomNavBarItem(
        icon: SvgPicture.asset(
          'assets/images/app/icons/subjects.svg',
          height: 20,
          colorFilter: ColorFilter.mode(Colors.blue.shade400, BlendMode.srcIn),
        ),
        title: "Subjects"),
    PersistentBottomNavBarItem(
        icon: SvgPicture.asset(
          'assets/images/app/icons/notes.svg',
          height: 20,
          colorFilter: ColorFilter.mode(Colors.blue.shade400, BlendMode.srcIn),
        ),
        title: "Notes"),
  ];
}
