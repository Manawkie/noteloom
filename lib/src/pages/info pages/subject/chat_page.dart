import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:school_app/src/pages/info%20pages/subject/chat_service.dart";
import "package:school_app/src/pages/info%20pages/subject/messages.dart";
import "package:school_app/src/pages/info%20pages/subject/text_field.dart";
import "package:school_app/src/utils/firebase.dart";
import "package:school_app/src/utils/models.dart";
import "package:school_app/src/utils/providers.dart";

class ChatPage extends StatefulWidget {
  final String subjectId;

  const ChatPage({
    super.key,
    required this.subjectId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messsageController = TextEditingController();
  final ChatService _chatService = ChatService();
  late UserProvider _user;

  @override
  void initState() {
    _user = context.read<UserProvider>();
    super.initState();
  }

  void sendMessage() async {
    //only send message if theres something to send
    if (_messsageController.text.isNotEmpty) {
      await _chatService.sendMessage(_user.readUserData!.username,
          _messsageController.text, widget.subjectId);

      //delete the message after sending
      _messsageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subjectId),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            // messages
            Expanded(
              child: _buildMessagelist(),
            ),
            // user input
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  // build message list
  Widget _buildMessagelist() {
    return StreamBuilder(
      stream: _chatService.getMessages(Auth.currentUser!.uid, widget.subjectId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('error${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        return ListView(
          children: snapshot.data!.docs
              .map((document) => _buildMessageItem(document.data()))
              .toList(),
        );
      },
    );
  }

  // build message item
  Widget _buildMessageItem(MessageModel message) {
    //alignment of the messages if the u r the sender then its in right else left
    var alignment = (message.senderId == Auth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Column(
        children: [Text(message.senderUsername), Text(message.message)],
      ),
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
        )),
        // send button
        IconButton(
            onPressed: sendMessage,
            icon: const Icon(
              Icons.arrow_upward,
              size: 40,
            )),
      ],
    );
  }
}
