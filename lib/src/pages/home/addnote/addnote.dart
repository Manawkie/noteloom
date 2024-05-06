import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/components/uicomponents.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/providers.dart';

class AddNote extends StatefulWidget {
  const AddNote({super.key, required this.onpageChanged});
  final void Function(int index) onpageChanged;

  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  final _formkey = GlobalKey<FormState>();

  late TextEditingController _nameControl;
  late TextEditingController _tag1Control;
  late TextEditingController _tag2Control;
  late TextEditingController _tag3Control;
  String _subjectName = "";
  String _subjectId = "";
  late TextEditingController _summaryControl;

  List<String> subjects = [];

  FilePickerResult? result;
  Uint8List? bytes;

  late FToast ftoast;

  bool isUploading = false;
  @override
  void initState() {
    final noteData = Provider.of<NoteProvider>(context, listen: false);

    _nameControl = TextEditingController(text: noteData.name ?? "");
    _tag1Control = TextEditingController(text: noteData.readTag1 ?? "");
    _tag2Control = TextEditingController(text: noteData.readTag2 ?? "");
    _tag3Control = TextEditingController(text: noteData.readTag3 ?? "");
    _summaryControl = TextEditingController(text: noteData.summary ?? "");

    _subjectName = noteData.readSubjectName ?? "Select a Subject";
    _subjectId = noteData.readSubjectId ?? "";
    ftoast = FToast();
    ftoast.init(context);

    super.initState();
  }

  String resultString = "";

  @override
  void dispose() {
    _nameControl.dispose();
    _tag1Control.dispose();
    _tag2Control.dispose();
    _tag3Control.dispose();
    super.dispose();
  }

  Future _uploadFile() async {
    result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf']);

    if (result != null) {
      final file = result!.files.single;
      bytes = file.bytes!;
      setState(() {
        _nameControl.text = file.name.split(".pdf")[0];
      });
    }
  }

  Future _submitFile(
      BuildContext context, NoteProvider note, QueryNotesProvider uni) async {
    final theme = Theme.of(context);

    setState(() {
      isUploading = true;
    });

    try {
      if (_subjectName == "Select a Subject" || !subjects.contains(_subjectName)) {
        throw ErrorDescription("Please select a Subject first");
      }
      if (_formkey.currentState!.validate()) {
        if (result != null && bytes != null) {
          final newNote = await Database.submitFile(
              bytes!,
              _nameControl.text,
              _subjectId,
              _subjectName,
              [_tag1Control.text, _tag2Control.text, _tag3Control.text],
              _summaryControl.text);
          clearFields(note);
          setState(() {
            isUploading = false;
          });
          ftoast.showToast(
            child: myToast(theme, "Note posted!"),
            gravity: ToastGravity.BOTTOM,
            fadeDuration: const Duration(milliseconds: 400),
            toastDuration: const Duration(seconds: 2),
            isDismissable: true,
            ignorePointer: false,
          );
          final newList = uni.getUniversityNotes;
          newList.add(newNote);
          uni.setUniversityNotes(newList);
        }
      }
    } on ErrorDescription catch (e) {
      setState(() {
        isUploading = false;
      });
      ftoast.showToast(
        child: myToast(theme, e.toString()),
        gravity: ToastGravity.BOTTOM_RIGHT,
        fadeDuration: const Duration(milliseconds: 400),
        toastDuration: const Duration(seconds: 2),
        isDismissable: true,
        ignorePointer: false,
      );
    }
  }

  void clearFields(NoteProvider note) {
    note.clearFields();
    result = null;
    bytes = null;
    _nameControl.text = note.readName!;
    _summaryControl.text = note.readSummary!;
    _subjectName = note.readSubjectName ?? "Select a Subject";
    _subjectId = note.readSubjectId ?? "";
    _tag1Control.text = note.readTag1!;
    _tag2Control.text = note.readTag2!;
    _tag3Control.text = note.readTag3!;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<NoteProvider, QueryNotesProvider>(
        builder: (context, note, uni, child) {
      if (note.readBytes != null) {
        bytes = note.readBytes;
      }
      if (note.readResult != null) {
        result = note.readResult;
      }

      if (note.readSubjectName != null) {
        _subjectName = note.readSubjectName!;
      }

      if (note.readSubjectId != null) {
        _subjectId = note.readSubjectId!;
      }

      if (subjects.isEmpty) {
        for (var subject in uni.getUniversitySubjects) {
          subjects.add(subject.subject);
        }
      }

      void setNote() {
        note.setResult(
          result,
          _nameControl.text,
          _summaryControl.text,
          _subjectName,
          _subjectId,
          _tag1Control.text,
          _tag2Control.text,
          _tag3Control.text,
        );
      }

      void removeNote() {
        note.removeFile();
        setState(() {
          _nameControl.text = "";
          result = null;
          bytes = null;
        });
      }

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.pop(),
            color: Colors.black,
          ),
        ),
        body: Scaffold(
            body: Container(
          height: double.infinity,
          margin: const EdgeInsets.all(20),
          child: Form(
            key: _formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text("Share your note here",
                    style: TextStyle(fontSize: 30)),
                const SizedBox(
                  height: 20,
                ),
                myFormField(
                    label: "Name",
                    controller: _nameControl,
                    isRequired: true,
                    onChanged: (value) {
                      setState(() {
                        resultString = value;
                      });
                      note.setName(resultString);
                    }),
                ElevatedButton(
                    onPressed: () {
                      context.go("/addnote/selectsubject");
                    },
                    child: Text(note.readSubjectName ?? "Select a Subject")),
                (result == null)
                    ? ElevatedButton(
                        onPressed: () async {
                          await _uploadFile();
                          setNote();
                        },
                        child: const Text("Upload a file"),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                setNote();
                                widget.onpageChanged(1);
                              },
                              child: const Text("Preview File")),
                          IconButton(
                              onPressed: removeNote,
                              icon: const Icon(Icons.delete))
                        ],
                      ),
                myFormField(
                    label: "Tag 1",
                    controller: _tag1Control,
                    isRequired: false,
                    onChanged: (value) => setNote()),
                myFormField(
                    label: "Tag 2",
                    controller: _tag2Control,
                    isRequired: false,
                    onChanged: (value) => setNote()),
                myFormField(
                    label: "Tag 3",
                    controller: _tag3Control,
                    isRequired: false,
                    onChanged: (value) => setNote()),
                TextFormField(
                  controller: _summaryControl,
                  decoration: const InputDecoration(
                    labelText: "Summary",
                    hintText: "Write a brief summary of the note",
                  ),
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  maxLength: 100,
                  maxLines: 4,
                  onChanged: (value) {
                    note.setSummary(value);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    (isUploading)
                        ? ElevatedButton(
                            onPressed: () {},
                            child: SizedBox(
                              height: 10,
                              width: 10,
                              child: myLoadingIndicator(),
                            ))
                        : ElevatedButton(
                            onPressed: () async =>
                                _submitFile(context, note, uni),
                            child: const Text("Post")),
                    IconButton(
                      onPressed: () => clearFields(note),
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        )),
      );
    });
  }
}
