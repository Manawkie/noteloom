import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String _subject = "";
  late TextEditingController _summaryControl;

  List<String> subjects = [];

  FilePickerResult? result;
  Uint8List? bytes;

  @override
  void initState() {
    final noteData = Provider.of<NotesProvider>(context, listen: false);

    _nameControl = TextEditingController(text: noteData.name ?? "");
    _tag1Control = TextEditingController(text: noteData.readTag1 ?? "");
    _tag2Control = TextEditingController(text: noteData.readTag2 ?? "");
    _tag3Control = TextEditingController(text: noteData.readTag3 ?? "");
    _summaryControl = TextEditingController(text: noteData.summary ?? "");

    final getUserSubjects =
        Provider.of<UniversityDataProvider>(context, listen: false)
            .readSubjects;

    for (Map<String, dynamic> subjectData in getUserSubjects) {
      subjects.add(subjectData.values.first.toString());
    }

    subjects.insert(0, "Select a Subject");
    _subject = noteData.readSubject ?? subjects.first;

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

  void _submitFile() {
    if (_formkey.currentState!.validate()) {
      if (result != null && bytes != null) {
        Database.submitFile(
            bytes!,
            _nameControl.text,
            _subject,
            [_tag1Control.text, _tag2Control.text, _tag3Control.text],
            _summaryControl.text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<NotesProvider, UniversityDataProvider>(
        builder: (context, addnote, uni, child) {
      if (addnote.readBytes != null) {
        bytes = addnote.readBytes;
      }
      if (addnote.readResult != null) {
        result = addnote.readResult;
      }

      if (kDebugMode) print(uni.readSubjects);

      if (subjects.length == 1) {
        for (var subject in uni.readSubjects) {
          subjects.add(subject.values.first.toString());
        }
      }

      void setNote() {
        addnote.setResult(
          result!,
          _nameControl.text,
          _summaryControl.text,
          _subject,
          _tag1Control.text,
          _tag2Control.text,
          _tag3Control.text,
        );
      }

      void removeNote() {
        addnote.removeFile();
        setState(() {
          _nameControl.text = "";
          result = null;
          bytes = null;
        });
      }

      void clearFields() {
        addnote.clearFields();
        _nameControl.text = addnote.readName!;
        _summaryControl.text = addnote.readSummary!;
        _subject = addnote.subject ?? subjects.first;
        _tag1Control.text = addnote.readTag1!;
        _tag2Control.text = addnote.readTag2!;
        _tag3Control.text = addnote.readTag3!;
      }

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.go("/home"),
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
                      addnote.setName(resultString);
                    }),
                ElevatedButton(
                    onPressed: () {
                      context.go("/addnote/selectsubject");
                    },
                    child: Text(_subject)),
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
                    isRequired: false),
                myFormField(
                    label: "Tag 2",
                    controller: _tag2Control,
                    isRequired: false),
                myFormField(
                    label: "Tag 3",
                    controller: _tag3Control,
                    isRequired: false),
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
                    addnote.setSummary(value);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: _submitFile, child: const Text("Post")),
                    IconButton(
                      onPressed: clearFields,
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
