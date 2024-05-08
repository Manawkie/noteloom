import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/components/uicomponents.dart';
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
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            context.go('/home');
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

        return RenderSubjectPage(subject: subject);
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
      future: SharedPrefs.isSubjectPriority(widget.subject.id!),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return  Center(
            child: myLoadingIndicator()
          );
        }

        bool isPriority = snapshot.data ?? false;
        if (kDebugMode) {
          print("isPriority: $isPriority");
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Actions(
              isPriority: isPriority,
              subject: widget.subject,
            ),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      context.pushNamed("subjectNotes", pathParameters: {
                        "id": widget.subject.id!,
                      });
                    },
                    child: const Text("View Subject Notes")),
                TextButton(
                    onPressed: () {
                      context.pushNamed("discussions", pathParameters: {
                        "id": widget.subject.id!,
                      });
                    },
                    child: const Text("View Subject Dissussions"))
              ],
            )
          ],
        );
      },
    );
  }
}

class Actions extends StatefulWidget {
  const Actions({
    super.key,
    required this.isPriority,
    required this.subject,
  });
  final bool isPriority;
  final SubjectModel subject;

  @override
  State<Actions> createState() => _ActionsState();
}

class _ActionsState extends State<Actions> {
  bool isPriority = false;

  @override
  void initState() {
    isPriority = widget.isPriority;
    super.initState();
  }

  void togglePriority() {
    setState(() {
      isPriority = !isPriority;
    });
    final userData = context.read<UserProvider>();

    if (isPriority) {
      userData.addPrioritySubjectId(widget.subject.id!);
    } else {
      userData.removePrioritySubjectId(widget.subject.id!);
    }
  }

  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: togglePriority,
        icon: Icon(
          Icons.bookmark,
          color: isPriority ? Theme.of(context).colorScheme.primary : null,
        ));
  }
}
