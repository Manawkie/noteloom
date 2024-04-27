import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/providers.dart';
import 'package:school_app/src/utils/sharedprefs.dart';

class SubjectPage extends StatefulWidget {
  const SubjectPage({super.key, required this.subjectId});
  final String subjectId;

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userData = context.read<UserProvider>();

      Database.addRecents("subjects/${widget.subjectId}");
      userData.addRecents("subjects/${widget.subjectId}");
    });
  }

  void onExit() {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: Consumer<QueryNotesProvider>(builder: (context, notes, child) {
        SubjectModel? subject = notes.findSubject(widget.subjectId);

        if (subject == null) {
          return const Center(
            child: Text("Subject not found."),
          );
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () {
                        context.goNamed("subjectNotes", pathParameters: {
                          "id": widget.subjectId,
                        });
                      },
                      child: const Text("View Subject Notes")),
                  TextButton(
                      onPressed: () {
                        context.goNamed("discussions", pathParameters: {
                          "id": widget.subjectId,
                        });
                      },
                      child: const Text("View Subject Dissussions"))
                ],
              )
            ],
          ),
        );
      }),
    );
  }
}

class RenderSubjectPage extends StatefulWidget {
  const RenderSubjectPage({super.key, required this.subject});
  final SubjectModel subject;
  @override
  State<RenderSubjectPage> createState() => _RenderSubjectPageState();
}

class _RenderSubjectPageState extends State<RenderSubjectPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([SharedPrefs.isSubjectPriority(widget.subject.id)]),
      builder: (context, snapshot) {
        return Container();
      },
    );
  }
}
