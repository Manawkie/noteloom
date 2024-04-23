import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_app/src/pages/info%20pages/subject/chat_page.dart';

class ChatMain extends StatefulWidget {
  const ChatMain({super.key});

  @override
  State<ChatMain> createState() => _ChatMainState();
}

class _ChatMainState extends State<ChatMain> {

  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:const Text('Chats'),
      ),
      body: _buildSubjectList(),
    );
    }
  Widget _buildSubjectList() {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('subjects').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('error');

        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');

        }

        return ListView(
          children: snapshot.data!.docs
          .map<Widget>((doc) => _buildSubjectListItem(doc))
          .toList(),
        );
      }
    );
  }
  Widget _buildSubjectListItem(DocumentSnapshot document){
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;


    return ListTile(
      title: Text(data['subject']),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => ChatPage(
            groupChatName: data['subject']
            )
          )
        );
      },
    );
  }
}