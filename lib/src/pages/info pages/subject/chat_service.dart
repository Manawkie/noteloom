import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_app/src/pages/info%20pages/subject/messages.dart';

class ChatService extends ChangeNotifier {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// sending a message
  Future<void> sendMessage(String senderName, String message, String subjectId) async {

    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();


    Message newMessage = Message(
      senderId: currentUserId,
       senderEmail: currentUserEmail,
        senderName: senderName,
         message: message,
          timestamp: timestamp,
          );
    
    await _firestore
    .collection('subjects')
    .doc(subjectId)
    .collection('discussion')
    .add(newMessage.toMap());
  }
  /// getting the message 
  Stream<QuerySnapshot> getMessages(String userId, String subId) {

    return _firestore
    .collection('subjects')
    .doc(subId)
    .collection('discussion')
    .orderBy('timestamp', descending: false)
    .snapshots();
  }




}
