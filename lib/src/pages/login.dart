import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:go_router/go_router.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:school_app/src/components/uicomponents.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/util_functions.dart';

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
    await Auth.signIn();
  }

  Future getStarted() async {
    await Utils.logIn(context);
    if (mounted) context.go("/setup");
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: Auth.auth.userChanges(),
        builder: (context, snapshot) {
          return Scaffold(
              body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Log in with your"),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade300),
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        _universityName,
                        style: const TextStyle(
                          fontSize: 30,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    context.go("/");
                  },
                  child: const Text("Return to Home Page"),
                ),
                if (snapshot.data == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: _logIn,
                        child: const Text("Log In"),
                      ),
                    ),
                  ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: _loginState(snapshot),
                ),
              ],
            ),
          ));
        });
  }

  Widget _loginState(AsyncSnapshot<User?> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return SizedBox(
        width: 30,
        child: myLoadingIndicator(),
      );
    }

    if (snapshot.data == null) {
      return Container();
    }

    return FutureBuilder(
        future: Auth.isUserValid(snapshot.data),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Text("Loading..."),
            );
          }
          if (snapshot.data == false) {
            return Column(
              children: [
                const Text(
                    "You are not signed in with your school email.\nOr your school may not yet be supported."),
                ElevatedButton(
                    onPressed: () {
                      Auth.signOut();
                    },
                    child: const Text("Sign Out"))
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Welcome,"),
                  Text(
                    Auth.auth.currentUser!.displayName ?? "",
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                ElevatedButton(
                    onPressed: getStarted,
                    style: ButtonStyle(
                      fixedSize: MaterialStatePropertyAll(
                        Size(MediaQuery.of(context).size.width * 0.4, 50),
                      ),
                      shape: MaterialStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      backgroundColor: MaterialStatePropertyAll(
                          Theme.of(context).colorScheme.secondary),
                    ),
                    child: const Text(
                      "Get Started",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Not you?"),
                    TextButton(
                      onPressed: () => Auth.signOut(),
                      child: const Text("Log out"),
                    )
                  ],
                )
              ]),
            ],
          );
        });
  }
}
