import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart' as googleauth;
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/sharedprefs.dart';

class Auth {
  static final auth = FirebaseAuth.instance;

  static User? get currentUser => auth.currentUser;

  static String get schoolDomain => currentUser!.email!.split("@")[1];

  static final GoogleAuthProvider googleProvider = GoogleAuthProvider();
  static final googleSignIn = googleauth.GoogleSignIn();

  static Future<void> signIn() async {
    late User? userCred;
    if (kIsWeb) {
      userCred =
          await auth.signInWithPopup(googleProvider).then((cred) => cred.user);
    } else {
      final googleauth.GoogleSignInAccount? googleUser =
          await googleSignIn.signIn();

      final googleauth.GoogleSignInAuthentication? googleUserAuth =
          await googleUser?.authentication;

      final cred = GoogleAuthProvider.credential(
        accessToken: googleUserAuth?.accessToken,
        idToken: googleUserAuth?.idToken,
      );

      userCred = await auth
          .signInWithCredential(cred)
          .then((usercred) => usercred.user);
    }

    try {
      isUserValid(userCred);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print(e.message);
    }
  }

  static Future<bool> isUserValid(User? user) async {
    // check if the user is a student of any of the universities
    final schoolDomains = await Database.getUniversities().then((value) => value
        .map(
          (data) => data.id,
        )
        .toList());
    if (schoolDomains.contains(Auth.schoolDomain)) {
      return true;
    } else {
      return false;
    }
  }

  static Future<void> signOut() async {
    await googleSignIn.signOut();
    await auth.signOut();
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

    return userFromDatabase;
  }

  static Future<bool> isUsernameTaken(String username) async {
    return await db
        .collection("users")
        .withConverter(
            fromFirestore: UserModel.fromFirestore,
            toFirestore: (model, _) => model.toFirestore())
        .where("username", isEqualTo: username)
        .get()
        .then(
      (QuerySnapshot<UserModel> snap) {
        return snap.docs.firstOrNull?.data().username == username;
      },
    );
  }

  static Future<List<DepartmentModel>> getDepartments() async {
    final schoolDepartments = <DepartmentModel>[];
    final schooldomain = Auth.schoolDomain;

    await db
        .collection("universities")
        .doc(schooldomain)
        .collection("departments")
        .withConverter(
            fromFirestore: DepartmentModel.fromFirestore,
            toFirestore: (model, _) => model.toFirestore())
        .get()
        .then((snapshot) {
      for (var department in snapshot.docs) {
        schoolDepartments.add(department.data());
      }
    });

    return schoolDepartments;
  }

  static Future<List<CourseModel>> getCourses() async {
    final courses = <CourseModel>[];
    final schooldomain = Auth.schoolDomain;

    final departments = await getDepartments();

    for (var department in departments) {
      await db
          .collection("universities")
          .doc(schooldomain)
          .collection("departments")
          .doc(department.id)
          .collection("courses")
          .withConverter(
              fromFirestore: CourseModel.fromFirestore,
              toFirestore: (model, _) => model.toFirestore())
          .get()
          .then((snapshot) {
        for (var course in snapshot.docs) {
          courses.add(course.data());
        }
      });
    }

    return courses;
  }

  static Future<List<Map<String, List<String>>>>
      getDepartmentsAndCourses() async {
    List<Map<String, List<String>>> listDepartmentAndCourses = [];
    final departments = await getDepartments();

    for (var department in departments) {
      final List<String> courses = await Database.db
          .collection("universities")
          .doc(Auth.schoolDomain)
          .collection("departments")
          .doc(department.id)
          .collection("courses")
          .withConverter(
              fromFirestore: CourseModel.fromFirestore,
              toFirestore: (model, _) => model.toFirestore())
          .get()
          .then((snapshot) =>
              snapshot.docs.map((course) => course.data().name).toList());
      listDepartmentAndCourses.add({department.name: courses});
    }

    return listDepartmentAndCourses;
  }

  static Future<List<SubjectModel>> getAllSubjects() async {
    final subjects = <SubjectModel>[];
    await db
        .collection("subjects")
        .withConverter(
            fromFirestore: SubjectModel.fromFirestore,
            toFirestore: (model, _) => model.toFirestore())
        .get()
        .then((snapshot) {
      for (var subject in snapshot.docs) {
        subjects.add(subject.data());
      }
    });

    return subjects;
  }

  static Future<UserModel> createUser(
    String username,
    String? department,
    String? course,
    List<String> recents,
    List<String> prioritySubjects,
  ) async {
    final user = UserModel(
        id: Auth.auth.currentUser!.uid,
        email: Auth.auth.currentUser!.email!,
        name: Auth.auth.currentUser!.displayName!,
        universityId: Auth.schoolDomain,
        username: username,
        department: department,
        course: course,
        recents: recents,
        prioritySubjects: prioritySubjects);

    await db
        .collection("users")
        .withConverter(
            fromFirestore: UserModel.fromFirestore,
            toFirestore: (model, _) => model.toFirestore())
        .doc(user.id)
        .set(user);

    return user;
  }

  static Future<NoteModel> submitFile(
    Uint8List fileBytes,
    String fileName,
    String subjectId,
    String subjectName,
    List<String> tags,
    String? summary,
  ) async {
    final storagePath = await Storage.addFile(fileName, fileBytes);
    final newNote = NoteModel(
      name: fileName,
      schoolId: Auth.schoolDomain,
      author: await SharedPrefs.getUserData().then((user) => user!.username),
      subjectId: subjectId,
      subjectName: subjectName,
      time: DateTime.now().toString(),
      storagePath: storagePath,
      tags: tags,
      summary: summary,
    );

    await db
        .collection("notes")
        .withConverter(
            fromFirestore: NoteModel.fromFirestore,
            toFirestore: (model, __) => model.toFirestore())
        .add(newNote);

    return newNote;
  }

  static Future<List<String>> addRecents(String resultpath) async {
    final user = db
        .collection('users')
        .withConverter(
          fromFirestore: UserModel.fromFirestore,
          toFirestore: (model, _) => model.toFirestore(),
        )
        .doc(Auth.currentUser!.uid);

    final recents = await user.get().then((snap) => snap.data()?.recents) ?? [];
    if (recents.length >= 10) {
      recents.removeAt(0);
    }
    if (!recents.contains(resultpath)) {
      recents.add(resultpath);
      user.update({"recents": recents});
    }

    return recents;
  }

  // notes

  static Stream<QuerySnapshot<NoteModel>> getNotesStream() {
    return db
        .collection("notes")
        .withConverter(
          fromFirestore: NoteModel.fromFirestore,
          toFirestore: (model, _) => model.toFirestore(),
        )
        .limit(100)
        .orderBy("time", descending: true)
        .snapshots();
  }

  static Future<NoteModel?> getNoteById(String noteId) async {
    final note = await db
        .collection("notes")
        .doc(noteId)
        .withConverter(
            fromFirestore: NoteModel.fromFirestore,
            toFirestore: (model, _) => model.toFirestore())
        .get()
        .then((snapshot) => snapshot.data());

    return note;
  }

  static Future saveNote(NoteModel note, bool saved) async {
    final saveData = SavedNoteModel(
      noteid: note.id!,
      date: DateTime.now(),
    );

    final userSaves = db
        .collection('users')
        .doc(Auth.currentUser!.uid)
        .collection("saved notes")
        .withConverter(
            fromFirestore: SavedNoteModel.fromFirestore,
            toFirestore: (model, _) => model.toFirestore());
    if (kDebugMode) {
      print("saving note");
    }
    if (saved) {
      if (!await isNoteSaved(note)) {
        await userSaves.add(saveData);
      }
    } else {
      final getSavedNoteData =
          await userSaves.where("noteid", isEqualTo: note.id).get();
      final dataIds = getSavedNoteData.docs;
      if (dataIds.isNotEmpty) {
        await userSaves.doc(dataIds.first.id).delete();
      }
    }
  }

  static Future<void> editNote(NoteModel note, String userName) async {
    note.author = userName;
    await db
        .collection("notes")
        .withConverter(
            fromFirestore: NoteModel.fromFirestore,
            toFirestore: (model, _) => model.toFirestore())
        .doc(note.id)
        .update(note.toFirestore());
  }

  static Future<void> deleteNote(NoteModel note) async {
    await Storage.deleteFile(note.storagePath);
    await db.collection("notes").doc(note.id).delete();
  }

  // saved notes

  static Future<List<SavedNoteModel>> getAllSavedNotes() async {
    final savedNoteIds = <SavedNoteModel>[];

    if (kDebugMode) print("Getting saved notes");
    await db
        .collection('users')
        .doc(Auth.currentUser!.uid)
        .collection("saved notes")
        .withConverter(
            fromFirestore: SavedNoteModel.fromFirestore,
            toFirestore: (model, _) => model.toFirestore())
        .get()
        .then(
      (snapshot) {
        if (snapshot.docs.isEmpty) {
          return savedNoteIds;
        }
        for (var note in snapshot.docs) {
          savedNoteIds.add(
            note.data(),
          );
        }
      },
    );

    return savedNoteIds;
  }

  static Future<bool> isNoteSaved(NoteModel note) async {
    final getNoteData = await db
        .collection('users')
        .doc(Auth.currentUser!.uid)
        .collection("saved notes")
        .withConverter(
            fromFirestore: SavedNoteModel.fromFirestore,
            toFirestore: (model, _) => model.toFirestore())
        .where("noteid", isEqualTo: note.id)
        .get();

    if (getNoteData.docs.isEmpty) {
      return false;
    }

    return true;
  }

  // like

  static Stream<DocumentSnapshot<NoteModel>> noteStream(NoteModel note) {
    final streamNote = db
        .collection('notes')
        .withConverter(
            fromFirestore: NoteModel.fromFirestore,
            toFirestore: (model, _) => model.toFirestore())
        .doc(note.id)
        .snapshots();

    return streamNote;
  }

  static Future<void> likeNote(NoteModel note, bool isLiked) async {
    final dbNote = db
        .collection('notes')
        .withConverter(
            fromFirestore: NoteModel.fromFirestore,
            toFirestore: (model, _) => model.toFirestore())
        .doc(note.id);

    await db.runTransaction((transaction) async {
      final noteSnap = await transaction.get(dbNote);

      final peopleLiked = noteSnap.data()!.peopleLiked ?? [];
      if (isLiked) {
        peopleLiked.add(Auth.auth.currentUser!.uid);
      } else {
        peopleLiked.remove(Auth.auth.currentUser!.uid);
      }

      transaction.update(dbNote, {"peopleLiked": peopleLiked});
    });
  }

  static Future editUserNotes(String oldUsername, String username) async {
    final userNotes =
        db.collection("notes").where("author", isEqualTo: oldUsername);

    final batch = db.batch();
    await userNotes.get().then((snapshot) {
      for (var note in snapshot.docs) {
        batch.update(note.reference, {"author": username});
      }
    });
    batch.commit();
  }

  // subjects

  static Stream<QuerySnapshot<SubjectModel>> getSubjectsStream() {
    return db
        .collection("subjects")
        .withConverter(
            fromFirestore: SubjectModel.fromFirestore,
            toFirestore: (model, _) => model.toFirestore())
        .snapshots();
  }

  static Future<SubjectModel?> addSubject(String subjectName,
      String subjectCode, List<SubjectModel> currentSubjectList) async {
    if (currentSubjectList.any(
          (subj) => subj.subject.toLowerCase() == subjectName.toLowerCase(),
        ) ||
        currentSubjectList.any(
          (subj) => subj.subjectCode.toLowerCase() == subjectCode.toLowerCase(),
        )) {
      throw ErrorDescription("Subject already exists");
    }

    final newSubject = SubjectModel(
        subject: subjectName,
        subjectCode: subjectCode,
        universityId: Auth.schoolDomain);

    final submittedSubject = await db
        .collection("subjects")
        .withConverter(
            fromFirestore: SubjectModel.fromFirestore,
            toFirestore: (model, _) => model.toFirestore())
        .add(newSubject)
        .then((subject) {
      newSubject.id = subject.id;
      return newSubject;
    });

    return submittedSubject;
  }

  static Future<List<String>> setPrioritySubejctIds(
      String subjectId, bool isSaved) async {
    final DocumentReference<UserModel> user = db
        .collection("users")
        .withConverter(
            fromFirestore: UserModel.fromFirestore,
            toFirestore: (model, _) => model.toFirestore())
        .doc(Auth.currentUser!.uid);

    final prioritySubjectIds =
        await user.get().then((snap) => snap.data()?.prioritySubjects) ?? [];

    if (isSaved) {
      prioritySubjectIds.insert(0, subjectId);
    } else {
      prioritySubjectIds
          .removeWhere((prioritizedSubject) => prioritizedSubject == subjectId);
    }

    user.update({"prioritySubjects": prioritySubjectIds});

    return prioritySubjectIds;
  }

  static Future editMessageUsername(
      Stream<QuerySnapshot<SubjectModel>> subjects, String newUsername) async {
     final batch = db.batch();

  // Fetch all subjects at once using a future
  final snapSubjects = await subjects.first;

  if (snapSubjects.docs.isEmpty) {
    if (kDebugMode) print('No subjects found. Skipping username update.');
    return; // Early exit if no subjects
  }

  // Efficiently iterate through each subject and its messages
  for (var subjectDoc in snapSubjects.docs) {
    final subjectId = subjectDoc.id;
    final discussionRef = db
        .collection('subjects')
        .doc(subjectId)
        .collection('discussion')
        .withConverter(
          fromFirestore: MessageModel.fromFirestore,
          toFirestore: (model, _) => model.toFirestore(),
        );

    // Stream-based approach for efficient listener handling
    discussionRef
        .where('authorId', isEqualTo: Auth.currentUser!.uid)
        .snapshots()
        .listen((messageSnap) {
      for (var messageDoc in messageSnap.docs) {
        batch.update(messageDoc.reference, {'author': newUsername});
      }
    });
  }

  await batch.commit().then((_) {
    if (kDebugMode) {
      print('Batch write successful!');
    }
  }).catchError((error) {
    if (kDebugMode) {
      print('Error updating message usernames: $error');
    }
  });
  }
}

class Storage {
  static final storage = FirebaseStorage.instance;
  static Reference get ref => storage.ref();

  static Future<String> addFile(
    String fileName,
    Uint8List fileBytes,
  ) async {
    final fileRef = ref.child("notes/${Auth.auth.currentUser!.uid}/$fileName");

    try {
      final FullMetadata metadata = await fileRef.getMetadata();
      if (metadata.size == fileBytes.length) {
        throw ErrorDescription("File already exists");
      }
    } catch (e) {
      await fileRef.putData(
          fileBytes, SettableMetadata(contentType: "application/pdf"));
    }
    return 'notes/${Auth.auth.currentUser!.uid}/$fileName';
  }

  static Future<void> deleteFile(String storagePath) async {
    await storage.ref(storagePath).delete();
  }

  static Future<Uint8List> getFile(String storagePath) async {
    final noteRef = storage.ref(storagePath);
    final bytes = await noteRef.getData();
    return bytes!;
  }
}
