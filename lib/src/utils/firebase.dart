import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:school_app/src/utils/cache.dart';

import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/sharedprefs.dart';

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

  static User? get currentUser => auth.currentUser;

  static String get schoolDomain => currentUser!.email!.split("@")[1];

  static final googleProvider = GoogleAuthProvider();

  static Future<void> googleSignIn() async {
    googleProvider.addScope("email");
    googleProvider.addScope("profile");

    late User? userCred;
    if (kIsWeb) {
      userCred =
          await auth.signInWithPopup(googleProvider).then((cred) => cred.user);
    } else {
      userCred = await auth
          .signInWithProvider(googleProvider)
          .then((cred) => cred.user);
    }

    try {
      isUserValid(userCred);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print(e.message);
    }
  }

  static Future<bool> isUserValid(User? user) async {
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
            toFirestore: (user, _) => user.toMap())
        .doc(Auth.auth.currentUser!.uid)
        .get()
        .then(
      (value) {
        return value.data();
      },
    );

    return userFromDatabase;
  }

  static Future<List<String>> getUsernames() async {
    final usernames = <String>[]; // Initialize the list
    await db
        .collection("users")
        .withConverter(
            fromFirestore: UserModel.fromFirestore,
            toFirestore: (model, _) => model.toMap())
        .get()
        .then(
      (QuerySnapshot<UserModel> snap) {
        for (var docs in snap.docs) {
          usernames.add(docs.data().username);
        }
      },
    );
    return usernames;
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

  static Future<void> createUser(
    String username,
    String? department,
    String? course,
  ) async {
    final user = UserModel(
      id: Auth.auth.currentUser!.uid,
      email: Auth.auth.currentUser!.email!,
      name: Auth.auth.currentUser!.displayName!,
      universityId: Auth.schoolDomain,
      username: username,
      department: department,
      course: course,
    );

    await db
        .collection("users")
        .withConverter(
            fromFirestore: UserModel.fromFirestore,
            toFirestore: (model, _) => model.toMap())
        .doc(user.id)
        .set(user);

    SharedPrefs.setUserData(user);
  }

  static Future<void> submitFile(
    Uint8List fileBytes,
    String fileName,
    String subject,
    List<String> tags,
    String? summary,
  ) async {
    final storagePath = await Storage.addFile(fileName, fileBytes);

    await db
        .collection("notes")
        .withConverter(
            fromFirestore: NoteModel.fromFirestore,
            toFirestore: (model, __) => model.toFirestore())
        .add(NoteModel(
          name: fileName,
          schoolId: Auth.schoolDomain,
          author:
              await SharedPrefs.getUserData().then((user) => user!.username),
          subjectId: subject,
          time: DateTime.now().toString(),
          storagePath: storagePath,
          tags: tags,
          summary: summary,
        ));
  }

  static Future<List<NoteModel>> getAllNotes() async {
    final allNotes = <NoteModel>[];

    await db
        .collection("notes")
        .withConverter(
            fromFirestore: NoteModel.fromFirestore,
            toFirestore: (model, _) => model.toFirestore())
        .get()
        .then((snapshot) {
      for (var note in snapshot.docs) {
        allNotes.add(note.data());
      }
    });

    return allNotes;
  }

  static Future saveNote(NoteModel note, bool saved) async {
    final saveData = SavedNoteModel(noteid: note.id!, date: DateTime.now());

    final userSaves = db
        .collection('users')
        .doc(Auth.currentUser!.uid)
        .collection("saved notes")
        .withConverter(
            fromFirestore: SavedNoteModel.fromFirestore,
            toFirestore: (model, _) => model.toFirestore());

    if (saved) {
      await userSaves.add(saveData);
    } else {
      await userSaves
          .where("noteid", isEqualTo: note.id)
          .get()
          .then((snap) async {
        final dataId = snap.docs.first.id;

        await userSaves.doc(dataId).delete();
      });
    }
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

  static Future<Stream> getLikes(NoteModel note) async {
    return db.collection('notes').doc(note.id).collection('likes').snapshots();
  }
}

class Storage {
  static final storage = FirebaseStorage.instance;

  static Future<String> addFile(
    String fileName,
    Uint8List fileBytes,
  ) async {
    final fileRef =
        storage.ref("notes/${Auth.auth.currentUser!.uid}/$fileName");

    if (await fileRef.getData() != null) {
      throw ErrorDescription("File already exists");
    }

    await fileRef.putData(
        fileBytes, SettableMetadata(contentType: "application/pdf"));
    return "notes/${Auth.auth.currentUser!.uid}/$fileName";
  }

  static Future<void> deleteFile(String storagePath) async {
    await Database.db
        .collection("notes")
        .where("storagePath", isEqualTo: storagePath)
        .get()
        .then((snapshot) {
      snapshot.docs.first.reference.delete();
    });
    await storage.refFromURL(storagePath).delete();
  }

  static Future<Uint8List> getFile(String storagePath) async {
    final Uint8List? cachedFile = await CachedData.getCachedFile(storagePath);

    if (cachedFile != null) {
      return cachedFile;
    }

    final noteRef = storage.ref(storagePath);
    final bytes = await noteRef.getData();

    if (bytes != null) {
      await CachedData.setCachedFile(storagePath, bytes);
    }

    return bytes!;
  }
}
