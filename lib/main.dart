import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/firebase_options.dart';
import 'package:school_app/routes.dart';
import 'package:school_app/src/providers/setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SetUpProvider()),
        ChangeNotifierProvider(create: (context)=> UserProvider())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        routerConfig: Routes.routes,
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(primarySwatch: Colors.blue));
  }
}
