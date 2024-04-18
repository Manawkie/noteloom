import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
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

  static Future<UserModel?> setUserData(UserModel? user) async {
    final sf = await SharedPreferences.getInstance();
    if (user != null) {
      sf.setString("userData", jsonEncode(user.toMap()));
      return user;
    }

    sf.setString("userData", "");
    return null;
  }

  static Future<List<String>> getSavedNotes() async {
    final sf = await SharedPreferences.getInstance();
    final savedNotes = sf.getString("savedNotes");

    if (savedNotes == null) {
      final dbSavedNotes = await Database.getAllSavedNotes();

      final savedNoteIds = <String>[];
      for (var savedNote in dbSavedNotes) {
        savedNoteIds.add(savedNote.id!);
      }
      return savedNoteIds;
    }

    final List decodedData = jsonDecode(savedNotes);
    return decodedData.cast<String>();
  }

  static Future<void> setSavedNotes(List<String> notes) async {
    final sf = await SharedPreferences.getInstance();
    sf.setString("savedNotes", jsonEncode(notes));
  }

  static Future<bool> isNoteSaved(NoteModel note) async {
    final notesList = await getSavedNotes();
    if (notesList.contains(note.id)) {
      return true;
    } else {
      return false;
    }
  }

  static Future<List<String>> addLikedNote(NoteModel note, bool isSaved) async {
    final notesList = await getSavedNotes();

    if (!await isNoteSaved(note)) {
      notesList.add(note.id!);
    }

    if (!isSaved) {
      notesList.remove(note.id!);
    }

    setSavedNotes(notesList);
    return await getSavedNotes();
  }
}
