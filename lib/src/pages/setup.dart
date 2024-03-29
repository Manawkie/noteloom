
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/setup.dart';

class Setup extends StatefulWidget {
  const Setup({super.key});

  @override
  State<Setup> createState() => _SetupState();
}

class _SetupState extends State<Setup> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Database.getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasData) {
          GoRouter.of(context).go("/home");
        }

        return const SetupPage();
      },
    );
  }
}

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final _usernameControl = TextEditingController();
  late List<String> _existingUsernames;
  late List<String>? _schoolDepartments;

  String schoolYear = schoolYears.first;
  @override
  void initState() {
    Database.getUsernames().then((value) => setState(() {
          _existingUsernames = value;
          if (kDebugMode) print(value);
        }));

    Database.getDepartments().then((value) => setState(() {
          _schoolDepartments = value;
          if (kDebugMode) print(value);
        }));
    super.initState();
  }

  @override
  void dispose() {
    _usernameControl.dispose();
    super.dispose();
  }

  Widget _createTextField(
      String name, TextEditingController control, bool required) {
    return TextFormField(
      controller: control,
      decoration: InputDecoration(hintText: name),
      validator: (String? value) {
        if (required && value == "") {
          return "This field is required";
        }
        if (name.toLowerCase() == "username") {
          if (_existingUsernames.contains(value?.toLowerCase())) {
            return "This username is already taken. Please choose another username";
          }
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const Text(
            "Welcome to Note Loom!",
            style: TextStyle(
                fontSize: 50,
                leadingDistribution: TextLeadingDistribution.even),
            textAlign: TextAlign.center,
          ),
          const Text("To get started, please set up your profile."),
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _createTextField("Username", _usernameControl, true),
                DropdownButton(
                  value: schoolYear,
                  items: schoolYears.map((String val) {
                    return DropdownMenuItem(
                      value: val,
                      child: Text(val),
                    );
                  }).toList(),
                  onChanged: (String? val) {
                    setState(() {
                      schoolYear = val!;
                    });
                  },
                ),
              ],
            ),
          )
        ],
      ),
    ));
  }
}
