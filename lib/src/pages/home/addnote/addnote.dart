import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/components/uicomponents.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/providers.dart';
import 'package:school_app/src/utils/util_functions.dart';

class AddNote extends StatefulWidget {
  const AddNote({super.key, required this.onpageChanged});
  final void Function(int index) onpageChanged;

  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  final _formkey = GlobalKey<FormState>();
  List<String> _selectedTags = [];

  late TextEditingController _nameControl;
  late TextEditingController _summaryControl;
  late SearchController _searchController;

  String _subjectName = "";
  String _subjectId = "";

  List<String> subjects = [];
  List<SubjectModel> allUniversitySubjects = [];
  List<SubjectModel> suggestedSubjects = [];

  FilePickerResult? result;
  Uint8List? bytes;

  late FToast ftoast;

  bool isUploading = false;
  @override
  void initState() {
    final noteData = Provider.of<NoteProvider>(context, listen: false);

    allUniversitySubjects =
        context.read<QueryNotesProvider>().getUniversitySubjects;
    _nameControl = TextEditingController(text: noteData.name ?? "");
    _summaryControl = TextEditingController(text: noteData.summary ?? "");

    _searchController = SearchController();
    _searchController.text = noteData.readSubjectName ?? "";
    _searchController.addListener(filterSubjects);
    _subjectId = noteData.readSubjectId ?? "";

    _selectedTags = noteData.readTags ?? [];
    ftoast = FToast();
    ftoast.init(context);

    super.initState();
  }

  String resultString = "";

  @override
  void dispose() {
    _nameControl.dispose();
    _summaryControl.dispose();
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
        if (_nameControl.text == "") {
          _nameControl.text = file.name.split(".pdf")[0];
        }
      });
    }
  }

  Future _submitFile(
      BuildContext context, NoteProvider note, QueryNotesProvider uni) async {
    final theme = Theme.of(context);

    if (isUploading) return;
    setState(() {
      isUploading = true;
    });

    try {
      if (bytes == null || result == null) {
        throw ErrorDescription("Please upload a file first");
      }

      if (_subjectName == "Select a Subject" ||
          !subjects.contains(_subjectName)) {
        print(_subjectName);
        throw ErrorDescription("Please select a Subject first");
      }
      if (_formkey.currentState!.validate()) {
        if (result != null && bytes != null) {
          final newNote = await Database.submitFile(bytes!, _nameControl.text,
              _subjectId, _subjectName, _selectedTags, _summaryControl.text);
          clearFields(note);
          _selectedTags.clear;

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
      ftoast.showToast(
        child: myToast(theme, e.toString()),
        gravity: ToastGravity.BOTTOM_RIGHT,
        fadeDuration: const Duration(milliseconds: 400),
        toastDuration: const Duration(seconds: 2),
        isDismissable: true,
        ignorePointer: false,
      );
    }
    setState(() {
      isUploading = false;
    });
  }

  void clearFields(NoteProvider note) {
    note.clearFields();
    result = null;
    bytes = null;
    _nameControl.text = note.readName!;
    _searchController.text = "";
    _summaryControl.text = note.readSummary!;
    _subjectName = note.readSubjectName ?? "Select a Subject";
    _subjectId = note.readSubjectId ?? "";
    _selectedTags.clear();
  }

  void filterSubjects() {
    final search = _searchController.text;
    if (search.isEmpty) {
      suggestedSubjects = allUniversitySubjects;
      return;
    }
    final filteredSubjects = allUniversitySubjects
        .where((subject) =>
            subject.subject.toLowerCase().contains(search.toLowerCase()))
        .toList();
    suggestedSubjects = filteredSubjects;
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
          note.setResult(result, _nameControl.text, _summaryControl.text,
              _subjectName, _subjectId, _selectedTags);
        }

        void removeNote() {
          note.removeFile();
          setState(() {
            _nameControl.text = "";
            result = null;
            bytes = null;
          });
        }

        filterSubjects();

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
            setState(() {
              _selectedTags = results;
            });
            setNote();
          }
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go("/home");
                }
              },
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
                    subjectSearchBar(_searchController, "Select a Subject here",
                        suggestedSubjects, (context, controller) {
                      return [
                        ...List.generate(
                            suggestedSubjects.length > 5
                                ? 5
                                : suggestedSubjects.length, (index) {
                          final subject = suggestedSubjects[index].subject;
                          final subjectCode =
                              suggestedSubjects[index].subjectCode;
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
                        if (suggestedSubjects.isEmpty)
                          addASubjectButton(context)
                      ];
                    }),
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
                    ElevatedButton(
                        onPressed: () {
                          showTags();
                        },
                        child: const Text('Select Tags')),
                    const Divider(
                      height: 30,
                    ),
                    Wrap(
                      children: _selectedTags
                          .map((e) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Chip(
                                  label: Text(e),
                                ),
                              ))
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
                      onChanged: (value) {
                        note.setSummary(value);
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                            onPressed: () async =>
                                _submitFile(context, note, uni),
                            child: isUploading
                                ? SizedBox(
                                    height: 10,
                                    width: 10,
                                    child: myLoadingIndicator(),
                                  )
                                : const Text("Post")),
                        TextButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.red.shade100)),
                          onPressed: () => clearFields(note),
                          child: const Text(
                            "Clear all fields",
                            style: TextStyle(color: Colors.red),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
