import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/components/uicomponents.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/providers.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
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
        body: Consumer2<UserProvider, QueryNotesProvider>(
            builder: (context, userData, querynotes, child) {
          final username = userData.readUserData?.username;
          final userNotes = querynotes.getUniversityNotes
              .where((note) => note.author == username)
              .toList();

          List<Color> colors = const [
            Color.fromRGBO(255, 242, 218, 1),
            Color.fromRGBO(253, 233, 238, 1),
            Color.fromRGBO(232, 243, 243, 1),
            Color.fromRGBO(254, 254, 240, 1),
          ];

          return CustomScrollView(slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  children: [
                    Hero(
                      transitionOnUserGestures: true,
                      tag: Auth.currentUser!.uid,
                      child: CircleAvatar(
                        radius: 100,
                        backgroundImage:
                            NetworkImage(Auth.currentUser!.photoURL!),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      userData.readUserData?.username ??
                          Auth.currentUser!.displayName!,
                      style: const TextStyle(fontSize: 30, color: Colors.white),
                    ), // current user name dapat
                    Text(
                      userData.readUserData?.email ?? Auth.currentUser!.email!,
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
                child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(45)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: List.generate(
                  userNotes.length,
                  (index) {
                    final note = userNotes[index];

                    return noteButton(
                        note, context, colors[Random().nextInt(4)]);
                  },
                ),
              ),
            )

                // current user ermail
                // button for editing profile
                // const SizedBox(
                //   width: 200,
                //   child: ElevatedButton(onPressed: () {sa settings dapat},
                //   style:  ElevatedButton.styleFrom(
                //   backgroundColor: Colors.blue, side: BorderSide.none, shape:  StadiumBorder() ),
                //   child: Text('Edit Profile', ))
                // ),
                )
          ]
              // // Hero(
              // //     tag: Auth.currentUser!.uid,
              // //     child: CircleAvatar(
              // //       backgroundImage: NetworkImage(Auth.currentUser!.photoURL!),
              //     ))
              );
        }));
  }

  // Widget _renderUserNotes() {
  //   return Container();
  // }
}
