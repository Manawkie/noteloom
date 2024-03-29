import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/foundation.dart';
import 'package:school_app/src/utils/models.dart';

Future functionWithTryCatchFirebase(Future Function() function) async {
  try {
    final result = await function();
    return result;
  } on FirebaseAuthException catch (e) {
    if (kDebugMode) {
      print(e);
    }
  }
}

class Auth {
  static final auth = FirebaseAuth.instance;

  static final googleProvider = GoogleAuthProvider();

  static Future<void> googleSignIn() async {
    googleProvider.addScope("email");
    googleProvider.addScope("profile");

    try {
      late User? userCred;
      if (kDebugMode) {
        userCred = await auth
            .signInWithPopup(googleProvider)
            .then((cred) => cred.user);
      } else {
        userCred = await auth
            .signInWithProvider(googleProvider)
            .then((cred) => cred.user);
      }
      validateUser(userCred);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print(e.message);
    }
  }

  static Future validateUser(User? user) async {
    final emails = await Database.getUniversities()
        .then((value) => value.map((data) => data.domain));
    if (user == null) {
      return;
    }
    if (emails.contains(user.email!.split("@")[1])) {
      await Database.getUser();
      return true;
    } else {
      throw ErrorDescription(
          "No university found for this email. Please use your university email.");
    }
  }

  Future<void> signOut() async {
    functionWithTryCatchFirebase(() async {
      await auth.signOut();
    });
  }
}

class Database {
  static final db = FirebaseFirestore.instance;

  static Future<List<UniversityModel>> getUniversities() async {
    final universities = <UniversityModel>[];
    await db
        .collection("universities")
        .withConverter(
            fromFirestore: UniversityModel.fromFirestore,
            toFirestore: (m, _) => m.toFirestore())
        .get()
        .then(
      (value) {
        for (var university in value.docs) {
          universities.add(university.data());
        }
      },
    );
    return universities;
  }

  static Future<UserModel?> getUser() async {
    final userFromDatabase = await db
        .collection("/users")
        .withConverter(
            fromFirestore: UserModel.fromFirestore,
            toFirestore: (user, _) => user.toFirestore())
        .doc(Auth.auth.currentUser!.uid)
        .get()
        .then(
      (value) {
        return value.data();
      },
    );

    if (kDebugMode) print(userFromDatabase);

    if (userFromDatabase == null) {
      return null;
    } else {
      return userFromDatabase;
    }
  }

  static Future<List<String>> getUsernames() async {
    final usernames = <String>[]; // Initialize the list
    await db
        .collection("users")
        .withConverter(
            fromFirestore: UserModel.fromFirestore,
            toFirestore: (m, _) => m.toFirestore())
        .get()
        .then(
      (QuerySnapshot<UserModel> snap) {
        for (var docs in snap.docs) {
          usernames.add(docs.data().username!);
        }
      },
    );
    return usernames;
  }

  static Future<List<String>?> getDepartments() async {
    final schoolDepartments = <String>[];
    final schooldomain = Auth.auth.currentUser!.email?.split("@")[1];

    if (schooldomain == null) {
      return null;
    }

    final school = await db
        .collection("universities")
        .withConverter(
            fromFirestore: UniversityModel.fromFirestore,
            toFirestore: (mod, _) => mod.toFirestore())
        .where({"domain": schooldomain})
        .get()
        .then((value) => value.docs.first);
    await db
        .collection("departments")
        .where({"schoolId": school.id})
        .get()
        .then((value) {
          for (var doc in value.docs) {
            final document = DepartmentModel.fromFirestore(doc);
            schoolDepartments.add(document.name);
          }
        });
    return schoolDepartments;
  }

  // static Future submitFile(
  //   Uint8List fileBytes,
  //   String fileName,
  // ) async {
  //   // final storagePath = await Storage.addFile();

  //   await db
  //       .collection("notes")
  //       .withConverter(
  //           fromFirestore: NoteModel.fromFirestore,
  //           toFirestore: (model, __) => model.toFirestore())
  //       .add(NoteModel(name: fileName, storagePath: storagePath));
  // }
}

// class Storage {

//   static final storage = FirebaseStorage.instance;

//   static addFile()async {
//     await storage.
//   }

//   static getFile() {

//   }
// }
