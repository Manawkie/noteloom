import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/components/uicomponents.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/providers.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
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
    GoRouter.of(context).refresh();
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

    _filteredResults = [...filteredNotes, ...filteredSubjects];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QueryNotesProvider>(builder: (context, notes, child) {
      if (notes.universityNotes.isEmpty) {
        Database.getAllNotes().then((allNotes) {
          notes.setUniversityNotes(allNotes.cast<NoteModel>());
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
        notes.setUniversityNotes(getAllNotes);
      }

      _allNotes = context.read<QueryNotesProvider>().getUniversityNotes;
      _allSubjects = context.read<QueryNotesProvider>().getUniversitySubjects;

      filterResults();

      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
          body: LiquidPullToRefresh(
        color: Theme.of(context).colorScheme.primary,
        showChildOpacityTransition: false,
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
            SliverToBoxAdapter(
              child: ColoredBox(
                color: Colors.white,
                child: Column(
                  children: renderNotes(),
                ),
              ),
            ), const SliverFillRemaining(
              child: ColoredBox(color: Colors.white,),
            )
          ],
        ),
      ));
    });
  }

  List<Widget> renderNotes() {
    return List.generate(
      _filteredResults.length,
      (index) {
        final dynamic result = _filteredResults[index];

        if (result.runtimeType == NoteModel) {
          return noteButton(result as NoteModel, context);
        }

        if (result.runtimeType == SubjectModel) {
          return subjectButton(result as SubjectModel, context);
        }

        return Container();
      },
    );
  }
}
