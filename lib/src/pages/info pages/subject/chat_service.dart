import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/models.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// sending a message
  Future<void> sendMessage(
      String senderName, String message, String subjectId, String? noteId) async {
    // get the current user
    final String senderUserId = _firebaseAuth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    //to send message
    MessageModel newMessage = MessageModel(
      senderId: senderUserId,
      senderUserProfileURL: Auth.currentUser!.photoURL!,
      noteId: noteId,
      senderUsername: senderName,
      message: message,
      timestamp: timestamp,
    );

    //to add to firebase // waiting pa sa subject id ni wends
    await Database.db
        .collection('subjects')
        .doc(subjectId)
        .collection('discussion')
        .add(newMessage.toFirestore());
  }

  //get the message from firabase
  Stream<QuerySnapshot<MessageModel>> getMessages(String subId) {
    return Database.db
        .collection('subjects')
        .doc(subId)
        .collection('discussion')
        .withConverter(
            fromFirestore: MessageModel.fromFirestore,
            toFirestore: (model, _) => model.toFirestore())
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
