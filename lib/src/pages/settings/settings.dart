import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/components/uicomponents.dart';
import 'package:school_app/src/utils/providers.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/models.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text("Settings"),
      ),
      body: Consumer2<UniversityDataProvider, UserProvider>(
          builder: (context, setup, user, child) {
        if (user.readUserData != null &&
            setup.readDepartmentsAndCourses.isNotEmpty) {
          return SetupForm(
            departmentsAndCourses: setup.readDepartmentsAndCourses,
            user: user.readUserData!,
          );
        }

        return Center(child: myLoadingIndicator());
      }),
    );
  }
}

class SetupForm extends StatefulWidget {
  final List<Map<String, dynamic>> departmentsAndCourses;
  final UserModel user;

  const SetupForm({
    super.key,
    required this.departmentsAndCourses,
    required this.user,
  });

  @override
  State<SetupForm> createState() => _SetupFormState();
}

class _SetupFormState extends State<SetupForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _username;

  final List<String> _departments = ["Select a Department"];
  final List<String> _courses = ["Select a Department first"];
  final List<String> _filteredCourses = ["Select a Department first"];

  String _selectedDepartment = "";
  String _selectedCourse = "";

  late FToast ftoast;

  @override
  void initState() {
    // set form fields to the user's data
    _username = TextEditingController(text: widget.user.username);
    _selectedDepartment = widget.user.department ?? _departments.first;

    // Extracting the departments and courses from the list of maps
    // and filtering the user's department courses
    for (Map<String, dynamic> department in widget.departmentsAndCourses) {
      department.forEach((key, value) {
        _departments.add(key);
        for (String course in value) {
          _courses.add(course);
        }
      });
    }
    resetCourses();
    _selectedCourse = widget.user.course ?? _courses.first;

    ftoast = FToast();
    ftoast.init(context);

    super.initState();
  }

  void resetCourses() {
    setState(() {
      for (Map<String, dynamic> department in widget.departmentsAndCourses) {
        department.forEach((key, value) {
          if (key == _selectedDepartment) {
            for (var course in value) {
              _filteredCourses.add(course);
            }
          }
        });
      }
    });
  }

  void _saveData() async {
    final theme = Theme.of(context);

    final userData = context.read<UserProvider>();
    final oldUsername = userData.readUserData!.username;

    final queryNotes = context.read<QueryNotesProvider>();
    try {
      if (await Database.isUsernameTaken(_username.text)) {
        throw "Username already taken. Please try another username";
      }
      if (_selectedDepartment == "Select a Department") {
        throw "Please select a department.";
      }

      if (_formKey.currentState!.validate()) {
        // save the data

        final course = _selectedCourse == "Select a Department first"
            ? null
            : _selectedCourse;

        final currentUserData = userData.readUserData;
        userData.setUserData(await Database.createUser(
          _username.text,
          _selectedDepartment,
          course,
          currentUserData?.recents ?? [],
          currentUserData?.prioritySubjects ?? [],
        ));

        // change notes data by the user
        print("Editing user notes");
        await Database.editUserNotes(oldUsername, _username.text);

        // change message usernames
        final subjectsStream = queryNotes.readSubjectsStream;
        await Database.editMessageUsername(subjectsStream, _username.text);
      }
    } catch (err) {
      ftoast.showToast(
        child: myToast(theme, err.toString()),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.5,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  hintText: Auth.currentUser!.email,
                  enabled: false,
                ),
              ),
              usernameField(_username, (value) {
                if (value!.isEmpty) {
                  return "This field is required.";
                }
                return null;
              }),
              myButtonFormField(
                  value: _selectedDepartment,
                  items: _departments,
                  onChanged: (value) {
                    setState(() {
                      _selectedDepartment = value;
                      _selectedCourse = _courses.first;
                      _filteredCourses.clear();
                      _filteredCourses.add(_courses.first);
                      resetCourses();
                    });
                  }),
              if (_filteredCourses.isNotEmpty)
                myButtonFormField(
                    value: _selectedCourse,
                    items: _filteredCourses,
                    onChanged: (value) {
                      setState(() {
                        _selectedCourse = value;
                      });
                    }),
              ElevatedButton(
                  onPressed: () async {
                    await Auth.signOut().then((_) {
                      GoRouter.of(context).go("/");
                    });
                  },
                  child: const Text("Log out")),
              ElevatedButton(onPressed: _saveData, child: const Text("Save"))
            ],
          ),
        ),
      ),
    );
  }
}
