import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/components/uicomponents.dart';
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
    return Consumer<QueryNotesProvider>(builder: (context, notes, child) {
      if (notes.getUniversityNotes.isEmpty) {
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

      _allNotes = notes.getUniversityNotes;
      _allSubjects = notes.getUniversitySubjects;

      filterResults();
      return Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                stretch: false,
                pinned: true,
                flexibleSpace: Padding(
                  padding: const EdgeInsets.all( 8.0),
                  child: mySearchBar(
                      context, _searchController, "Search Note or Subject"),
                ),
                backgroundColor: Theme.of(context).primaryColor,
                floating: true,
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(45))),
                          margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(20),
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

  List<Color> colors = const [
    Color.fromRGBO(255, 242, 218, 1),
    Color.fromRGBO(253, 233, 238, 1),
    Color.fromRGBO(232, 243, 243, 1),
    Color.fromRGBO(254, 254, 240, 1),
  ];

  List<Widget> renderNotes() {
    return List.generate(
      _filteredResults.length,
      (index) {
        final dynamic result = _filteredResults[index];

        final color = colors[index % colors.length];

        if (result.runtimeType == NoteModel) {
          return noteButton(result as NoteModel, context, color);
        }

        if (result.runtimeType == SubjectModel) {
          return subjectButton(result as SubjectModel, context, color);
        }

        return Container();
      },
    );
  }
}
