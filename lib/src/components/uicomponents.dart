import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

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