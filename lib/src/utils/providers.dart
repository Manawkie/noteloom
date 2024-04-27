// get all school info on department and courses when the user is logged in

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/sharedprefs.dart';

class UniversityDataProvider extends ChangeNotifier {
  // data looks like this:
  // [{dep : [course, course, course], {dep: [course, course, course]}]
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

  List<String> _savedNoteIds = [];
  List<String> get readSavedNoteIds => _savedNoteIds;

  List<String> get readRecents => _userData?.recents ?? [];

  List<String> get readPrioritySubjects => _userData?.prioritySubjects ?? [];

  UserProvider() {
    if (_userData == null) {
      SharedPrefs.getUserData().then((data) {
        if (data != null) setUserData(data);
        if (data != null) setRecents(data.recents);

      });
      SharedPrefs.getSavedNotes().then((data) {
        setSavedNoteIds(data);
      });
    }
  }

  void setUserData(UserModel data) {
    _userData = data;
    SharedPrefs.setUserData(data);
    notifyListeners();
  }

  void setSavedNoteIds(List<String> newSavedNoteIds) {
    _savedNoteIds = newSavedNoteIds;
    print("Saved notes: $_savedNoteIds");
    SharedPrefs.setSavedNotes(newSavedNoteIds);
    notifyListeners();
  }

  void addSavedNoteId(String noteId) {
    if (!_savedNoteIds.contains(noteId)) {
      _savedNoteIds.add(noteId);
      SharedPrefs.setSavedNotes(_savedNoteIds);
      notifyListeners();
    }
  }

  void removeSavedNoteId(String noteId) {
    _savedNoteIds.remove(noteId);
    SharedPrefs.setSavedNotes(readSavedNoteIds);
    notifyListeners();
  }

  void setRecents(List<String> newRecents) async {
    _userData?.setRecents(newRecents);
    SharedPrefs.setRecents(newRecents);
    notifyListeners();
  }

  void addRecents(String recent) {
    if (!_userData!.recents.contains(recent)) {
      if (_userData!.recents.length >= 10) {
        _userData!.recents.removeAt(0);
      }
      _userData?.recents.add(recent);
      SharedPrefs.setRecents(readRecents);
      notifyListeners();
    }
  }

  void setPrioritySubjectIds(List<String> prioritySubjects) {
    _userData!.prioritySubjects = prioritySubjects;
    SharedPrefs.setPrioritySubjects(prioritySubjects);
    notifyListeners();
  }

  void addPrioritySubjectIds(String newPrioritySubject) {
    if (!_userData!.prioritySubjects!.contains(newPrioritySubject)) {
      _userData?.prioritySubjects?.add(newPrioritySubject);
      SharedPrefs.setPrioritySubjects(readPrioritySubjects);
      notifyListeners();
    }
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

  void requeryNotes(String searchResult, List<String> priorityIds) async {
    final newNotes = await Database.searchNotes(searchResult, priorityIds);
    universityNotes = {...newNotes, ...universityNotes}.toList();
    for (var note in universityNotes) {
      print(note.name);
    }
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
