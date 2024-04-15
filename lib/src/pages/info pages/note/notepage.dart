import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/components/uicomponents.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/providers.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class NotePage extends StatelessWidget {
  const NotePage({super.key, required this.id});

  final String id;
  @override
  Widget build(BuildContext context) {
    return Consumer<QueryNotesProvider>(builder: (context, notes, child) {
      NoteModel? note = notes.findNote(id);

      if (note == null) {
        return const Center(
          child: Text("Note not found"),
        );
      }

      return RenderNote(
        note: note,
      );
    });
  }
}

class RenderNote extends StatefulWidget {
  const RenderNote({super.key, required this.note});

  final NoteModel note;
  @override
  State<RenderNote> createState() => _RenderNoteState();
}

class _RenderNoteState extends State<RenderNote> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(widget.note.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.note.subjectId,
                  style: const TextStyle(fontSize: 20),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  IconButton(
                    icon: const Icon(Icons.bookmark),
                    onPressed: () {},
                  ),
                  Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text("69"),
                      ),
                      IconButton(
                          onPressed: () {}, icon: const Icon(Icons.thumb_up))
                    ],
                  )
                ])
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Text(
                    widget.note.summary ?? "",
                    textAlign: TextAlign.start,
                  ),
                  Text("@${widget.note.author ?? "student"}"),
                ],
              ),
            ),
            Expanded(
                child: FutureBuilder(
              future: Storage.getFile(widget.note.storagePath),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.data == null) {
                  return Center(
                    child: myLoadingIndicator(),
                  );
                }
                return SfPdfViewer.network(snapshot.data!);
              },
            ))
          ],
        ),
      ),
    );
  }
}
