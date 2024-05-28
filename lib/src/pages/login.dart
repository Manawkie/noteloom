import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:school_app/src/components/uicomponents.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/util_functions.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
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
              body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromRGBO(95, 10, 215, 1),
                  Color.fromRGBO(7, 156, 182, 1),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Log in with your",
                        style: GoogleFonts.ubuntu(
                          color: Colors
                              .white, // Adjust the color to match the background gradient
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.go("/");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(255, 255, 255,
                          1), // Adjust the color to match your gradient
                      shadowColor: Colors.black.withOpacity(1),
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Return to Home Page",
                      style: GoogleFonts.ubuntu(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (snapshot.data == null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: _logIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 255, 255,
                                255), // Adjust the color to match your gradient
                            shadowColor: Colors.black.withOpacity(1),
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text("Log In",
                              style: GoogleFonts.ubuntu(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ),
                    ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: _loginState(snapshot),
                  ),
                ],
              ),
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
            return Center(
              child: Text("Loading...",
                  style: GoogleFonts.ubuntu(
                    color: Colors
                        .white, // Adjust the color to match the background gradient
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
            );
          }
          if (snapshot.data == false) {
            return Column(
              children: [
                Text(
                    "You are not signed in with your school email.\nOr your school may not yet be supported.",
                    style: GoogleFonts.ubuntu(
                      color: Colors
                          .white, // Adjust the color to match the background gradient
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    )),
                ElevatedButton(
                    onPressed: () {
                      Auth.signOut();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(
                          255, 255, 255, 0.8), // Semi-transparent white
                      shadowColor: Colors.black.withOpacity(0.5),
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text("Sign Out",
                        style: GoogleFonts.ubuntu(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )))
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Welcome",
                      style: GoogleFonts.ubuntu(
                        color: Colors
                            .white, // Adjust the color to match the background gradient
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )),
                  Text(
                    Auth.auth.currentUser!.displayName ?? "",
                    style: GoogleFonts.ubuntu(
                      color: Colors
                          .white, // Adjust the color to match the background gradient
                      fontSize: 20,
                    ),
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
                    child: Text("Get Started",
                        style: GoogleFonts.ubuntu(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Not you?",
                      style: GoogleFonts.ubuntu(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () => Auth.signOut(),
                      child: Text(
                        "Log out",
                        style: GoogleFonts.ubuntu(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                )
              ]),
            ],
          );
        });
  }
}
