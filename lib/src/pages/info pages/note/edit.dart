import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/components/uicomponents.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/providers.dart';

class EditNotePage extends StatefulWidget {
  const EditNotePage({super.key, required this.noteId});

  final String noteId;
  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameControl;
  late TextEditingController _tag1Control;
  late TextEditingController _tag2Control;
  late TextEditingController _tag3Control;
  late TextEditingController _summaryControl;

  late CurrentNoteProvider currentNote;

  String _subjectName = "";
  String _subjectId = "";

  @override
  void initState() {
    currentNote = Provider.of<CurrentNoteProvider>(context, listen: false);

    _nameControl = TextEditingController(text: currentNote.name ?? "");
    _tag1Control = TextEditingController(text: currentNote.readTag1 ?? "");
    _tag2Control = TextEditingController(text: currentNote.readTag2 ?? "");
    _tag3Control = TextEditingController(text: currentNote.readTag3 ?? "");
    _summaryControl = TextEditingController(text: currentNote.summary ?? "");

    _subjectName = currentNote.readSubjectName ?? "";
    _subjectId = currentNote.readSubjectId ?? "";
    super.initState();

    Future.microtask(() {
      currentNote.setEditing(true);
      currentNote.setNewSubject(_subjectId, _subjectName);
    });
  }

  void resetFields() {
    _nameControl.text = currentNote.readName ?? "";
    _tag1Control.text = currentNote.readTag1 ?? "";
    _tag2Control.text = currentNote.readTag2 ?? "";
    _tag3Control.text = currentNote.readTag3 ?? "";
    _summaryControl.text = currentNote.summary ?? "";

    setState(() {
      _subjectName = currentNote.subjectName!;
      _subjectId = currentNote.subjectId!;
    });
  }

  void setNote(CurrentNoteProvider noteData) {
    final queryNotes = context.read<QueryNotesProvider>();
    noteData.setNote(
      _nameControl.text,
      _subjectName,
      _subjectId,
      notesummary: _summaryControl.text,
      notetag1: _tag1Control.text,
      notetag2: _tag2Control.text,
      notetag3: _tag3Control.text,
    );

    // reset notemodel

    final universityNotes = queryNotes.getUniversityNotes;

    NoteModel editedNote =
        universityNotes.where((note) => note.id == widget.noteId).first;

    editedNote.editFields(
        _nameControl.text,
        _subjectId,
        _subjectName,
        _summaryControl.text,
        [_tag1Control.text, _tag2Control.text, _tag3Control.text]);

    queryNotes.editNote(editedNote);
    final username = context.read<UserProvider>().readUserData?.username;
    Database.editNote(editedNote, username ?? editedNote.author);
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

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentNoteProvider>(builder: (context, note, child) {
      _subjectName = note.readNewSubjectName ?? note.subjectName!;
      _subjectId = note.readNewSubjectId ?? note.subjectId!;
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
              onPressed: () => setNote(note),
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
          ElevatedButton(
              onPressed: () {
                context.push("/addnote/selectsubject");
              },
              child: Text(_subjectName)),
          myFormField(
            label: "Tag 1",
            controller: _tag1Control,
            isRequired: false,
          ),
          myFormField(
            label: "Tag 2",
            controller: _tag2Control,
            isRequired: false,
          ),
          myFormField(
            label: "Tag 3",
            controller: _tag3Control,
            isRequired: false,
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
