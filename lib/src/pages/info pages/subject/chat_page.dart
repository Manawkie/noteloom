import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:school_app/src/pages/info%20pages/subject/chat_service.dart";

class ChatPage extends StatefulWidget {
  final String groupChatName;
  const ChatPage({
    super.key,
    required this.groupChatName,
    });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messsageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    if (_messsageController.text.isNotEmpty) {
        await _chatService.sendMessage(widget.recieverId, message, subjectId)
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.groupChatName),),
    );
  }
}