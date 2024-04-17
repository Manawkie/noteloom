import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/providers.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            context.pop();
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.push("/home/settings");
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, value, child) {
          final screenSize = MediaQuery.of(context).size;
          return SingleChildScrollView(
            child: SizedBox(
              width: screenSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: screenSize.width,
                    padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width / 4, vertical: 30),
                    decoration:
                        BoxDecoration(color: Theme.of(context).primaryColor),
                    child: Hero(
                      tag: Auth.currentUser!.uid,
                      child: CircleAvatar(
                        radius: screenSize.width / 5,
                        backgroundImage: NetworkImage(
                          Auth.currentUser!.photoURL ?? "",
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(children: [
                      Text(
                        Auth.currentUser!.displayName ?? "",
                        style: const TextStyle(fontSize: 20),
                      ),
                      Text(
                        Auth.currentUser!.email ?? "",
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(
                        height: 50,
                        child: Text("Notes:"),
                      ),
                      _renderUserNotes()
                    ]),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _renderUserNotes() {
    return Container();
  }
}
