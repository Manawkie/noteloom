import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  SearchController _searchController = SearchController();

  List<NoteModel> _allNotes = [];
  List<SubjectModel> _allSubjects = [];
  List<Results> _filteredResults = [];

  @override
  void initState() {
    _searchText = TextEditingController();
    _searchController = SearchController();
    _searchText.addListener(() {
      setState(() {
        filterResults();
      });
    });

    _searchController.addListener(() {
      setState(() {
        filterResults();
      });
    });

    super.initState();
    GoRouter.of(context).refresh();
  }

  @override
  void dispose() {
    _searchText.dispose();
    super.dispose();
  }

  void filterResults() {
    // filtering name
    final filteredNames = _allNotes.where((note) {
      if (note.name
          .toLowerCase()
          .contains(_searchController.text.toLowerCase())) {
        return true;
      }

      if (note.subjectId
          .toLowerCase()
          .contains(_searchController.text.toLowerCase())) {
        return true;
      }

      return false;
    }).toList();

    final filteredSubjects = _allSubjects.where((subject) {
      if (subject.subject
          .toLowerCase()
          .contains(_searchController.text.toLowerCase())) {
        return true;
      }

      if (subject.subjectCode
          .toLowerCase()
          .contains(_searchController.text.toLowerCase())) {
        return true;
      }

      return false;
    }).toList();

    final filteredTags = _allNotes.where((note) {
      if (note.tags?.contains(_searchController.text.toLowerCase()) ?? false) {
        return true;
      }
      return false;
    }).toList();

    _filteredResults = {
      ...filteredNames,
      ...filteredSubjects,
      ...filteredTags,
    }.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<QueryNotesProvider, UserProvider>(
        builder: (context, notes, userdata, child) {
      if (notes.getUniversityNotes.isEmpty) {
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

      void onSearch() async {
        print("searching...");

        if (_searchController.text != "") {
          final newNotes = await Database.searchNotes(
              _searchController.text, userdata.userSavedNotesAndSubjects);
          notes.setUniversityNotes(newNotes);
        }
      }

      _allNotes = notes.getUniversityNotes;
      _allSubjects = notes.getUniversitySubjects;

      filterResults();

      return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.primary,
          body: LiquidPullToRefresh(
            color: Theme.of(context).colorScheme.primary,
            showChildOpacityTransition: false,
            onRefresh: () async => onRefresh(),
            child: CustomScrollView(
              physics: BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverAppBar(
                  title: mySearchBar(context, _searchController,
                      "Search Note or Subject", onSearch),

                  // title: TextField(
                  //   onSubmitted: (string) async {
                  //     if (kDebugMode) print(string);
                  //     if (string == "") {
                  //       notes.setUniversityNotes(await Database.getAllNotes());
                  //     } else {
                  //       notes.requeryNotes(string, priorityNoteIds);
                  //     }
                  //   },
                  //   style: const TextStyle(color: Colors.white),
                  //   controller: _searchText,
                  //   decoration: const InputDecoration(
                  //     hintStyle: TextStyle(color: Colors.white),
                  //     hintText: "Search Notes",
                  //     fillColor: Colors.white,
                  //     border: UnderlineInputBorder(
                  //       borderSide: BorderSide(color: Colors.white),
                  //     ),
                  //   ),
                  // ),
                ),
                SliverToBoxAdapter(
                  child: ColoredBox(
                    color: Colors.white,
                    child: Column(
                      children: renderNotes(),
                    ),
                  ),
                ),
                if (!_filteredResults
                    .any((result) => result.runtimeType == SubjectModel))
                  SliverToBoxAdapter(
                    child: noSubjectButton(),
                  ),
                const SliverFillRemaining(
                  fillOverscroll: true,
                  child: ColoredBox(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ));
    });
  }

  ColoredBox noSubjectButton() {
    return ColoredBox(
      color: Colors.white,
      child: GestureDetector(
        onTap: () => context.go("/addSubject"),
        child: Container(
          width: double.infinity,
          height: 150,
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: const Center(
            child: Column(
              children: [
                Text("Can't find your subject?"),
                Text("Add a subject here")
              ],
            ),
          ),
        ),
      ),
    );
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
