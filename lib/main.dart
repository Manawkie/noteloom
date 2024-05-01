import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/firebase_options.dart';
import 'package:school_app/routes.dart';
import 'package:school_app/src/utils/providers.dart';
import 'package:school_app/src/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UniversityDataProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => NoteProvider()),
        ChangeNotifierProvider(create: (context) => QueryNotesProvider()),
        ChangeNotifierProvider(create: (context) => CurrentNoteProvider()),
        ChangeNotifierProvider(create: (context) => MessageProvider())
      
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
        theme: AppTheme.defaultTheme);
  }
}
