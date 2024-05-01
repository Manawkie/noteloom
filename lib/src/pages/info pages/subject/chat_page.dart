import "package:flutter/foundation.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:provider/provider.dart";
import "package:school_app/src/components/uicomponents.dart";
import "package:school_app/src/components/usermessage.dart";
import "package:school_app/src/pages/info%20pages/subject/chat_service.dart";
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
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Consumer<QueryNotesProvider>(builder: (context, querynotes, child) {
      final currentSubject = querynotes.findSubject(widget.subjectId);
      return Scaffold(
        appBar: AppBar(
          title: Text(currentSubject?.subject ?? " "),
        ),
        body: Column(
          children: [
            // messages
            Expanded(
              child: _buildMessagelist(),
            ),
            // user input
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: MessageInput(
                  chatService: _chatService,
                  subjectId: widget.subjectId,
                )),
          ],
        ),
      );
    });
  }

  // build message list
  Widget _buildMessagelist() {
    return StreamBuilder(
      stream: _chatService.getMessages(widget.subjectId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('error${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        return ListView(
          dragStartBehavior: DragStartBehavior.down,
          children: snapshot.data!.docs
              .map((document) => UserMessage(message: document.data()))
              .toList(),
        );
      },
    );
  }
}

class MessageInput extends StatefulWidget {
  const MessageInput({
    super.key,
    required this.chatService,
    required this.subjectId,
  });

  final ChatService chatService;
  final String subjectId;

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  late TextEditingController _messsageController;
  String message = "";
  late UserProvider _user;
  late MessageProvider _messageData;
  MessageType messageType = MessageType.message;
  String noteIdRef = "";

  @override
  void initState() {
    _user = context.read<UserProvider>();
    _messageData = context.read<MessageProvider>();
    _messsageController = TextEditingController(text: _messageData.readMessage);

    Future.microtask(() {
      if (_messageData.readCurrentSubjectId != widget.subjectId) {
        _messageData.clearFields();
        _messsageController.text = "";
      }
      _messageData.setCurrentNoteId(widget.subjectId);
      messageType = _messageData.readMessageType;
      noteIdRef = _messageData.readNoteId ?? "";
    });

    

    super.initState();
  }

  void sendMessage() async {
    if (kDebugMode) {
      print(noteIdRef);
      print(messageType);
      
    }
    //only send message if theres something to send
    if (_messsageController.text.isNotEmpty) {
      await widget.chatService.sendMessage(
        _user.readUserData!.username,
        _messsageController.text,
        widget.subjectId,
        messageType,
        noteIdRef,
      );

      //delete the message after sending
      _messsageController.clear();
    }
  }

  void setFields() {
    _messageData.setNoteId(noteIdRef);
    _messageData.setMessageType(messageType);
  }

  void setMessageType(MessageType type) {
    setState(() {
      messageType = type;
    });
  }

  void selectMessageType(MessageProvider messageData) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                  "Select a message type. Using a Note Message will allow you to reference a note."),
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text("Message"),
              onTap: () {
                setMessageType(MessageType.message);
                messageData.setMessageType(MessageType.message);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.note,
              ),
              title: const Text("Note"),
              onTap: () {
                setMessageType(MessageType.comment);
                messageData.setMessageType(MessageType.comment);
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
    setFields();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageProvider>(builder: (context, messageData, child) {

      if (messageData.readNoteId != null) {
        noteIdRef = messageData.readNoteId!;
      }
      
      return Row(
        children: [
          // text field
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: MyMessageField(
                controller: _messsageController,
                hintText: 'Enter message',
                obscureText: false,
                onChanged: (value) {
                  setState(() {
                    message = value ?? "";
                  });
                  messageData.setMessage(message);
                }),
          )),
          Row(
            children: [
              IconButton(
                onPressed: () => selectMessageType(messageData),
                icon: Icon(messageType == MessageType.message
                    ? Icons.message
                    : Icons.note),
              ),
              IconButton(
                onPressed: () {
                  if (messageType == MessageType.comment) {
                    context.pushNamed("selectNote",
                        pathParameters: {"id": widget.subjectId});
                  }
                },
                icon: const Icon(
                  Icons.note_add,
                ),
              )
            ],
          ),
          // send button
          IconButton(
            onPressed: sendMessage,
            icon: const Icon(
              Icons.arrow_upward,
              size: 40,
            ),
          ),
        ],
      );
    });
  }
}
