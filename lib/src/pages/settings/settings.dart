import 'package:flutter/material.dart';
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

  const SetupForm(
      {super.key, required this.departmentsAndCourses, required this.user});

  @override
  State<SetupForm> createState() => _SetupFormState();
}

class _SetupFormState extends State<SetupForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _username;

  final List<String> _departments = ["Select a Department"];
  final List<String> _courses = ["Select a Department first"];
  final List<String> _filteredCourses = ["Select a Department first"];
  final List<String> _takenUsernames = [];

  String _selectedDepartment = "";
  String _selectedCourse = "";

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

    // get all taken usernames
    Database.getUsernames().then((value) {
      _takenUsernames
          .where((element) => element != widget.user.username)
          .toList();
    });

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
    if (_formKey.currentState!.validate()) {
      // save the data
      final department = _selectedDepartment == "Select a Department"
          ? null
          : _selectedDepartment;

      context.read<UserProvider>().setUserData( await
          Database.createUser(_username.text, department, _selectedCourse));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
              if (_takenUsernames.contains(value)) {
                return "This username is already taken.";
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
                  await Auth.auth.signOut().then((_) {
                    GoRouter.of(context).go("/");
                  });
                },
                child: const Text("Log out")),
            ElevatedButton(onPressed: _saveData, child: const Text("Save"))
          ],
        ),
      ),
    );
  }
}
