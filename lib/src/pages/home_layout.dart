import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:school_app/src/pages/find_notes/findnotes.dart';
import 'package:school_app/src/pages/mynotes/mynotes.dart';
import 'package:school_app/src/pages/mysubjects/mysubjects.dart';
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
  late AnimationController _tabController;
  late AnimationController _animationController;
  var _bottomNavIndex = 0;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    super.initState();
    _tabController = AnimationController(vsync: this);
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
          icon: const Icon(Icons.add),
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
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: 4,
        gapLocation: GapLocation.none,
        tabBuilder: (index, isActive) {
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: Center(
              child: icons[index],
            ),
          );
        },
        activeIndex: _bottomNavIndex,
        onTap: (index) => setState(() {
          _bottomNavIndex = index;
        }),
      ),
      body: _pages[_bottomNavIndex],
    );
  }

  List icons = [
    const Icon(Icons.home),
    const Icon(Icons.search),
    getSvgIcon("assets/images/app/icons/subjects.svg"),
    getSvgIcon("assets/images/app/icons/notes.svg")
  ];

  final List<Widget> _pages = [
    const HomePage(), const FindNotes(),
    const MyNotesPage(),
    const PrioritySubjects(),
   
  ];
}

Widget getSvgIcon(String path) {
  return SvgPicture.asset(
    path,
  );
}
