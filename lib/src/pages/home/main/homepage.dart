import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/components/uicomponents.dart';
import 'package:school_app/src/utils/providers.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollControl = ScrollController();
  List<String>? _recents = <String>[];

  bool overScrolled = false;

  @override
  void initState() {
    _scrollControl.addListener(overScroll);
    super.initState();
  }

  @override
  void dispose() {
    _scrollControl.dispose();
    super.dispose();
  }

  void overScroll() {
    setState(() {
      if (_scrollControl.hasClients && _scrollControl.offset > 200) {
        overScrolled = true;
      } else {
        overScrolled = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: overScrolled ? const Text("Hello") : null,
              backgroundColor: Theme.of(context).primaryColor,
              expandedHeight: 200,
              flexibleSpace: !overScrolled
                  ? const FlexibleSpaceBar(
                      title: Text(
                        "Welcome to Note Loom!",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    )
                  : Container(),
            ),
            SliverFillRemaining(
                child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(45),
                ),
                color: Colors.white,
              ),
              child: Consumer2<UserProvider, QueryNotesProvider>(
                  builder: (context, userdetails, allnotes, child) {
                
                _recents = userdetails.readRecents;
                final getAllNotes = allnotes.getUniversityNotes;
                final getAllSubjects = allnotes.getUniversitySubjects;
                if (getAllNotes.isEmpty || getAllSubjects.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Column(
                      children: [
                        myLoadingIndicator(),
                        Text(
                          getAllNotes.isEmpty
                              ? "Loading Recent Notes..."
                              : getAllSubjects.isEmpty
                                  ? "Loading Recent Subjects..."
                                  : "Please wait...",
                        )
                      ],
                    ),
                  );
                }

                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: const Text("Recent Notes and Subjects"),
                      ),
                      ..._buildList()
                    ]);
              }),
            ))
          ],
        ));
  }

  List<Widget> _buildList() {
    QueryNotesProvider notes = context.read<QueryNotesProvider>();
    return List.generate(_recents!.length, (index) {
      final result = _recents![index];

      final type = result.split("/")[0];
      final id = result.split("/")[1];

      if (type == "notes") {
        return noteButton(notes.findNote(id)!, context);
      } else if (type == "subjects") {
        return subjectButton(notes.findSubject(id)!, context);
      }
      return Container();
    });
  }
}
