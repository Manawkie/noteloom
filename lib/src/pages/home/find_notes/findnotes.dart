import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/components/uicomponents.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/providers.dart';

class FindNotes extends StatefulWidget {
  const FindNotes({super.key});

  @override
  State<FindNotes> createState() => _FindNotesState();
}

class _FindNotesState extends State<FindNotes> {
  final SearchController _seachcontroller = SearchController();

  @override
  void dispose() {
    _seachcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QueryNotesProvider>(builder: (context, notes, child) {
      if (notes.universityNotes.isEmpty) {
        Database.getAllNotes().then(
          (value) => notes.setNotes(
            value.cast<NoteModel>(),
          ),
        );

        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [const Text("Loading Notes..."), myLoadingIndicator()],
            ),
          ),
        );
      }

      return Scaffold(
        body: FindNotesPage(
          notes: notes.getUniversityNotes,
        ),
      );
    });
  }
}

class FindNotesPage extends StatefulWidget {
  const FindNotesPage({super.key, required this.notes});

  final List<NoteModel> notes;

  @override
  State<FindNotesPage> createState() => _FindNotesPageState();
}

class _FindNotesPageState extends State<FindNotesPage> {
  TextEditingController _searchText = TextEditingController();

  List<Results> _filteredResults = [];

  @override
  void initState() {
    _searchText = TextEditingController();
    _filteredResults = widget.notes;
    super.initState();
    _searchText.addListener(() {
      filterResults();
    });
  }

  @override
  void dispose() {
    _searchText.dispose();
    super.dispose();
  }

  void filterResults() {
    setState(
      () {
        _filteredResults = widget.notes.where((note) {
          if (note.name
              .toLowerCase()
              .contains(_searchText.text.toLowerCase())) {
            return true;
          }
          if (note.subjectId
              .toLowerCase()
              .contains(_searchText.text.toLowerCase())) {
            return true;
          }
          return false;
        }).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LiquidPullToRefresh(
      springAnimationDurationInMilliseconds: 1000,
      onRefresh: () {
        final queryNotes =
            Provider.of<QueryNotesProvider>(context, listen: false);

        Database.getAllNotes().then(
          (value) {
            queryNotes.setNotes(value.cast<NoteModel>());
          },
        );
        return Future.value();
      },
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
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final result = _filteredResults[index];

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
          ),
          if (_filteredResults
              .any((result) => result.runtimeType != SubjectModel))
            SliverToBoxAdapter(
              child: GestureDetector(
                child: const SizedBox(
                  height: 150,
                  child: Text("Can't find your subject? Add it here!"),
                ),
              ),
            )
        ],
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
        child: Column(
          children: [Text(subjectModel.subject)],
        ),
      ),
    );
  }
}
