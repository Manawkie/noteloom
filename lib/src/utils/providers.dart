// get all school info on department and courses when the user is logged in

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/sharedprefs.dart';

class UniversityDataProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _departmentsAndCourses = [];
  List<Map<String, dynamic>> get readDepartmentsAndCourses =>
      _departmentsAndCourses;

  List<Map<String, dynamic>> _userSubjects = [];
  List<Map<String, dynamic>> get readUserSubjects => _userSubjects;

  UniversityDataProvider() {
    SharedPrefs.getDepartmentAndCourses().then((data) {
      setDepartmentsAndCourses(data);
    });
    SharedPrefs.getSubjects().then((data) => setUserSubjects(data));
  }

  void setDepartmentsAndCourses(List<Map<String, dynamic>> data) {
    _departmentsAndCourses = data;
    notifyListeners();
  }

  void setUserSubjects(List<Map<String, dynamic>> data) {
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
      FilePickerResult result,
      String filename,
      String fileSummary,
      String fileSubject,
      String fileTags1,
      String fileTags2,
      String fileTags3) {
    _result = result;
    bytes = result.files.single.bytes!;
    name = filename;
    summary = fileSummary;
    subject = fileSubject;
    tag1 = fileTags1;
    tag2 = fileTags2;
    tag3 = fileTags3;
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
}
