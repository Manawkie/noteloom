import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/components/uicomponents.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/providers.dart';
import 'package:school_app/src/utils/util_functions.dart';

class EditNotePage extends StatefulWidget {
  const EditNotePage({super.key, required this.noteId});

  final String noteId;
  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameControl;
  late TextEditingController _summaryControl;
  late SearchController _searchController;
  List<String> _selectedTags = [];

  late CurrentNoteProvider currentNote;
  late QueryNotesProvider queryNotes;

  String _subjectName = "";
  String _subjectId = "";

  List<SubjectModel> subjects = [];
  List<SubjectModel> suggestedSubjects = [];

  @override
  void initState() {
    currentNote = Provider.of<CurrentNoteProvider>(context, listen: false);
    queryNotes = context.read<QueryNotesProvider>();

    _nameControl = TextEditingController(text: currentNote.name ?? "");
    _summaryControl = TextEditingController(text: currentNote.summary ?? "");

    _searchController = SearchController();
    _searchController.text = currentNote.subjectName ?? "";
    _searchController.addListener(filterSubjects);

    _selectedTags = currentNote.tags ?? [];
    _subjectName = currentNote.readSubjectName ?? "";
    _subjectId = currentNote.readSubjectId ?? "";

    subjects = queryNotes.getUniversitySubjects;
    super.initState();

    Future.microtask(() {
      currentNote.setEditing(true);
      currentNote.setNewSubject(_subjectId, _subjectName);
    });
  }

  void resetFields() {
    _nameControl.text = currentNote.readName ?? "";
    _summaryControl.text = currentNote.summary ?? "";

    setState(() {
      _subjectName = currentNote.subjectName!;
      _subjectId = currentNote.subjectId!;
      _selectedTags = currentNote.readTags ?? [];
    });
  }

  void setNote() {
    currentNote.setNote(
      _nameControl.text,
      _subjectName,
      _subjectId,
      notesummary: _summaryControl.text,
      notetags: _selectedTags,
    );

    // reset notemodel

    final universityNotes = queryNotes.getUniversityNotes;

    NoteModel editedNote =
        universityNotes.where((note) => note.id == widget.noteId).first;

    editedNote.editFields(_nameControl.text, _subjectId, _subjectName,
        _summaryControl.text, _selectedTags);

    queryNotes.editNote(editedNote);
    final username = context.read<UserProvider>().readUserData?.username;
    Database.editNote(editedNote, username ?? editedNote.author);
  }

  void filterSubjects() {
    final search = _searchController.text;
    if (search.isEmpty) {
      suggestedSubjects = subjects;
      return;
    }
    final filteredSubjects = subjects
        .where((subject) =>
            subject.subject.toLowerCase().contains(search.toLowerCase()))
        .toList();
    suggestedSubjects = filteredSubjects;
  }

  void deleteNote() {
    final universityNotes =
        Provider.of<QueryNotesProvider>(context, listen: false)
            .getUniversityNotes;

    NoteModel editedNote =
        universityNotes.where((note) => note.id == widget.noteId).first;

    context.read<QueryNotesProvider>().deleteNote(editedNote);
    Database.deleteNote(editedNote);

    // remove from recents
    // remove from saved notes
    context.pop();
  }

  void showTags() async {
    final List<String>? results = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return MultiSelect(
            selectedTags: _selectedTags,
            tags: Utils.tags,
          );
        });
    if (results != null) {
      setState(
        () {
          _selectedTags = results;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentNoteProvider>(builder: (context, note, child) {
      _subjectName = note.readNewSubjectName ?? note.subjectName!;
      _subjectId = note.readNewSubjectId ?? note.subjectId!;

      filterSubjects();
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              note.setEditing(false);
              context.pop();
            },
          ),
          actions: [
            IconButton(
              onPressed: () => setNote(),
              icon: const Icon(Icons.save_alt),
              tooltip: "Save Changes",
            ),
            IconButton(
              onPressed: () {
                resetFields();
                note.setNewSubject(
                    currentNote.subjectId!, currentNote.subjectName!);
              },
              icon: const Icon(Icons.replay),
              tooltip: "Reset Fields",
            ),
            IconButton(
              onPressed: deleteNote,
              icon: const Icon(Icons.delete),
              tooltip: "Delete Note",
            )
          ],
        ),
        body: Center(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(20),
            child: renderFormFields(),
          ),
        ),
      );
    });
  }

  Form renderFormFields() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          myFormField(
            label: "Name",
            controller: _nameControl,
            isRequired: true,
          ),
          subjectSearchBar(
              _searchController, "Select a Subject here", suggestedSubjects,
              (context, controller) {
            return [
              ...List.generate(
                  suggestedSubjects.length > 5 ? 5 : suggestedSubjects.length,
                  (index) {
                final subject = suggestedSubjects[index].subject;
                final subjectCode = suggestedSubjects[index].subjectCode;
                final subjectId = suggestedSubjects[index].id;
                return ListTile(
                  title: Text(subject),
                  subtitle: Text(subjectCode),
                  onTap: () {
                    setState(() {
                      _subjectName = subject;
                      _subjectId = subjectId!;
                      controller.closeView(subject);
                    });
                    setNote();
                  },
                );
              }),
              if (suggestedSubjects.isEmpty) addASubjectButton(context)
            ];
          }),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                  onPressed: showTags, child: const Text('Select Tags')),
              TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedTags = [];
                    });
                  },
                  child: const Text("Clear Tags"))
            ],
          ),
          Wrap(
            children: _selectedTags
                .map((e) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Chip(
                      label: Text(e),
                    )))
                .toList(),
          ),
          TextFormField(
            controller: _summaryControl,
            decoration: const InputDecoration(
              labelText: "Summary",
              hintText: "Write a brief summary of the note",
            ),
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            maxLength: 100,
            maxLines: 4,
          ),
        ],
      ),
    );
  }
}
