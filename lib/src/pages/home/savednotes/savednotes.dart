import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/providers.dart';
import 'package:school_app/src/utils/sharedprefs.dart';

class SavedNotesPage extends StatefulWidget {
  const SavedNotesPage({super.key});

  @override
  State<SavedNotesPage> createState() => _SavedNotesPageState();
}

class _SavedNotesPageState extends State<SavedNotesPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, QueryNotesProvider>(
        builder: (consumer, userdata, notes, child) {
        
      
      if (userdata.readSavedNoteIds.isEmpty) {
        return const Scaffold(
          body: Center(
            child: Text(
              "You currently don't have any saved notes.",
            ),
          ),
        );
      }

      return Scaffold(
          body: ListView.builder(
        itemBuilder: (context, index) {
          List<NoteModel> noteList = notes.getUniversityNotes;
          List<String> savedNoteIds = userdata.readSavedNoteIds;

          final note = noteList.cast<dynamic>().firstWhere(
              (note) => note.id == savedNoteIds[index],
              orElse: () => null);

          if (note == null) {
            return const Center(
              child: Text("Note not found"),
            );
          }

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
        itemCount: userdata.readSavedNoteIds.length,
      ));
    });
  }
}
