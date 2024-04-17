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

  List<Map<String, dynamic>> _userSubjects = [];
  List<Map<String, dynamic>> get readSubjects => _userSubjects;

  UniversityDataProvider() {
    SharedPrefs.getDepartmentAndCourses().then((data) {
      setDepartmentsAndCourses(data);
    });
    SharedPrefs.getSubjects().then((data) => setSubjects(data));
  }

  void setDepartmentsAndCourses(List<Map<String, dynamic>> data) {
    _departmentsAndCourses = data;
    notifyListeners();
  }

  void setSubjects(List<Map<String, dynamic>> data) {
    _userSubjects = data;
    notifyListeners();
  }
}

class UserProvider extends ChangeNotifier {
  UserModel? _userData;

  UserModel? get readUserData => _userData;

  UserProvider() {
    if (kDebugMode) print("Reading user data");
    SharedPrefs.getUserData().then((data) => setUserData(data));
  }

  void setUserData(UserModel? data) {
    _userData = data;
    notifyListeners();
  }
}

class NotesProvider extends ChangeNotifier {
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

class QueryNotesProvider extends ChangeNotifier {
  List<NoteModel> universityNotes = [];
  List<SubjectModel> universitySubjects = [];

  List<NoteModel> get getUniversityNotes => universityNotes;
  List<SubjectModel> get getUniversitySubjects => universitySubjects;

  QueryNotesProvider() {
    Database.getAllNotes().then(
      (data) => setNotes(
        data.cast<NoteModel>(),
      ),
    );

    Database.getAllSubjects().then(
      (data) => setSubjects(
        data.cast<SubjectModel>(),
      ),
    );
  }

  void setNotes(List<NoteModel> data) {
    universityNotes = data;
    notifyListeners();
  }

  void setSubjects(List<SubjectModel> data) {
    universitySubjects = data;
    notifyListeners();
  }

  NoteModel? findNote(String id) {
    return universityNotes.firstWhere((note) => note.id == id);
  }

  SubjectModel? findSubject(String id) {
    return universitySubjects.firstWhere((subject) => subject.id == id);
  }
}
