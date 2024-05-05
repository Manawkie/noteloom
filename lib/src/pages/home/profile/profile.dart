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
        builder: (context, user, child) {
          return SingleChildScrollView(
              child: Column(
            children: [
              const SizedBox(height: 40),
              CircleAvatar(radius: 100,
              backgroundImage: NetworkImage(Auth.currentUser!.photoURL!),),
              const SizedBox(height: 10,),
              Text(
                user.readUserData!.username,
              style: TextStyle(fontSize: 30 ),),// current user name dapat
              const Text(
                "test_email@gmail.com",
                style: TextStyle(fontSize: 20)),// current user ermail
                // button for editing profile
              // const SizedBox(
              //   width: 200,
              //   child: ElevatedButton(onPressed: () {sa settings dapat}, 
              //   style:  ElevatedButton.styleFrom(
              //   backgroundColor: Colors.blue, side: BorderSide.none, shape:  StadiumBorder() ),
              //   child: Text('Edit Profile', ))
              // ),
              const Center()
              ]),
              // // Hero(
              // //     tag: Auth.currentUser!.uid,
              // //     child: CircleAvatar(
              // //       backgroundImage: NetworkImage(Auth.currentUser!.photoURL!),
              //     ))
      );
      }
      )
      );
    
    


         
  }

  // Widget _renderUserNotes() {
  //   return Container();
  // }
}
