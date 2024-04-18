import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/providers.dart';
import 'package:school_app/src/utils/sharedprefs.dart';
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
  bool isSaved = false;

  void onExit() {
    final contextCopy = context;
    Database.saveNote(widget.note, isSaved);
    SharedPrefs.addLikedNote(widget.note, isSaved);
    SharedPrefs.addLikedNote(widget.note, isSaved).then((newList) {
      Provider.of<UserProvider>(contextCopy, listen: false).setSavedNoteIds(
        newList,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([
          Storage.getFile(widget.note.storagePath),
          SharedPrefs.isNoteSaved(widget.note),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: Text("Loading Page"),
              ),
            );
          }

          if (snapshot.hasData) {
            // add as recent note
            Database.setRecents("notes/${widget.note.id}");
          }

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () {
                  onExit();
                  context.pop();
                },
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.note.name,
                            style: const TextStyle(fontSize: 20),
                          ),
                          Text(
                            widget.note.subjectId,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Saved(
                            isSaved: snapshot.data![1] as bool,
                            note: widget.note,
                            setSaved: (bool saved) {
                              isSaved = saved;
                            },
                          ),
                          Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text("69"),
                              ),
                              IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.thumb_up))
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.note.summary ?? "",
                          textAlign: TextAlign.start,
                        ),
                        Text("@${widget.note.author}"),
                      ],
                    ),
                  ),
                  Flexible(
                      child: SfPdfViewer.memory(snapshot.data?[0] as Uint8List))
                ],
              ),
            ),
          );
        });
  }
}

class Saved extends StatefulWidget {
  const Saved(
      {super.key,
      required this.isSaved,
      required this.note,
      required this.setSaved});

  final bool isSaved;
  final NoteModel note;
  final Function(bool isSaved) setSaved;

  @override
  State<Saved> createState() => _SavedState();
}

class _SavedState extends State<Saved> {
  bool isSaved = false;

  @override
  void initState() {
    isSaved = widget.isSaved;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(
          Icons.bookmark,
          color: isSaved ? Theme.of(context).colorScheme.primary : null,
        ),
        onPressed: () {
          setState(() {
            isSaved = !isSaved;
          });
          widget.setSaved(isSaved);
        });
  }
}
