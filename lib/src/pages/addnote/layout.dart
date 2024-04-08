import 'package:flutter/material.dart';
import 'package:school_app/src/pages/addnote/addnote.dart';
import 'package:school_app/src/pages/addnote/previewnote.dart';

class AddNoteLayout extends StatefulWidget {
  const AddNoteLayout({super.key});

  @override
  State<AddNoteLayout> createState() => _AddNoteLayoutState();
}

class _AddNoteLayoutState extends State<AddNoteLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          children: [AddNote(), PreviewNote()],
        ),
      ),
    );
  }
}
