import 'dart:convert';

import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {

  // ==== deps and courses to [{dep: [course, course, ...], dep: [course, course, ...]}]
  static Future<List<Map<String, dynamic>>> getDepartmentAndCourses() async {
    final sf = await SharedPreferences.getInstance();

    final data = sf.getString("depsAndCourses");

    if (data == null) {
      final databaseData = await Database.getDepartmentsAndCourses();
      setDepartmentAndCourses(databaseData);
      return databaseData;
    }
    final List<dynamic> decodedData = jsonDecode(data);

    return decodedData.cast<Map<String, dynamic>>();
  }

  static Future<void> setDepartmentAndCourses(
      List<Map<String, List<String>>> list) async {
    final sf = await SharedPreferences.getInstance();
    sf.setString("depsAndCourses", jsonEncode(list));
  }

  // ==== user data

  static Future<UserModel?> getUserData() async {
    final sf = await SharedPreferences.getInstance();
    final userData = sf.getString("userData");

    if (userData == null) {
      final user = await Database.getUser();
      if (user == null) {
        return null;
      }
      return await setUserData(user);
    }

    final Map<String, dynamic> decodedData = jsonDecode(userData);
    return UserModel.fromMap(decodedData);
  }

  static Future<UserModel?> setUserData(UserModel user) async {
    final sf = await SharedPreferences.getInstance();
    sf.setString("userData", jsonEncode(user.toFirestore()));
    return user;
  }

  // ==== notes

  static Future<List<String>> getSavedNotes() async {
    final sf = await SharedPreferences.getInstance();
    final savedNotes = sf.getString("savedNotes");

    if (savedNotes == null) {
      final dbSavedNotes = await Database.getAllSavedNotes();

      final savedNoteIds = <String>[];
      for (var savedNote in dbSavedNotes) {
        savedNoteIds.add(savedNote.id!);
      }
      setSavedNotes(savedNoteIds);
      return savedNoteIds;
    }

    final List<dynamic> decodedData = jsonDecode(savedNotes);
    return decodedData.cast<String>();
  }

  static Future<void> setSavedNotes(List<String> notes) async {
    final sf = await SharedPreferences.getInstance();
    sf.setString("savedNotes", jsonEncode(notes));
  }


  static Future<List<String>> addSavedNote(NoteModel note, bool isSaved) async {
    final notesList = await getSavedNotes();

    if (isSaved) {
      notesList.add(note.id!);
    } else {
      notesList.remove(note.id!);
    }

    setSavedNotes(notesList);
    return await getSavedNotes();
  }

  // recent notes and subjects

  static Future<List<String>> getRecentNotes() async {
    final userNotes =
        await getUserData().then((user) => user?.recents ?? <String>[]);
    return userNotes;
  }

  static Future<void> setRecents(List<String> notes) async {
    final userData = await getUserData();
    userData?.recents = notes;
    setUserData(userData!);
  }

  // ========= subjects

  static Future<List<String>> getSavedSubjects() async {
    final savedSubjects = await getUserData()
        .then((userData) => userData?.prioritySubjects ?? <String>[]);

    return savedSubjects;
  }

  static Future<bool> isSubjectSaved(String subjectId) async {
    final userData = await getUserData();
    return userData?.prioritySubjects?.contains(subjectId) ?? false;
  }

  static Future<List<String>?> getPrioritySubjects() async {
    final sf = await SharedPreferences.getInstance();
    final prioritySubjects = sf.getString("prioritySubjects");

    if (prioritySubjects == null) {
      final user = await getUserData();
      final List<String>? savedPrioritySubjects = user!.prioritySubjects;
      setPrioritySubjects(savedPrioritySubjects ?? []);
      return savedPrioritySubjects;
    }

    final List<String> decodedData =
        jsonDecode(prioritySubjects).cast<String>();
    return decodedData;
  }

  static Future<List<String>?> setPrioritySubjects(
      List<String> subjects) async {
    final sf = await SharedPreferences.getInstance();
    sf.setString("savedSubjects", jsonEncode(subjects));
    return subjects;
  }
}
