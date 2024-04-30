import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/components/uicomponents.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/providers.dart';

class SubjectNotesPage extends StatefulWidget {
  const SubjectNotesPage({super.key, required this.subjectId});

  final String subjectId;

  @override
  State<SubjectNotesPage> createState() => _SubjectNotesPageState();
}

class _SubjectNotesPageState extends State<SubjectNotesPage> {
  late TextEditingController _searchText;
  final List<NoteModel> _filteredNotes = [];

  @override
  void initState() {
    _searchText = TextEditingController();
    super.initState();
  }

  Future onRefresh() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
      ),
      body: Consumer<QueryNotesProvider>(builder: (context, notes, child) {
        List<NoteModel> subjectNotes = notes.getUniversityNotes;
      
        if (subjectNotes.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text("No notes found for this subject"),
            ),
          );
        }
      
        notes.getNotesBySubject(widget.subjectId);
      
        if (kDebugMode) print(widget.subjectId);
      
        return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.primary,
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
                  SliverToBoxAdapter(
                    child: ColoredBox(
                      color: Colors.white,
                      child: Column(
                        children: renderNotes(),
                      ),
                    ),
                  )
                  
                ],
              ),
            ));
      }),
    );
  }

  List<Widget> renderNotes() {
    return List.generate(
      _filteredNotes.length,
      (index) {
        final dynamic result = _filteredNotes[index];

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
