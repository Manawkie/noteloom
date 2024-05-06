import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/providers.dart';

class UserMessage extends StatelessWidget {
  const UserMessage({
    super.key,
    required this.message,
  });

  final MessageModel message;

  Widget renderUpperBox(BuildContext context) {

    if (message.noteId == null || message.noteId == "") {
      return const SizedBox.shrink();
    }

    final NoteModel? note =
        context.read<QueryNotesProvider>().findNote(message.noteId!);

    return GestureDetector(
      onTap: () {
        context.push('/note/${note.id}');
      },
      child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(5),
          child: Text(
            note!.name,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUserMessage = Auth.currentUser!.uid == message.senderId;
    List<Widget> messageComponents = [
      if (!isUserMessage)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: CircleAvatar(
            backgroundImage: NetworkImage(message.senderUserProfileURL),
          ),
        ),
      Flexible(
        child: Column(
          crossAxisAlignment:
              isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isUserMessage) Text(message.senderUsername),
            if (message.noteId != null || message.noteId == "")
              renderUpperBox(context),
            Container(
                padding: const EdgeInsets.all(10),
                margin: EdgeInsetsDirectional.fromSTEB(
                    isUserMessage ? 60 : 0, 0, isUserMessage ? 0 : 60, 0),
                decoration: BoxDecoration(
                  color: isUserMessage ? Colors.blue : Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  message.message,
                  style: const TextStyle(color: Colors.white),
                )),
          ],
        ),
      )
    ];

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: messageComponents,
      ),
    );
  }
}
