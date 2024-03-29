
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:school_app/src/utils/firebase.dart';


class Login extends StatefulWidget {
  const Login({super.key, required this.universityId});
  final String universityId;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _universityName = "";
  @override
  void initState() {
    super.initState();
    Database.getUniversities().then((data) {
      data.where((uni) => uni.id == widget.universityId).forEach((uni) {
        setState(() {
          _universityName = uni.name;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                  height: 200,
                  child: _universityName.isNotEmpty
                      ? Text(
                          _universityName,
                          style: const TextStyle(
                            fontSize: 30,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : const LoadingIndicator(
                          indicatorType: Indicator.ballTrianglePathColored,
                        )),
              const Text("Log in with your school account."),
            ],
          ),
          ElevatedButton(
            onPressed: () async {
              await Auth.googleSignIn()
                  .then((value) => GoRouter.of(context).refresh());
            },
            child: const Text("Log In"),
          ),
          ElevatedButton(
            onPressed: () {
              context.replace("/");
            },
            child: const Text("Return to Home Page"),
          ),
          FutureBuilder(
            future: Auth.validateUser(Auth.auth.currentUser),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 30,
                  child: LoadingIndicator(
                    indicatorType: Indicator.ballBeat,
                  ),
                );
              }
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
              if (snapshot.data == null) {
                return const Text("Log in to continue");
              }
              return Text("Logged in: ${Auth.auth.currentUser!.displayName}");
            },
          )
        ],
      ),
    ));
  }
}
