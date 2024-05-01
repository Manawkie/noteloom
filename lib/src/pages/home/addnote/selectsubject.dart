import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/components/uicomponents.dart';
import 'package:school_app/src/utils/providers.dart';

class SelectSubjectPage extends StatefulWidget {
  const SelectSubjectPage({super.key});

  @override
  State<SelectSubjectPage> createState() => _SelectSubjectPageState();
}

class _SelectSubjectPageState extends State<SelectSubjectPage> {
  void selectedNote(QueryNotesProvider queryNotes, NoteProvider note, int index) {
    
    final selectedSubject = queryNotes.getUniversitySubjects[index];
    final currentNote = context.read<CurrentNoteProvider>();
    
    if (currentNote.readEditing == true) {
      currentNote.setNewSubject(selectedSubject.id!, selectedSubject.subject);
      context.pop();
      return;
    } else {
      note.setSubject(selectedSubject.id!, selectedSubject.subject);
      context.read<CurrentNoteProvider>().setSubject(selectedSubject.id!, selectedSubject.subject);
      context.go("/addnote");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<QueryNotesProvider, NoteProvider>(
        builder: (context, queryNotes, note, child) {
      if (queryNotes.getUniversitySubjects.isEmpty) {
        // Database.getAllSubjects().then(
        //   (value) => queryNotes.setUniversitySubjects(
        //     value.cast<SubjectModel>(),
        //   ),
        // );

        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Loading Subjects..."),
                myLoadingIndicator(),
              ],
            ),
          ),
        );
      }

      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: IconButton(
                  onPressed: () {
                    context.go("/addnote");
                  },
                  icon: const Icon(Icons.arrow_back_ios)),
              title: const Text("Select a Subject"),
              floating: true,
              snap: true,
            ),
            SliverList(
                delegate: SliverChildBuilderDelegate(
              (context, index) {
                final subjectInfo = queryNotes.getUniversitySubjects[index];

                return ListTile(
                  title: Text(subjectInfo.subject),
                  onTap: () => selectedNote(queryNotes, note, index),
                  subtitle: Text(subjectInfo.subjectCode),
                );
              },
              childCount: queryNotes.getUniversitySubjects.length,
            )),
          ],
        ),
      );
    });
  }
}
