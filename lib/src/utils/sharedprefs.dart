import 'dart:convert';

import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static Future<List<Map<String, dynamic>>> getDepartmentAndCourses() async {
    final sf = await SharedPreferences.getInstance();

    final data = sf.getString("userSchoolData");

    if (data == null) {
      final databaseData = await setDepartmentAndCourses();
      return databaseData;
    }
    final List<dynamic> decodedData = jsonDecode(data);

    return decodedData.cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, List<String>>>>
      setDepartmentAndCourses() async {
    final sf = await SharedPreferences.getInstance();

    final databaseData = await Database.getDepartmentsAndCourses();
    sf.setString("userSchoolData", jsonEncode(databaseData));
    return databaseData;
  }

  static Future<UserModel> getUserData() async {
    final sf = await SharedPreferences.getInstance();
    final userData = sf.getString("userData");

    if (userData == null) {
      final user = await Database.getUser();
      return await setUserData(user!);
    }

    final Map<String, dynamic> decodedData = jsonDecode(userData);

    return UserModel.fromMap(decodedData);
  }

  static Future<UserModel> setUserData(UserModel user) async {
    final sf = await SharedPreferences.getInstance();
    sf.setString("userData", jsonEncode(user.toMap()));
    return user;
  }

  static Future<List<Map<String, dynamic>>> getSubjects() async {
    final sf = await SharedPreferences.getInstance();
    final subjects = sf.getString("subjects");

    if (subjects == null) {
      final userSubjects = await Database.getUserSubjects();
      await setSubjects(userSubjects);
      return userSubjects;
    }

    final List<dynamic> decodedData = jsonDecode(subjects);

    if (decodedData.isEmpty) {
      final userSubjects = await Database.getUserSubjects();
      await setSubjects(userSubjects);
      return userSubjects;
    }
    
    return decodedData.cast<Map<String, dynamic>>();
  }

  static Future<void> setSubjects(List<Map<String, String>> subjects) async {
    final sf = await SharedPreferences.getInstance();
    sf.setString("subjects", jsonEncode(subjects));
  }
}
