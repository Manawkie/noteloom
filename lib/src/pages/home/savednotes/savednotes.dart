import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/components/uicomponents.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/providers.dart';

class SavedNotesPage extends StatefulWidget {
  const SavedNotesPage({super.key});

  @override
  State<SavedNotesPage> createState() => _SavedNotesPageState();
}

class _SavedNotesPageState extends State<SavedNotesPage> {
  late SearchController _searchController;
  List<NoteModel?> _allSavedNoteIds = [];
  final List<NoteModel?> _filteredNotes = [];

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
    final filteredNotes = _allSavedNoteIds.where((note) {
      if (note == null) return false;

      // filter by name, subject name, and tags
      if (note.name.toLowerCase().contains(lowerSearchText)) return true;
      if (note.subjectId.toLowerCase().contains(lowerSearchText)) return true;
      if (note.author.toLowerCase().contains(lowerSearchText)) return true;
      // filter by tags

      if (note.tags?.contains(lowerSearchText) ?? false) return true;

      return false;
    });
    _filteredNotes.clear();
    _filteredNotes.addAll(filteredNotes);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, QueryNotesProvider>(
        builder: (context, userdata, notes, child) {
      if (userdata.readSavedNoteIds.isEmpty) {
        return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Text(
              "You currently don't have any saved notes.\n To add, search a note and save it.",
            ),
          ),
        );
      }

      _allSavedNoteIds = userdata.readSavedNoteIds
          .map((savedNoteId) => notes.findNote(savedNoteId))
          .toList();

      filterResults();

      return Scaffold(
          appBar: AppBar(
            flexibleSpace: Container(
                decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color.fromRGBO(95, 10, 215, 1),
                  Color.fromRGBO(7, 156, 182, 1),
                ],
              ),
            )),
            title: mySearchBar(context, _searchController, "Search Notes"),
          ),
          body: ListView.builder(
              itemBuilder: (context, index) {
                NoteModel? note = _filteredNotes[index];

                if (note == null) {
                  return const Center(
                    child: Text("Note not found"),
                  );
                }

                return noteButton(note, context);
              },
              itemCount: _filteredNotes.length));
    });
  }
}
