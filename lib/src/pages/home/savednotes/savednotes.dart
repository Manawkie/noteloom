import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/components/uicomponents.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/providers.dart';
import 'package:google_fonts/google_fonts.dart';

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
List<Color> colors = const [
  Color.fromRGBO(255, 224, 204, 1), // Soft Peach (#FFE0CC)
  Color.fromRGBO(255, 228, 232, 1), // Light Blush Pink (#FFE4E8)
  Color.fromRGBO(204, 255, 204, 1), // Soft Mint Green (#CCFFCC)
  Color.fromRGBO(240, 240, 255, 1), // Very Light Lavender (#F0F0FF)
];

  @override
  Widget build(BuildContext caontext) {
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
          backgroundColor: Theme.of(context).primaryColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            centerTitle: true, // Center the title
            title: mySearchBar(context, _searchController, "Search your Saved Notes"),
            elevation: 4.0, // Adds shadow
            titleTextStyle: GoogleFonts.ubuntu( // Using Google Fonts for the title
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
          ),
          body: Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 174, 198, 207),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(45),
              ),
            ),
            margin: const EdgeInsets.only(top:20),
            padding: const EdgeInsets.all(20),
            child: ListView.builder(
                itemBuilder: (context, index) {
                  NoteModel? note = _filteredNotes[index];
                  if (note == null) {
                    return const Center(
                      child: Text("Note not found"),
                    );
                  }

                  return noteButton(note, context, colors[index % colors.length]);
                },
                itemCount: _filteredNotes.length),
          ),
        );
      },
    );
  }
}
