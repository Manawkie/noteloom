import 'package:flutter/material.dart';

class PrioritySubjects extends StatefulWidget {
  const PrioritySubjects({super.key});

  @override
  State<PrioritySubjects> createState() => _PrioritySubjectsState();
}

class _PrioritySubjectsState extends State<PrioritySubjects> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center( 
        child: Text("My Subjects Page"),
      ),
    );
  }
}