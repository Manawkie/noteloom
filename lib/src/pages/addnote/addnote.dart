import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AddNote extends StatefulWidget {
  const AddNote({super.key});

  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  final _formkey = GlobalKey<FormState>();

  final _nameControl = TextEditingController();
  final _tag1Control = TextEditingController();
  final _tag2Control = TextEditingController();
  final _tag3Control = TextEditingController();

  late FilePickerResult result;

  @override
  void dispose() {
    _nameControl.dispose();
    _tag1Control.dispose();
    _tag2Control.dispose();
    _tag3Control.dispose();
    super.dispose();
  }

  Widget _myFormField(
      String name, TextEditingController control, bool required) {
    return TextFormField(
      decoration: InputDecoration(hintText: name),
      validator: (value) {
        if (required && value == null) {
          return "This field is required";
        }
        return null;
      },
    );
  }

  void _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final file = result.files.first;

      setState(() {
        _nameControl.text = file.name;
      });
    }
  }

  void _submitFile() {
    if (result != null) {
      Uint8List fileBytes = result.files.first.bytes!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          margin: const EdgeInsets.all(8),
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                const Text("Share your note here"),
                const SizedBox(
                  height: 20,
                ),
                _myFormField("Name", _nameControl, true),
                ElevatedButton(
                  onPressed: _uploadFile,
                  child: const Text("Upload a file"),
                ),
                _myFormField("Tag 1", _tag1Control, false),
                _myFormField("Tag 2", _tag2Control, false),
                _myFormField("Tag 3", _tag3Control, false),
                ElevatedButton(onPressed: () {
                  if (_formkey.currentState!.validate()) {

                  }
                }, child: const Text("Post"))
              ],
            ),
          )),
    );
  }
}
