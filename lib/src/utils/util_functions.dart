import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/providers.dart';
import 'package:school_app/src/utils/sharedprefs.dart';

class Utils {
  static resetData() {
    // if the user logs out, clear all providers and shared preferences.
    SharedPrefs.resetData();
  }

  static logIn(BuildContext context) async {
    //// University Information
    ///

    final notesProvider = context.read<QueryNotesProvider>();
    final userInfo = context.read<UserProvider>();

    // override all set deps and courses
    // [{dep : [course, course, course], {dep: [course, course, course]}}]

    final List<Map<String, List<String>>> departmentsAndCourses =
        await Database.getDepartmentsAndCourses();
    await SharedPrefs.setDepartmentAndCourses(departmentsAndCourses);

    // override all set subjects

    // [Subject, Subject...]
    await Database.getAllSubjects().then((allSubjects) {
      notesProvider.setAllSubjects(allSubjects);
    });

    //// User's information

    // override user data with the new user
    // with the data,
    //   set provider's user data
    //   set recents
    //   set priority subjects
    await Database.getUser().then((UserModel? userData) async {
      if (kDebugMode) {
        print(userData?.id);
        print(userData?.email);
        print(userData?.username);
      }

      if (userData != null) {
        userInfo.setUserData(userData);
        userInfo.setRecents(userData.recents);
        userInfo.setPrioritySubjectIds(userData.prioritySubjects ?? []);
      } else {
        userInfo.setUserData(null);
      }
    });
    // saved notes are saved in a subcollection in firebase
    // so we need to do things separately
    // get all of the user's saved notes

    await Database.getAllSavedNotes().then((savedNotes) async {
      List<String> savedNotesIds = [];
      for (var note in savedNotes) {
        savedNotesIds.add(note.noteid);
      }
      userInfo.setSavedNoteIds(savedNotesIds);
    });
  }
}
