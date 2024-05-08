// get all school info on department and courses when the user is logged in

// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:cloud_firestore/cloud_firestore.dart';
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

  List<String> get userSavedNotesAndSubjects {
    List<String> userNotes = [];

    for (var recent in readRecents) {
      if (recent.startsWith("note")) {
        userNotes.add(recent.split("/")[1]);
      }
    }
    userNotes.addAll({...readSavedNoteIds, ...readPrioritySubjects}.toList());
    return userNotes;
  }

  UserProvider() {

    if (_userData == null) {
      SharedPrefs.getUserData().then((data) {
        if (data != null) {
          setUserData(data);
          setPrioritySubjectIds(data.prioritySubjects ?? []);
        }
      });
      SharedPrefs.getSavedNotes().then((data) {
        setSavedNoteIds(data);
      });
    }
  }

  void setUserData(UserModel? data) {
    _userData = data;
    SharedPrefs.setUserData(data);
    notifyListeners();
  }

  void setSavedNoteIds(List<String> newSavedNoteIds) {
    _savedNoteIds = newSavedNoteIds;
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
    _userData!.setRecents(newRecents);
    SharedPrefs.setRecents(newRecents);
    notifyListeners();
  }

  void addRecents(String recent) {
    if (_userData == null) return;
    if (!_userData!.recents.contains(recent)) {
      if (_userData!.recents.length >= 10) {
        _userData!.recents.removeAt(0);
      }
      _userData?.recents.add(recent);
      SharedPrefs.setRecents(readRecents);
    }
    notifyListeners();
  }

  void setPrioritySubjectIds(List<String> prioritySubjects) {
    _userData?.setPrioritySubjects(prioritySubjects);
    SharedPrefs.setPrioritySubjects(prioritySubjects);
    notifyListeners();
  }

  void addPrioritySubjectId(String newPrioritySubject) {
    if (!_userData!.prioritySubjects!.contains(newPrioritySubject)) {
      _userData?.prioritySubjects?.add(newPrioritySubject);
      SharedPrefs.setPrioritySubjects(readPrioritySubjects);
    }
    notifyListeners();
  }

  void removePrioritySubjectId(String prioritySubjectId) {
    _userData!.prioritySubjects?.remove(prioritySubjectId);
    SharedPrefs.setPrioritySubjects(readPrioritySubjects);

    notifyListeners();
  }
}

class NoteProvider extends ChangeNotifier {
  // get my notes and then set it as the value of the notes

  FilePickerResult? _result;
  Uint8List? bytes;
  String? name;
  String? summary;
  String? subjectName;
  String? subjectId;
  List<String>? tags;
  

  FilePickerResult? get readResult => _result;
  Uint8List? get readBytes => bytes;
  String? get readName => name;
  String? get readSummary => summary;
  String? get readSubjectName => subjectName;
  String? get readSubjectId => subjectId;
  List<String>? get readTags => tags;
  

  void setName(String value) {
    name = value;
    notifyListeners();
  }

  void setResult(
      FilePickerResult? result,
      String filename,
      String fileSummary,
      String fileSubjectName,
      String fileSubjectId,
      List<String> fileTags,
      ) {
    _result = result;
    bytes = result?.files.single.bytes!;
    name = filename;
    summary = fileSummary;
    subjectName = fileSubjectName;
    subjectId = fileSubjectId;
    tags = fileTags;
    
    notifyListeners();
  }

  void setSubject(String newSubjectId, String newSubjectName) {
    subjectId = newSubjectId;
    subjectName = newSubjectName;
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
    subjectName = "Select a Subject";
    subjectId = "";
    summary = "";
    tags = [];
    
    notifyListeners();
  }
}

class CurrentNoteProvider extends ChangeNotifier {
  String? name;
  String? summary;
  String? newSubjectName;
  String? newSubjectId;
  String? subjectName;
  String? subjectId;
  String? tag1;
  

  bool editing = false;

  String? get readName => name;
  String? get readSummary => summary;

  String? get readNewSubjectName => newSubjectName;
  String? get readNewSubjectId => newSubjectId;
  String? get readSubjectId => subjectId;
  String? get readSubjectName => subjectName;
  String? get readTag1 => tag1;
  
  bool get readEditing => editing;

  void setEditing(bool value) {
    editing = value;
    notifyListeners();
  }

  void setNote(
    String notename,
    String noteSubjectName,
    String noteSubjectId, {
    String? notesummary,
    String? notetag1,
    
  }) {
    name = notename;
    summary = notesummary;
    subjectName = noteSubjectName;
    subjectId = noteSubjectId;
    tag1 = notetag1;
    

    notifyListeners();
  }

  void setNewSubject(String subjectId, String subjectName) {
    newSubjectId = subjectId;
    newSubjectName = subjectName;
    notifyListeners();
  }

  void setSubject(String id, String name) {
    subjectId = id;  
    subjectName = name;
    notifyListeners();
  }
}

class QueryNotesProvider extends ChangeNotifier {
  final streamNotes = Database.getNotesStream();
  final streamSubjects = Database.getSubjectsStream();

  List<NoteModel> _universityNotes = [];
  List<SubjectModel> _universitySubjects = [];

  List<NoteModel> get getUniversityNotes => _universityNotes;
  List<SubjectModel> get getUniversitySubjects => _universitySubjects;

  Stream get readNotesStream => streamNotes;
  Stream<QuerySnapshot<SubjectModel>> get readSubjectsStream => streamSubjects;

  QueryNotesProvider() {
    streamNotes.listen((snap) {
      setUniversityNotes(snap.docs.map((note) => note.data()).toList());
    });
    streamSubjects.listen((snap) {
      setUniversitySubjects(
          snap.docs.map((subject) => subject.data()).toList());
    });
  }

  void setUniversityNotes(List<NoteModel> data) {
    _universityNotes = data;
    notifyListeners();
  }

  void setUniversitySubjects(List<SubjectModel> data) {
    _universitySubjects = data;
    notifyListeners();
  }

  NoteModel? findNote(String id) {
    return _universityNotes.where((note) => note.id == id).firstOrNull;
  }

  void editNote(NoteModel note) {
    final existingNoteIndex =
        _universityNotes.indexWhere((element) => element.id == note.id);
    _universityNotes[existingNoteIndex] = note;
    notifyListeners();
  }

  List<NoteModel> getNotesBySubject(String subjectId) {
    
    return _universityNotes
        .where((note) => note.subjectId == subjectId)
        .toList();
  }

  void deleteNote(NoteModel note) {
    _universityNotes.removeWhere((element) => element.id == note.id);
    notifyListeners();
  }

  SubjectModel? findSubject(String id) {
    return _universitySubjects.where((subject) => subject.id == id).firstOrNull;
  }
}

class MessageProvider extends ChangeNotifier {
  String message = "";
  String? noteId;
  String? currentSubjectId;

  String get readMessage => message;
  String? get readNoteId => noteId;
  String? get readCurrentSubjectId => currentSubjectId;

  void setMessage(String newMessage) {
    message = newMessage;
    notifyListeners();
  }

  void setNoteId(String? newNoteId) {
    noteId = newNoteId;
    notifyListeners();
  }

  void setCurrentNoteId(String? newSubjectId) {
    currentSubjectId = newSubjectId;
    notifyListeners();
  }

  void clearFields() {
    message = "";
    noteId = null;
    notifyListeners();
  }
}
