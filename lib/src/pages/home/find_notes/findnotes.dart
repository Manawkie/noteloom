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
    final lowerSearchText = _searchController.text.toLowerCase();

    final filteredNames = _allNotes.where((note) {
      // filtering name
      if (note.name.toLowerCase().contains(lowerSearchText)) return true;
      if (note.subjectId.toLowerCase().contains(lowerSearchText)) return true;
      // filter by author

      if (note.author.toLowerCase().contains(lowerSearchText)) return true;
      // filter by tags
      if (note.tags?.contains(lowerSearchText) ?? false) return true;
      return false;
    }).toList();

    final filteredSubjects = _allSubjects.where((subject) {
      if (subject.subject.toLowerCase().contains(lowerSearchText)) return true;

      return subject.subjectCode.toLowerCase().contains(lowerSearchText);
    }).toList();

    _filteredResults = {
      ...filteredNames,
      ...filteredSubjects,
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
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverAppBar(
                  title: mySearchBar(
                      context, _searchController, "Search Note or Subject"),
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
                  hasScrollBody: false,
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
