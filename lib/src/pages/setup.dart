import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/components/uicomponents.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/providers.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/sharedprefs.dart';

class Setup extends StatelessWidget {
  const Setup({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UniversityDataProvider>(builder: (context, setup, child) {
      if (setup.readDepartmentsAndCourses.isEmpty) {
        SharedPrefs.getDepartmentAndCourses();
        return Scaffold(
          body: Center(child: myLoadingIndicator()),
        );
      }

      return Scaffold(
        body: SetupForm(
          data: setup.readDepartmentsAndCourses,
        ),
      );
    });
  }
}

class SetupForm extends StatefulWidget {
  const SetupForm({
    super.key,
    required this.data,
  });

  final List<Map<String, dynamic>> data;

  @override
  State<SetupForm> createState() => _SetupFormState();
}

class _SetupFormState extends State<SetupForm> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();

  final List<String> _departments = ["Select a Department"];
  final List<String> _courses = ["Select a Department first"];
  final List<String> _filteredCourses = ["Select a Department first"];

  String _selectedDepartment = "";
  String _selectedCourse = "";

  late FToast ftoast;

  @override
  void initState() {
    ftoast = FToast();
    ftoast.init(context);
    _selectedDepartment = _departments.first;
    _selectedCourse = _filteredCourses.first;
    for (var department in widget.data) {
      if (kDebugMode) print(widget.data);
      department.forEach((key, value) {
        _departments.add(key);
        for (var course in value) {
          _courses.add(course);
        }
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    _username.dispose();
    super.dispose();
  }

  void _getStarted() async {
    try {
      if (_selectedDepartment == "Select a Department") {
        throw "Please select a department and course.";
      }
      if (_formKey.currentState!.validate()) {
        final course = _selectedCourse == "Select a Department first"
            ? null
            : _selectedCourse;
        await Database.createUser(
                _username.text, _selectedDepartment, course, [], [])
            .then((UserModel user) {
          context.read<UserProvider>().setUserData(user);
          GoRouter.of(context).refresh();
        });
      }
    } catch (err) {
      final theme = Theme.of(context);
      if (kDebugMode) print(err);
      ftoast.showToast(
        child: myToast(theme, err.toString()),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // top part
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome to Note Loom!",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                      "We'd like to get to know you better before you get started."),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              // Form Fields
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextFormField(
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: Auth.auth.currentUser!.email,
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
                            _selectedDepartment = value!;
                            _selectedCourse = _filteredCourses.first;
                            _filteredCourses.clear();
                            _filteredCourses.add(_courses.first);
                            for (var department in widget.data) {
                              department.forEach((key, value) {
                                if (key == _selectedDepartment) {
                                  for (var course in value) {
                                    _filteredCourses.add(course);
                                  }
                                }
                              });
                            }
                          });
                        }),
                    if (_filteredCourses.isNotEmpty)
                      myButtonFormField(
                          value: _selectedCourse,
                          items: _filteredCourses,
                          onChanged: (value) {
                            setState(() {
                              _selectedCourse = value!;
                            });
                          }),
                    ElevatedButton(
                        onPressed: _getStarted,
                        child: const Text("Get started!")),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Not your account? "),
                        TextButton(
                            onPressed: () async {
                              await Auth.auth
                                  .signOut()
                                  .then((_) => GoRouter.of(context).refresh());
                            },
                            child: const Text("Sign Out")),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
