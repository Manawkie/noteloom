import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/components/uicomponents.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/providers.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  TextEditingController _searchText = TextEditingController();

  List<NoteModel> _allNotes = [];
  List<SubjectModel> _allSubjects = [];
  List<Results> _filteredResults = [];

  @override
  void initState() {
    _searchText = TextEditingController();
    super.initState();
    _searchText.addListener(() {
      setState(() {
        filterResults();
      });
    });
  }

  @override
  void dispose() {
    _searchText.dispose();
    super.dispose();
  }

  void filterResults() {
    final filteredNotes = _allNotes.where((note) {
      if (note.name.toLowerCase().contains(_searchText.text.toLowerCase())) {
        return true;
      }

      if (note.subjectId
          .toLowerCase()
          .contains(_searchText.text.toLowerCase())) {
        return true;
      }

      return false;
    }).toList();

    final filteredSubjects = _allSubjects.where((subject) {
      if (subject.subject
          .toLowerCase()
          .contains(_searchText.text.toLowerCase())) {
        return true;
      }

      if (subject.subjectCode
          .toLowerCase()
          .contains(_searchText.text.toLowerCase())) {
        return true;
      }

      return false;
    }).toList();

    _filteredResults = [...filteredSubjects, ...filteredNotes];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QueryNotesProvider>(builder: (context, notes, child) {
      if (notes.universityNotes.isEmpty) {
        Database.getAllNotes().then((allNotes) {
          notes.setNotes(allNotes.cast<NoteModel>());
        });

        if (kDebugMode) {
          print("Getting notes");
        }

        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Loading Notes..."),
                myLoadingIndicator(),
              ],
            ),
          ),
        );
      }

      void onRefresh() async {
        final getAllNotes = await Database.getAllNotes();
        notes.setNotes(getAllNotes);
      }

      _allNotes = context.read<QueryNotesProvider>().getUniversityNotes;
      _allSubjects = context.read<QueryNotesProvider>().getUniversitySubjects;

      filterResults();

      return Scaffold(
          body: LiquidPullToRefresh(
              onRefresh: () async => onRefresh(),
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    title: TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: _searchText,
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(color: Colors.white),
                        hintText: "Search Notes",
                        fillColor: Colors.white,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  renderNotes(),
                  if (!_filteredResults.any(
                      (Results result) => result.runtimeType == SubjectModel))
                    const SliverToBoxAdapter(
                      child: SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: Center(
                          child: Text("Can't find your subject?"),
                        ),
                      ),
                    )
                ],
              )));
    });
  }

  SliverList renderNotes() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final dynamic result = _filteredResults[index];

          if (result.runtimeType == NoteModel) {
            return _buildNoteItem(result as NoteModel);
          }

          if (result.runtimeType == SubjectModel) {
            return _buildSubjectItem(result as SubjectModel);
          }

          return Container();
        },
        childCount: _filteredResults.length,
      ),
    );
  }

  Widget _buildNoteItem(NoteModel note) {
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
  }

  Widget _buildSubjectItem(SubjectModel subjectModel) {
    return GestureDetector(
      onTap: () {
        GoRouter.of(context).push('/subject/${subjectModel.id}');
      },
      child: Container(
        height: 150,
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Column(
            children: [
              Text(subjectModel.subject),
              Text(subjectModel.subjectCode)
            ],
          ),
        ),
      ),
    );
  }
}
