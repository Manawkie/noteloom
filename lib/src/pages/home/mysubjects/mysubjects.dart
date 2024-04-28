import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/components/uicomponents.dart';
import 'package:school_app/src/utils/providers.dart';

class PrioritySubjects extends StatefulWidget {
  const PrioritySubjects({super.key});

  @override
  State<PrioritySubjects> createState() => _PrioritySubjectsState();
}

class _PrioritySubjectsState extends State<PrioritySubjects> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, QueryNotesProvider>(
        builder: (context, userdata, notes, child) {
      final userPrioritySubjects = userdata.readPrioritySubjects;
      final allSubjects = notes.getUniversitySubjects;

      if (userPrioritySubjects.isEmpty) {
        return const Center(
          child: Text(
            "You currently don't have any priority subjects.",
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: const TextField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintStyle: TextStyle(color: Colors.white),
              hintText: "Search Subjects",
              fillColor: Colors.white,
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
        ),
        body: ListView.builder(
          itemCount: userPrioritySubjects.length,
          itemBuilder: (context, index) {
          final subject = allSubjects.cast<dynamic>().firstWhere(
              (subject) => subject.id == userPrioritySubjects[index],
              orElse: () => null);

          if (subject == null) {
            return const Center(
              child: Text("Subject not found"),
            );
          }

          return subjectButton(subject, context);
        }),
      );
    });
  }
}
