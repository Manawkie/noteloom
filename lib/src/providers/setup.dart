// get all school info on department and courses when the user is logged in

import 'package:flutter/foundation.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/sharedprefs.dart';

class SetUpProvider extends ChangeNotifier {
  final List<String> _schoolYears = [
    "School Year",
    "2023-2024",
    "2024-2025",
    "2026-2027",
    "2027-2028",
    "2028-2029",
    "2029-2030"
  ];

  List<String> get readSchoolYears => _schoolYears;

  List<Map<String, dynamic>> _departmentsAndCourses = [];

  List<Map<String, dynamic>> get readDepartmentsAndCourses =>
      _departmentsAndCourses;

  SetUpProvider() {
    SharedPrefs.getDepartmentAndCourses().then((data) {
      setDepartmentsAndCourses(data);
    });
  }

  void setDepartmentsAndCourses(List<Map<String, dynamic>> data) {
    _departmentsAndCourses = data;
    notifyListeners();
  }
}

class UserProvider extends ChangeNotifier {
  UserModel? _userData;

  UserModel? get readUserData => _userData;

  UserProvider() {
    SharedPrefs.getUserData().then((data) => setUserData(data));
  }

  void setUserData(UserModel? data) {
    _userData = data;
    notifyListeners();
  }
}
