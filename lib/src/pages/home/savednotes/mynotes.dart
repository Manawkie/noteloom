import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/components/uicomponents.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/providers.dart';
import 'package:school_app/src/utils/sharedprefs.dart';

class MyNotesPage extends StatefulWidget {
  const MyNotesPage({super.key});

  @override
  State<MyNotesPage> createState() => _MyNotesPageState();
}

class _MyNotesPageState extends State<MyNotesPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: SharedPrefs.getSavedNotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: myLoadingIndicator(),
              ),
            );
          }

          if (snapshot.data!.isEmpty) {
            return const Scaffold(
              body: Center(
                child: Text(
                  "You currently don't have any saved notes.",
                ),
              ),
            );
          }

          return RenderMyNotes(noteIds: snapshot.data!);
        });
  }
}

class RenderMyNotes extends StatefulWidget {
  const RenderMyNotes({super.key, required this.noteIds});
  final List<String> noteIds;

  @override
  State<RenderMyNotes> createState() => _RenderMyNotesState();
}

class _RenderMyNotesState extends State<RenderMyNotes> {
  final List<NoteModel> _filteredNotes = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QueryNotesProvider>(builder: (context, querynotes, child) {
    
      if (widget.noteIds.isNotEmpty) {
        for (var noteId in widget.noteIds) {
          final NoteModel savedNote = querynotes.getUniversityNotes
              .where((note) => note.id == noteId)
              .first;
          _filteredNotes.add(savedNote);
        }
      }
      return CustomScrollView(
        slivers: [
          SliverList.builder(
            itemBuilder: (context, index) {
              final note = _filteredNotes[index];

              return GestureDetector(
                onTap: () {
                  GoRouter.of(context).push('/note/${note.id}');
                },
                child: Container(
                  height: 150,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: [Text(note.name), Text(note.subjectId)],
                  ),
                ),
              );
            },
            itemCount: _filteredNotes.length,
          )
        ],
      );
    });
  }
}
