
import 'package:flutter/material.dart';
import 'package:school_app/src/pages/addnote/addnote.dart';
import 'package:school_app/src/pages/addnote/previewnote.dart';

class AddNoteLayout extends StatefulWidget {
  const AddNoteLayout({super.key});

  @override
  State<AddNoteLayout> createState() => _AddNoteLayoutState();
}

class _AddNoteLayoutState extends State<AddNoteLayout>
    with TickerProviderStateMixin {
  // tabs
  late PageController _pageController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    _tabController.index = index;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // note information
  @override
  Widget build(BuildContext context) {
    return PageView(
      
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _tabController.index = index;
        });
      },
      children: [
        AddNote(
          onpageChanged: _onTabTapped,
        ),
        PreviewNote(
          onPageChanged: _onTabTapped,
        )
      ],
    );
  }
}
