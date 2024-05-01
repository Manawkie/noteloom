import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/providers.dart';

enum MessageType { message, question, answer, comment }

class UserMessage extends StatefulWidget {
  const UserMessage(
      {super.key,
      required this.username,
      required this.name,
      required this.userProfileURL,
      required this.message,
      required this.messageType,
      this.questionId,
      this.noteId});

  final String userProfileURL;
  final String username;
  final String name;
  final String message;
  final MessageType messageType;
  final String? questionId;
  final String? noteId;

  @override
  State<UserMessage> createState() => _UserMessageState();
}

class _UserMessageState extends State<UserMessage> {
  late Alignment _alignment;

  @override
  void initState() {
    final userData = context.read<UserProvider>();

    final isCurrentUserMessage =
        userData.readUserData!.username == widget.username;
    super.initState();
  }

  Widget mainComponent() {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(widget.userProfileURL),
        ),
        Column(
          children: [
            Text(widget.name),
            Text(widget.message),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
