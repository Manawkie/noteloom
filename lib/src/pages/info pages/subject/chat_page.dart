import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:school_app/src/pages/info%20pages/subject/chat_service.dart";
import "package:school_app/src/pages/info%20pages/subject/text_field.dart";

class ChatPage extends StatefulWidget {
  final String senderId;
  final String message;
  final String subjectId;

  const ChatPage({
    super.key,
    required this.senderId,
    required this.message,
    required this.subjectId,
    });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messsageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {

    //only send message if theres something to send
    if (_messsageController.text.isNotEmpty) {
        await _chatService.sendMessage(widget.senderId, widget.message, widget.subjectId);

    //delete the message after sending
        _messsageController.clear();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.subjectId),),
      body: Column(
        children: [
          // messages
          Expanded(
            child: _buildMessagelist(),
            ),

          // user input
            _buildMessageInput(),
        ],),
    );
  }
  // build message list
  Widget _buildMessagelist()  {
    return StreamBuilder(
      stream: _chatService.getMessages(widget.senderId, widget.subjectId),
      builder: (context, snapshot)  {
        if (snapshot.hasError)  {
          return Text('error${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading..');
        }

        return ListView(
          children: 
          snapshot.data!.docs
          .map((document) => _buildMessageItem(document))
          .toList(),


        );
      },
    );
  }
  // build message item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    //alignment of the messages if the u r the sender then its in right else left
    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
      ? Alignment.centerRight
      : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Column(
        children: [
          Text(data['sender'])
        ],),
    );
  }

  // build message input
  Widget _buildMessageInput() {
    return Row(
      children: [
        // text field
          Expanded(
            child: MyTextField(
              controller: _messsageController,
              hintText: 'Enter message',
              obscureText: false,
          )
        ),
        // send button
        IconButton(
          onPressed: sendMessage,
           icon: const Icon(
            Icons.arrow_upward,
            size: 40,
            )
          ),
      ],
    );
  }
}