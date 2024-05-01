
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/providers.dart';

class SelectNotePage extends StatefulWidget {
  const SelectNotePage({super.key, required this.subjectId});
  final String subjectId;

  @override
  State<SelectNotePage> createState() => _SelectNotePageState();
}

class _SelectNotePageState extends State<SelectNotePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.pop()),
        title: const Text("Select Note"),
      ),
      body: Consumer2<QueryNotesProvider, MessageProvider>(
        builder: (context, queryNotes, messageData, child) {
          final subjectNotes = queryNotes.getNotesBySubject(widget.subjectId);
          final selectedNote = messageData.noteId;

          return ListView.builder(
              itemCount: subjectNotes.length,
              itemBuilder: (context, index) {
                final NoteModel note = subjectNotes[index];

                return ListTile(
                  leading:
                      note.id == selectedNote ? const Icon(Icons.check) : null,
                  title: Text(note.name),
                  subtitle: Text(note.author),
                  trailing: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      context.push("/note/${note.id}");
                    },
                  ),
                  onTap: () {
                    messageData.setNoteId(note.id);
                    context.pop();
                  },
                );
              });
        },
      ),
    );
  }
}
