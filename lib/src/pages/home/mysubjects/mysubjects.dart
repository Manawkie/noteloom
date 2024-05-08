import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/components/uicomponents.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/providers.dart';

class PrioritySubjects extends StatefulWidget {
  const PrioritySubjects({super.key});

  @override
  State<PrioritySubjects> createState() => _PrioritySubjectsState();
}

class _PrioritySubjectsState extends State<PrioritySubjects> {
  late SearchController _searchController;
  List<SubjectModel?> _allPrioritySubjects = [];
  List<SubjectModel?> _filteredSubjects = [];

  @override
  void initState() {
    _searchController = SearchController();
    _searchController.addListener(() {
      setState(() {
        filterResults();
      });
    });
    super.initState();
  }

  void filterResults() {
    final lowerSearchText = _searchController.text.toLowerCase();

    final filteredSubjects = _allPrioritySubjects.where((subject) {
      if (subject == null) return false;

      // filter by name, subject name, and tags
      if (subject.subject.toLowerCase().contains(lowerSearchText) ||
          subject.subjectCode.toLowerCase().contains(lowerSearchText)) {
        return true;
      }

      return false;
    });

    _filteredSubjects = filteredSubjects.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, QueryNotesProvider>(
      builder: (context, userdata, notes, child) {
        final userPrioritySubjects = userdata.readPrioritySubjects;

        if (userPrioritySubjects.isEmpty) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  "You currently don't have any priority subjects.\nTo add, search a subject and add as priority.",
                ),
              ),
            ),
          );
        }

        _allPrioritySubjects = userPrioritySubjects
            .map((subjectId) => notes.findSubject(subjectId))
            .toList();

        filterResults();

        return Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: mySearchBar(
                  context, _searchController, "Search your Priority Subjects")),
          body: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(45),
              ),
            ),
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.all(20),
            child: ListView.builder(
              itemCount: _filteredSubjects.length,
              itemBuilder: (context, index) {
                final subject = _filteredSubjects[index];
                if (subject == null) {
                  return const Center(
                    child: Text("Subject not found"),
                  );
                }

                return subjectButton(subject, context, Colors.white);
              },
            ),
          ),
        );
      },
    );
  }
}
