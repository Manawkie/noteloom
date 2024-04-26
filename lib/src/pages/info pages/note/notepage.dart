import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/components/uicomponents.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/providers.dart';
import 'package:school_app/src/utils/sharedprefs.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key, required this.id});
  final String id;

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<QueryNotesProvider>(builder: (context, notes, child) {
      NoteModel? note = notes.findNote(widget.id);
      if (note == null) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () {
                context.go('/home');
              },
            ),
          ),
          body: const Center(
            child: Text("Note not found"),
          ),
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
  final _key = GlobalKey<SfPdfViewerState>();
  late PdfViewerController _controller;

  @override
  void initState() {
    _controller = PdfViewerController();
    final currentNote =
        Provider.of<CurrentNoteProvider>(context, listen: false);

    Future.microtask(() {
      // set current note

      if (currentNote.readEditing == false) {
        currentNote.setNote(widget.note.name, widget.note.subjectId,
            notesummary: widget.note.summary,
            notetag1: widget.note.tags?[0],
            notetag2: widget.note.tags?[1],
            notetag3: widget.note.tags?[2]);
      }

      final userData = context.read<UserProvider>();

      Database.setRecents("notes/${widget.note.id}");
      userData.addRecents("notes/${widget.note.id}");
    });

    super.initState();
  }

  void onExit(List<String> noteIdSaved) async {
    final getSharedPrefList = await SharedPrefs.getSavedNotes();
    if (getSharedPrefList.length < noteIdSaved.length) {
      Database.saveNote(widget.note, false);
    }
    if (getSharedPrefList.length > noteIdSaved.length) {
      Database.saveNote(widget.note, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([
          Storage.getFile(widget.note.storagePath),
          SharedPrefs.getSavedNotes()
              .then((savednotes) => savednotes.contains(widget.note.id)),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: myLoadingIndicator(),
              ),
            );
          }
          final userData = Provider.of<UserProvider>(context, listen: false);
          bool isOwned = false;

          final allSavedNotes = userData.readSavedNoteIds;

          if (widget.note.author == userData.readUserData!.username) {
            isOwned = true;
          }

          return Consumer<CurrentNoteProvider>(
              builder: (context, currentNote, child) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: () async {
                    onExit(allSavedNotes);
                    context.pop();
                  },
                ),
                actions: [
                  if (isOwned)
                    IconButton(
                        onPressed: () {
                          context.pushNamed("editNote", pathParameters: {
                            "id": widget.note.id!,
                          });
                        },
                        icon: const Icon(Icons.edit))
                ],
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
                              currentNote.name ?? "",
                              style: const TextStyle(fontSize: 20),
                            ),
                            Text(
                              currentNote.subject ?? "",
                            ),
                          ],
                        ),
                        Actions(
                          isSaved: snapshot.data![1] as bool,
                          note: widget.note,
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentNote.summary ?? "",
                            textAlign: TextAlign.start,
                          ),
                          Text("@${widget.note.author}"),
                        ],
                      ),
                    ),
                    Flexible(
                        child: SfPdfViewer.memory(
                      snapshot.data?[0] as Uint8List,
                      key: _key,
                      enableTextSelection: true,
                      controller: _controller,
                    ))
                  ],
                ),
              ),
            );
          });
        });
  }
}

class Actions extends StatefulWidget {
  const Actions({
    super.key,
    required this.isSaved,
    required this.note,
  });

  final bool isSaved;
  final NoteModel note;

  @override
  State<Actions> createState() => _ActionsState();
}

class _ActionsState extends State<Actions> {
  bool isSaved = false;
  bool isLiked = false;

  @override
  void initState() {
    isSaved = widget.isSaved;
    super.initState();
  }

  void saveNote() {
    setState(() {
      isSaved = !isSaved;
      final userData = context.read<UserProvider>();
      if (isSaved) {
        userData.addSavedNoteId(widget.note.id!);
      } else {
        userData.removeSavedNoteId(widget.note.id!);
      }
      SharedPrefs.addSavedNote(widget.note, isSaved);
    });
  }

  void likeNote() {
    setState(() {
      isLiked = !isLiked;
      Database.likeNote(widget.note, isLiked);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<NoteModel>>(
        stream: Database.noteStream(widget.note),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return Center(
              child: myLoadingIndicator(),
            );
          }

          isLiked = snapshot.data!
                  .data()!
                  .peopleLiked
                  ?.contains(Auth.currentUser!.uid) ??
              false;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  icon: Icon(
                    Icons.bookmark,
                    color:
                        isSaved ? Theme.of(context).colorScheme.primary : null,
                  ),
                  onPressed: saveNote),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                        snapshot.data?.data()?.peopleLiked?.length.toString() ??
                            "0"),
                  ),
                  IconButton(
                      onPressed: likeNote,
                      icon: Icon(
                        Icons.thumb_up,
                        color: isLiked
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ))
                ],
              )
            ],
          );
        });
  }
}
