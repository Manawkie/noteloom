import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/components/uicomponents.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/providers.dart';
import 'package:google_fonts/google_fonts.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  List<String>? _recents = [];
  List<NoteModel> recommendedNotes = <NoteModel>[];

  @override
  void initState() {
    final prioritySubjects = context.read<UserProvider>().readPrioritySubjects;

    if (prioritySubjects.isNotEmpty) {
      for (final subject in prioritySubjects) {
        final subjectNotes =
            context.read<QueryNotesProvider>().getNotesBySubject(subject);
        if (subjectNotes.isNotEmpty) {
          recommendedNotes.addAll(subjectNotes);
          recommendedNotes.sort(
              (a, b) => a.peopleLiked!.length.compareTo(b.peopleLiked!.length));
        }
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(45),
            ),
            color:  Color.fromARGB(255, 174, 198, 207)),
        padding: const EdgeInsets.all(20),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Text(
                "Recents",
                style: GoogleFonts.ubuntu(fontSize: 30),
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
                        style: GoogleFonts.ubuntu(),
                      )
                    ],
                  );
                }

                if (_recents!.isEmpty) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: Center(
                      child: Text(
                        "You currently have no recents...",
                        style: GoogleFonts.ubuntu(),
                      ),
                    ),
                  );
                }

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: ListView.builder(
                    reverse: true,
                      itemCount: _recents!.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) =>
                          _buildItem(context, index, queryNotes),),
                );
              }),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Suggested Notes",
                    style: GoogleFonts.ubuntu(fontSize: 30),
                  ),
                  Text(
                    "Here are suggested notes based on your saved subjects.",
                    style: GoogleFonts.ubuntu(),
                  )
                ],
              ),
            ),
            const SliverToBoxAdapter(
              child: RenderRecommended(),
            )
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
        return Container(
          margin: const EdgeInsets.all(8),
          child: _buildRecentNote(displayedNote, context));
      }
    } else if (type == "subjects") {
      final displayedSubject = notes.findSubject(id);
      if (displayedSubject != null) {
        return Container(
          margin: const EdgeInsets.all(8),
          child: _buildRecentSubject(displayedSubject, context));
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
        color: colors[subject.id.hashCode %
            colors.length], // Dynamic color based on subject ID
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject.subject, style: GoogleFonts.ubuntu(fontSize: 16)),
                Text(subject.subjectCode,
                    style: GoogleFonts.ubuntu(fontSize: 14))
              ],
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
        color: colors[note.id.hashCode %
            colors.length], 
        borderRadius: BorderRadius.circular(15),

      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(note.name, style: GoogleFonts.ubuntu()),
                Text(note.subjectName, style: GoogleFonts.ubuntu())
              ],
            ),
            Text(note.author, style: GoogleFonts.ubuntu())
          ]),
    ),
  );
}

List<Color> colors = const [
  Color.fromRGBO(255, 255, 204, 1), // Pale Yellow (#FFFFCC)
  Color.fromRGBO(135, 206, 250, 1), // Light Sky Blue (#87CEFA)
  Color.fromRGBO(204, 255, 204, 1), // Soft Mint Green (#CCFFCC)
 Color.fromRGBO(255, 250, 205, 1), // Lemon Chiffon (#FFFACD)
];

class RenderRecommended extends StatelessWidget {
  const RenderRecommended({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, QueryNotesProvider>(
      builder: (context, userdata, querynotes, child) {
        final recommendedNotes = [];
        final prioritySubjects = userdata.readPrioritySubjects.take(3).toList();

        for (var prioritySubject in prioritySubjects) {
          final getHighestLikes = querynotes.getNotesBySubject(prioritySubject);
          // sort gethighest likes by people liked length;

          getHighestLikes.sort((a, b) => (b.peopleLiked?.length ?? 0).compareTo(a.peopleLiked?.length ?? 0));
          if (getHighestLikes.isNotEmpty) {
            recommendedNotes.add(getHighestLikes.first);
          }
        }

        if (recommendedNotes.isEmpty) {
          return Container();
        }
        return Column(
          children: List.generate(recommendedNotes.length, (index) {
            final note = recommendedNotes[index];
            return noteButton(note, context, Colors.white);
          }),
        );
      },
    );
  }
}
