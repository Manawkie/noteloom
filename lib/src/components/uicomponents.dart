import 'package:flutter/material.dart';

Widget myFormField(
    {required String label,
    required TextEditingController controller,
    required bool isRequired}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
    ),
    validator: (value) =>
        isRequired && value!.isEmpty ? "This field is required." : null,
  );
}

TextFormField usernameField(
  TextEditingController controller,
  String? Function(String?) validator
  ) {
  return TextFormField(
    controller: controller,
    decoration: const InputDecoration(
      labelText: "Username",
    ),
    validator: validator
  );
}