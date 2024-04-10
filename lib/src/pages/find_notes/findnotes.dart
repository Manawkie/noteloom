import 'package:flutter/material.dart';

class FindNotes extends StatefulWidget {
  const FindNotes({super.key});

  @override
  State<FindNotes> createState() => _FindNotesState();
}

class _FindNotesState extends State<FindNotes> {
  final SearchController _seachcontroller = SearchController();

  @override
  void dispose() {
    _seachcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(15),
            child: SearchBar(
              controller: _seachcontroller,
              hintText: "Search a subject or a note",
            )));
  }
}
