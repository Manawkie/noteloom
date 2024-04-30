import 'package:flutter/material.dart';
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
          return SingleChildScrollView(
              child: Column(
            children: [
              Hero(
                  tag: Auth.currentUser!.uid,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(Auth.currentUser!.photoURL!),
                  ))
            ],
          ));
        },
      ),
    );
  }

  // Widget _renderUserNotes() {
  //   return Container();
  // }
}
