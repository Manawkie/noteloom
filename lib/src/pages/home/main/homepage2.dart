import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/components/uicomponents.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/providers.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  List<String>? _recents = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: Text(
                "Recents",
                style: TextStyle(fontSize: 30),
              ),
            ),
            SliverToBoxAdapter(
              child: Consumer2<UserProvider, QueryNotesProvider>(
                  builder: (context, userData, queryNotes, child) {
                _recents = userData.readRecents;

                final getAllNotes = queryNotes.getUniversityNotes;
                final getAllSubjects = queryNotes.getUniversitySubjects;
                if (getAllNotes.isEmpty || getAllSubjects.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                  );
                }

                if (_recents!.isEmpty) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: const Center(
                      child: Text("You currently have no recents..."),
                    ),
                  );
                }

                return Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: ListView.builder(
                      itemCount: _recents!.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) =>
                          _buildItem(context, index, queryNotes)),
                );
              }),
            ),
            const SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Suggested Notes",
                    style: TextStyle(fontSize: 30),
                  ),
                  Text("Here are suggested notes based on your saved subjects.")
                ],
              ),
            ),
            
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index, QueryNotesProvider notes) {
    final result = _recents![index];
    final type = result.split("/")[0];
    final id = result.split("/")[1];

    if (type == "notes") {
      final displayedNote = notes.findNote(id);
      if (displayedNote != null) {
        return _buildRecentNote(displayedNote, context);
      }
    } else if (type == "subjects") {
      final displayedSubject = notes.findSubject(id);
      if (displayedSubject != null) {
        return _buildRecentSubject(displayedSubject, context);
      }
    }
    return Container();
  }
}

Widget _buildRecentSubject(SubjectModel subject, BuildContext context) {
  return GestureDetector(
    onTap: () {
      context.push("/subject/${subject.id}");
    },
    child: Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(right: 10),
      width: MediaQuery.of(context).size.width * 0.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(subject.subject), Text(subject.subjectCode)],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  context.pushNamed("discussions", pathParameters: {
                    "id": subject.id!,
                  });
                },
                icon: const Icon(Icons.message),
              ),
              IconButton(
                  onPressed: () {
                    context.pushNamed(
                      "subjectNotes",
                      pathParameters: {"id": subject.id!},
                    );
                  },
                  icon: const Icon(Icons.book))
            ],
          )
        ],
      ),
    ),
  );
}

Widget _buildRecentNote(NoteModel note, BuildContext context) {
  return GestureDetector(
    onTap: () {
      context.push('/note/${note.id}');
    },
    child: Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(right: 10),
      width: MediaQuery.of(context).size.width * 0.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(note.name), Text(note.subjectName)],
            ),
            Text(note.author)
          ]),
    ),
  );
}
