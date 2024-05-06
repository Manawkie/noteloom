import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/components/uicomponents.dart';
import 'package:school_app/src/utils/providers.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String>? _recents = <String>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.transparent,
          floating: true,
          elevation: 0,
          expandedHeight: 150,
          forceElevated: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
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
            centerTitle: false,
            expandedTitleScale: 1,
            titlePadding: const EdgeInsets.all(12),
            title: Text(
              "Welcome to Note Loom!",
              style: GoogleFonts.ubuntu(fontSize: 30, color: Colors.white),
              textAlign: TextAlign.start,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(12),
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
                    const Text("Recent Notes and Subjects:"),
                    ..._buildList(),
                    _recents!.isEmpty
                        ? const SizedBox(
                            height: 200,
                            child: Center(
                              child: Text("No recent notes or subjects"),
                            ),
                          )
                        : Container()
                  ],
                );
              },
            ),
          ),
        ),
      ],
    ));
  }

  List<Widget> _buildList() {
    QueryNotesProvider notes = context.read<QueryNotesProvider>();
    if (_recents == null) return <Widget>[];
    return List.generate(_recents!.length, (index) {
      final result = _recents![index];

      final type = result.split("/")[0];
      final id = result.split("/")[1];

      if (type == "notes") {
        final displayedNote = notes.findNote(id);
        if (displayedNote != null) return noteButton(displayedNote, context);
      } else if (type == "subjects") {
        final displayedSubject = notes.findSubject(id);
        if (displayedSubject != null) {
          return subjectButton(displayedSubject, context);
        }
      }
      return Container();
    });
  }
}
