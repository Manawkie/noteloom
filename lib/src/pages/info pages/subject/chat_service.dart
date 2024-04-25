import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_app/src/pages/info%20pages/subject/messages.dart';

class ChatService extends ChangeNotifier {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// sending a message
  Future<void> sendMessage(String senderName, String message, String subjectId) async {


    // get the current user 
    final String senderUserId = _firebaseAuth.currentUser!.uid;
    final String senderUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    //to send message
    Message newMessage = Message(
      senderId: senderUserId,
       senderEmail: senderUserEmail,
        senderName: senderName,
         message: message,
          timestamp: timestamp,
          );
    
    //to add to firebase // waiting pa sa subject id ni wends
    await _firestore
    .collection('subjects')
    .doc(subjectId)
    .collection('discussion')
    .add(newMessage.toMap());
  }
    //get the message from firabase 
  Stream<QuerySnapshot> getMessages(String userId, String subId) {

    return _firestore
    .collection('subjects')
    .doc(subId)
    .collection('discussion')
    .orderBy('timestamp', descending: false)
    .snapshots();
  }




}
