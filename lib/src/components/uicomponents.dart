import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:school_app/src/utils/models.dart';

Widget myFormField(
    {required String label,
    required TextEditingController controller,
    required bool isRequired,
    void Function(String)? onChanged}) {
  return TextFormField(
    controller: controller,
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: label,
    ),
    validator: (value) =>
        isRequired && value!.isEmpty ? "This field is required." : null,
  );
}

TextFormField usernameField(
    TextEditingController controller, String? Function(String?) validator) {
  return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: "Username",
      ),
      validator: validator);
}

DropdownButtonFormField myButtonFormField(
    {required String value,
    required List<String> items,
    required Function(dynamic value) onChanged}) {
  return DropdownButtonFormField(
      value: value,
      isExpanded: true,
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e),
              ))
          .toList(),
      onChanged: onChanged);
}

Widget myLoadingIndicator() {
  return const SizedBox(
    height: 30,
    width: 30,
    child: LoadingIndicator(
      indicatorType: Indicator.ballTrianglePathColored,
    ),
  );
}

Widget myToast(ThemeData theme, String text) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(8)),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
      ),
    ),
  );
}

// notes / subject button

Widget noteButton(NoteModel note, BuildContext context) {
  return GestureDetector(
    onTap: () {
      GoRouter.of(context).push('/note/${note.id}');
    },
    child: Container(
      width: double.infinity,
      height: 150,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [Text(note.name), Text(note.subjectName), Text(note.author)],
      ),
    ),
  );
}

Widget subjectButton(SubjectModel subjectModel, BuildContext context) {
  return GestureDetector(
    onTap: () {
      GoRouter.of(context).push('/subject/${subjectModel.id}');
    },
    child: Container(
      height: 150,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: Column(
          children: [
            Text(subjectModel.subject),
            Text(subjectModel.subjectCode)
          ],
        ),
      ),
    ),
  );
}

SearchBar mySearchBar(
  BuildContext context,
  SearchController controller,
  String hintText,
) {
  return SearchBar(
    controller: controller,
    hintText: hintText,
    elevation: const MaterialStatePropertyAll(0),
    shape: const MaterialStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
      ),
    ),
    trailing: [
      Tooltip(
        message: "Clear search",
        child: IconButton(
          icon: const Icon(
            Icons.clear,
            color: Colors.white,
          ),
          onPressed: () {
            controller.clear();
          },
        ),
      ),
    ],
    hintStyle: const MaterialStatePropertyAll(
      TextStyle(color: Colors.white, fontSize: 16),
    ),
    textStyle: const MaterialStatePropertyAll(
      TextStyle(color: Colors.white, fontSize: 16),
    ),
    backgroundColor: const MaterialStatePropertyAll(
      Color.fromRGBO(0, 0, 0, 0),
    ),
  );
}

class MyMessageField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Function(String? text) onChanged;
  const MyMessageField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscureText,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
        fillColor: Colors.grey[200],
        filled: true,
        hintText: hintText,
      ),
      onChanged: onChanged,
    );
  }
}
