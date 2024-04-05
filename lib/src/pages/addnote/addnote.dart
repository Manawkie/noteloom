import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_app/src/components/uicomponents.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class AddNote extends StatefulWidget {
  const AddNote({super.key});

  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  final _formkey = GlobalKey<FormState>();

  late TextEditingController _nameControl;
  late TextEditingController _tag1Control;
  late TextEditingController _tag2Control;
  late TextEditingController _tag3Control;

  FilePickerResult? result;
  Uint8List? bytes;
  String? url;

  @override
  void initState() {
    _nameControl = TextEditingController();
    _tag1Control = TextEditingController();
    _tag2Control = TextEditingController();
    _tag3Control = TextEditingController();

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

  void _uploadFile() async {
    result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf']);

    if (result != null) {
      final file = result!.files.single;
      bytes = file.bytes!;

      if (kDebugMode) print(file.name);

      setState(() {
        _nameControl.text = file.name.split(".pdf")[0];
      });

      url = await Storage.addFile(file.name, bytes!);
    }
  }

  void _submitFile() {
    setState(() {
      try {
        if (_formkey.currentState!.validate()) {
          // if (result.count != 0) {
          //   Uint8List fileBytes = result.files.first.bytes!;
          //   String fileName = result.files.first.name;
          // }
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
          setState(() {
            resultString = "No file uploaded yet.";
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      height: double.infinity,
      margin: const EdgeInsets.all(30),
      child: Form(
        key: _formkey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text("Share your note here", style: TextStyle(fontSize: 30)),
            const SizedBox(
              height: 20,
            ),
            myFormField(
                label: "Name", controller: _nameControl, isRequired: true),
            (result == null)
                ? ElevatedButton(
                    onPressed: _uploadFile,
                    child: const Text("Upload a file"),
                  )
                : ElevatedButton(
                    onPressed: () {
                      context.goNamed("preview", pathParameters: {
                        "name": _nameControl.text,
                        "url": url!
                      });
                    },
                    child: const Text("Preview File")),
            myFormField(
                label: "Tag 1", controller: _tag1Control, isRequired: false),
            myFormField(
                label: "Tag 2", controller: _tag2Control, isRequired: false),
            myFormField(
                label: "Tag 3", controller: _tag3Control, isRequired: false),
            ElevatedButton(onPressed: _submitFile, child: const Text("Post")),
            Text(resultString),
            if (bytes != null) Flexible(child: SfPdfViewer.memory(bytes!))
          ],
        ),
      ),
    ));
  }
}
