import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/components/uicomponents.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/providers.dart';

class SelectSubjectPage extends StatefulWidget {
  const SelectSubjectPage({super.key});

  @override
  State<SelectSubjectPage> createState() => _SelectSubjectPageState();
}

class _SelectSubjectPageState extends State<SelectSubjectPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<QueryNotesProvider, NotesProvider>(
        builder: (context, notes, note, child) {
      if (notes.universitySubjects.isEmpty) {
        Database.getAllSubjects().then(
          (value) => notes.setSubjects(
            value.cast<SubjectModel>(),
          ),
        );

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
                final subjectInfo = notes.universitySubjects[index];

                return ListTile(
                  title: Text(subjectInfo.subject),
                  onTap: () {
                    final selectedSubject =
                        notes.getUniversitySubjects[index].subject;

                    note.setSubject(selectedSubject);

                    context.go("/addnote");
                  },
                  subtitle: Text(subjectInfo.subjectCode),
                );
              },
              childCount: notes.universitySubjects.length,
            )),
          ],
        ),
      );
    });
  }
}
