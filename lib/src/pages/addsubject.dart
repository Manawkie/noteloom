import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_app/src/components/uicomponents.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:school_app/src/utils/providers.dart';

class AddSubject extends StatefulWidget {
  const AddSubject({super.key});

  @override
  State<AddSubject> createState() => _AddSubjectState();
}

class _AddSubjectState extends State<AddSubject> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _subjectNameController = TextEditingController();
  TextEditingController _subjectCodeController = TextEditingController();
  bool isSubmitting = false;

  late List<SubjectModel> listFromDB;
  late FToast ftoast;

  @override
  void initState() {
    ftoast = FToast();
    ftoast.init(context);
    super.initState();
  }

  void displayToast(String message) {
    ftoast.showToast(
      child: myToast(Theme.of(context), message),
      gravity: ToastGravity.BOTTOM_RIGHT,
      fadeDuration: const Duration(milliseconds: 400),
      toastDuration: const Duration(seconds: 2),
      isDismissable: true,
      ignorePointer: false,
    );
  }

  void _submitSubject(
    BuildContext context,
  ) async {
    List<SubjectModel> queriedSubjects =
        context.read<QueryNotesProvider>().getUniversitySubjects;
    // check if there is a subject code in the same university

    queriedSubjects = {...queriedSubjects, ...listFromDB}.toList();

    setState(() {
      isSubmitting = true;
    });
    try {
      if (!_formKey.currentState!.validate()) {
        throw ErrorDescription("Please fill in the required fields");
      }
      await Database.addSubject(_subjectNameController.text.trim(),
          _subjectCodeController.text.trim(), queriedSubjects);
      displayToast("Subject added successfully");
      _subjectCodeController.clear();
      _subjectNameController.clear();
    } on ErrorDescription catch (e) {
      displayToast(e.toString());
    }

    setState(() {
      isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Database.getSubjectsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            listFromDB = snapshot.data!.docs.map((sub) => sub.data()).toList();
          }
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => context.go("/home"),
              ),
              title: const Text("Add a Subject"),
            ),
            body: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                height: MediaQuery.of(context).size.height * 0.5,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      myFormField(
                          label: "Subject",
                          controller: _subjectNameController,
                          isRequired: true),
                      myFormField(
                          label: "Subject Code",
                          controller: _subjectCodeController,
                          isRequired: true),
                      ElevatedButton(
                          onPressed: () => _submitSubject(context),
                          child: const Text("Submit"))
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
