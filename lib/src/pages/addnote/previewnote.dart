import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/utils/providers.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PreviewNote extends StatefulWidget {
  const PreviewNote({super.key, required this.onPageChanged});

  final void Function(int index) onPageChanged;

  @override
  State<PreviewNote> createState() => _PreviewNoteState();
}

class _PreviewNoteState extends State<PreviewNote> {
  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(builder: (context, addnote, child) {
      final bytes = addnote.readBytes;
      return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              color: Colors.black,
              onPressed: () {
                widget.onPageChanged(0);
              },
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            title: const Text(
              "Preview Note",
              style: TextStyle(color: Colors.black),
            ),
          ),
          body: _renderPDF(bytes, addnote.readName ?? ""));
    });
  }

  Widget _renderPDF(Uint8List? bytes, String title) {
    if (bytes == null) {
      return const Center(
        child: Text("No file to preview. Please upload a file first."),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 30),),
        Flexible(child: SfPdfViewer.memory(bytes)),
      ],
    );
  }
}
