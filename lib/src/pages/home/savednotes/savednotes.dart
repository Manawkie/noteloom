import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/components/uicomponents.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/providers.dart';

class SavedNotesPage extends StatefulWidget {
  const SavedNotesPage({super.key});

  @override
  State<SavedNotesPage> createState() => _SavedNotesPageState();
}

class _SavedNotesPageState extends State<SavedNotesPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, QueryNotesProvider>(
        builder: (context, userdata, notes, child) {
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
        appBar: AppBar
        (
          title: const TextField( style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintStyle: TextStyle(color: Colors.white),
              hintText: "Search Notes",
              fillColor: Colors.white,
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            )
        )
          ,
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

          return noteButton(note, context);
        },
        itemCount: userdata.readSavedNoteIds.length,
      ));
    });
  }
}
