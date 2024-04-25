// get all school info on department and courses when the user is logged in

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/sharedprefs.dart';

class UniversityDataProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _departmentsAndCourses = [];
  List<Map<String, dynamic>> get readDepartmentsAndCourses =>
      _departmentsAndCourses;

  UniversityDataProvider() {
    if (_departmentsAndCourses.isEmpty) {
      SharedPrefs.getDepartmentAndCourses().then((data) {
        setDepartmentsAndCourses(data);
      });
    }
  }

  void setDepartmentsAndCourses(List<Map<String, dynamic>> data) {
    _departmentsAndCourses = data;
    notifyListeners();
  }
}

class UserProvider extends ChangeNotifier {
  UserModel? _userData;
  UserModel? get readUserData => _userData;

  List<SavedNoteModel> _savedNotes = [];
  List<SavedNoteModel> get readSavedNotes => _savedNotes;

  List<String> _savedNoteIds = [];
  List<String> get readSavedNoteIds => _savedNoteIds;

  List<String> _recents = [];
  List<String> get readRecents => _recents;

  List<String> _prioritySubjects = [];
  List<String> get readPrioritySubjects => _prioritySubjects;

  UserProvider() {
    if (_userData == null) {
      SharedPrefs.getUserData().then((data) {
        setUserData(data);
      });
    }
  }

  void setUserData(UserModel? data) {
    _userData = data;
    if (data != null) {
      SharedPrefs.getRecentNotes().then((recents) {
        setRecents(recents);
      });
    }
    notifyListeners();
  }

  void setSavedNotes(List<SavedNoteModel> data) {
    _savedNotes = data;
    notifyListeners();
  }

  void setSavedNoteIds(List<String> data) {
    _savedNoteIds = data;
    notifyListeners();
  }

  void setRecents(List<String> newRecents) {
    print('set recents: ' + newRecents.toString());
    _recents = newRecents;
    SharedPrefs.setRecents(_recents);
    notifyListeners();
  }

  void setPrioritySubjects(List<String> prioritySubjects) {
    _prioritySubjects = prioritySubjects;
    notifyListeners();
  }
}

class NoteProvider extends ChangeNotifier {
  // get my notes and then set it as the value of the notes

  FilePickerResult? _result;
  Uint8List? bytes;
  String? name;
  String? summary;
  String? subject;
  String? tag1;
  String? tag2;
  String? tag3;

  FilePickerResult? get readResult => _result;
  Uint8List? get readBytes => bytes;
  String? get readName => name;
  String? get readSummary => summary;
  String? get readSubject => subject;
  String? get readTag1 => tag1;
  String? get readTag2 => tag2;
  String? get readTag3 => tag3;

  void setName(String value) {
    name = value;
    notifyListeners();
  }

  void setResult(
      FilePickerResult? result,
      String filename,
      String fileSummary,
      String fileSubject,
      String fileTags1,
      String fileTags2,
      String fileTags3) {
    _result = result;
    bytes = result?.files.single.bytes!;
    name = filename;
    summary = fileSummary;
    subject = fileSubject;
    tag1 = fileTags1;
    tag2 = fileTags2;
    tag3 = fileTags3;
    notifyListeners();
  }

  void setSubject(String subject) {
    this.subject = subject;
    notifyListeners();
  }

  void setSummary(String value) {
    summary = value;
    notifyListeners();
  }

  void removeFile() {
    if (bytes != null) {
      bytes = null;
      name = null;
      _result = null;
      notifyListeners();
    }
  }

  void clearFields() {
    _result = null;
    bytes = null;
    name = "";
    subject = "Select a Subject";
    summary = "";
    tag1 = "";
    tag2 = "";
    tag3 = "";
    notifyListeners();
  }
}

class CurrentNoteProvider extends ChangeNotifier {
  String? name;
  String? summary;

  String? newSubject;
  String? subject;
  String? tag1;
  String? tag2;
  String? tag3;

  bool editing = false;

  String? get readName => name;
  String? get readSummary => summary;

  String? get readNewSubject => newSubject;
  String? get readSubject => subject;
  String? get readTag1 => tag1;
  String? get readTag2 => tag2;
  String? get readTag3 => tag3;
  bool get readEditing => editing;

  void setEditing(bool value) {
    editing = value;
    notifyListeners();
  }

  void setNote(
    String notename,
    String notesubject, {
    String? notesummary,
    String? notetag1,
    String? notetag2,
    String? notetag3,
  }) {
    name = notename;
    summary = notesummary;
    subject = notesubject;
    tag1 = notetag1;
    tag2 = notetag2;
    tag3 = notetag3;

    notifyListeners();
  }

  void setNewSubject(String value) {
    newSubject = value;
    notifyListeners();
  }

  void setSubject(String value) {
    subject = value;
    notifyListeners();
  }
}

class QueryNotesProvider extends ChangeNotifier {
  List<NoteModel> universityNotes = [];
  List<SubjectModel> universitySubjects = [];

  List<NoteModel> get getUniversityNotes => universityNotes;
  List<SubjectModel> get getUniversitySubjects => universitySubjects;

  QueryNotesProvider() {
    if (universityNotes.isEmpty) {
      Database.getAllNotes().then(
        (data) => setUniversityNotes(
          data.cast<NoteModel>(),
        ),
      );
    }

    if (universitySubjects.isEmpty) {
      Database.getAllSubjects().then(
        (data) => setAllSubjects(
          data.cast<SubjectModel>(),
        ),
      );
    }
  }

  void setUniversityNotes(List<NoteModel> data) {
    universityNotes = data;
    notifyListeners();
  }

  void setAllSubjects(List<SubjectModel> data) {
    universitySubjects = data;
    notifyListeners();
  }

  NoteModel? findNote(String id) {
    return universityNotes.where((note) => note.id == id).firstOrNull;
  }

  void editNote(NoteModel note) {
    final existingNoteIndex =
        universityNotes.indexWhere((element) => element.id == note.id);
    universityNotes[existingNoteIndex] = note;

    notifyListeners();
  }

  List<NoteModel> getNotesBySubject(String subjectId) {
    return universityNotes
        .where((note) => note.subjectId == subjectId)
        .toList();
  }

  void deleteNote(NoteModel note) {
    universityNotes.removeWhere((element) => element.id == note.id);
    notifyListeners();
  }

  SubjectModel? findSubject(String id) {
    return universitySubjects.where((subject) => subject.id == id).firstOrNull;
  }
}
