import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:school_app/src/pages/home/find_notes/findnotes.dart';
import 'package:school_app/src/pages/home/main/homepage2.dart';
import 'package:school_app/src/pages/home/mysubjects/mysubjects.dart';
import 'package:school_app/src/pages/home/main/homepage.dart';
import 'package:school_app/src/pages/home/savednotes/savednotes.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PageWithDrawer extends StatefulWidget {
  const PageWithDrawer({super.key});

  @override
  State<PageWithDrawer> createState() => _PageWithDrawerState();
}

class _PageWithDrawerState extends State<PageWithDrawer>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  var _bottomNavIndex = 0;

  PageStorageBucket bucket = PageStorageBucket();

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    super.initState();
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
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color.fromRGBO(95, 10, 215, 1),
                Color.fromRGBO(7, 156, 182, 1),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                context.go("/home/profile");
              },
              icon: Hero(
                tag: Auth.currentUser!.uid,
                child: CircleAvatar(
                  backgroundImage:
                      NetworkImage(Auth.currentUser!.photoURL ?? ""),
                ),
              ))
        ],
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        notchAndCornersAnimation: _animationController,
        itemCount: icons.length,
        gapLocation: GapLocation.end,
        tabBuilder: (index, isActive) {
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: Center(
              child: icons[index],
            ),
          );
        },
        activeIndex: _bottomNavIndex,
        onTap: (index) {
          if (index == 2) {
            context.push("/addnote");
          } else {
            setState(() {
              _bottomNavIndex = index;
            });
          }
        },
      ),
      body: Stack(children: [
        Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color.fromRGBO(95, 10, 215, 1),
                Color.fromRGBO(7, 156, 182, 1),
              ],
            ),
          ),
        ),
        IndexedStack(
          index: _bottomNavIndex,
          children: _pages,
        ),
      ]),
    );
  }

  List icons = [
    const Icon(Icons.home),
    const Icon(Icons.search),
    const Icon(Icons.add),
    const Icon(Icons.star),
    const Icon(Icons.book),
  ];

  Widget getPage() {
    return _pages[_bottomNavIndex];
  }

  final List<Widget> _pages = [
    const MainHomePage(),
    const SearchPage(),
    Container(),
    const SavedNotesPage(),
    const PrioritySubjects(),
  ];
}

Widget getSvgIcon(String path) {
  return SvgPicture.asset(
    path,
  );
}
