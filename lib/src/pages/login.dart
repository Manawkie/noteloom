import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/utils/providers.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/sharedprefs.dart';

class Login extends StatefulWidget {
  const Login({super.key, required this.universityName});
  final String universityName;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _universityName = "";
  @override
  void initState() {
    setState(() {
      _universityName = widget.universityName;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _logIn() async {
    await Auth.googleSignIn();
    SharedPrefs.setDepartmentAndCourses().then((data) {
      Provider.of<SetUpProvider>(context, listen: false)
          .setDepartmentsAndCourses(data);
    });
    await SharedPrefs.getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: Auth.auth.userChanges(),
        builder: (context, snapshot) {
          return Scaffold(
              body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.shade300),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          _universityName,
                          style: const TextStyle(
                            fontSize: 30,
                          ),
                          textAlign: TextAlign.center,
                        )),
                    const Text("Log in with your school account."),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (snapshot.data == null)
                        ElevatedButton(
                          onPressed: _logIn,
                          child: const Text("Log In"),
                        ),
                      ElevatedButton(
                        onPressed: () {
                          context.go("/");
                        },
                        child: const Text("Return to Home Page"),
                      ),
                      _loginState(snapshot)
                    ],
                  ),
                ),
              ],
            ),
          ));
        });
  }
}

Widget _loginState(AsyncSnapshot<User?> snapshot) {
  if (snapshot.connectionState == ConnectionState.waiting) {
    return const SizedBox(
      width: 30,
      child: LoadingIndicator(indicatorType: Indicator.ballTrianglePathColored),
    );
  }

  if (snapshot.data == null) {
    return const Text("Awaiting Log In");
  }

  return FutureBuilder(
      future: Auth.isUserValid(snapshot.data),
      builder: (context, snapshot) {
        if (snapshot.data == false) {
          return Column(
            children: [
              const Text(
                  "You are not signed in with your school email.\nOr your school may not yet be supported."),
              ElevatedButton(
                  onPressed: () {
                    Auth.auth.signOut();
                  },
                  child: const Text("Sign Out"))
            ],
          );
        }
        return Column(
          children: [
            Text("Welcome, ${Auth.auth.currentUser!.displayName}"),
            ElevatedButton(
                onPressed: () {
                  context.go("/setup");
                },
                child: const Text("Continue")),
          ],
        );
      });
}
