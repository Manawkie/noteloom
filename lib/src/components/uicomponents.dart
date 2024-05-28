import 'dart:async';

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

Widget noteButton(NoteModel note, BuildContext context, Color color) {
  return GestureDetector(
    onTap: () {
      GoRouter.of(context).push('/note/${note.id}');
    },
    child: Container(
      width: double.infinity,
      height: 150,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    note.name,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700),
                  ),
                  Text(note.subjectName, style: const TextStyle(fontSize: 14)),
                ]),
                Text(
                  note.author,
                  style: const TextStyle(fontSize: 12),
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(note.peopleLiked?.length.toString() ?? "0"),
              const SizedBox(width: 10),
              const Icon(Icons.thumb_up_off_alt)
            ],
          )
        ],
      ),
    ),
  );
}

Widget subjectButton(SubjectModel subject, BuildContext context, Color color) {
  return GestureDetector(
    onTap: () {
      GoRouter.of(context).push('/subject/${subject.id}');
    },
    child: Container(
      height: 150,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Stack(children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                subject.subject,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(subject.subjectCode)
            ],
          ),
        ),
        Positioned(
            bottom: 0,
            right: 0,
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      context.pushNamed("subjectNotes", pathParameters: {
                        "id": subject.id!,
                      });
                    },
                    icon: const Icon(Icons.book)),
                IconButton(
                    onPressed: () {
                      context.pushNamed("discussions", pathParameters: {
                        "id": subject.id!,
                      });
                    },
                    icon: const Icon(Icons.message))
              ],
            ))
      ]),
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
    elevation: const WidgetStatePropertyAll(0),
    shape: const WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(50),
        ),
      ),
    ),
    trailing: [
      Tooltip(
        message: "Clear search",
        child: IconButton(
          icon: const Icon(
            Icons.clear,
            color: Colors.black,
          ),
          onPressed: () {
            controller.clear();
          },
        ),
      ),
    ],
    hintStyle: const WidgetStatePropertyAll(
      TextStyle(color: Colors.black, fontSize: 16),
    ),
    textStyle: const WidgetStatePropertyAll(
      TextStyle(color: Colors.black, fontSize: 16),
    ),
    backgroundColor: WidgetStatePropertyAll(
      Theme.of(context).colorScheme.tertiary,
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

class MultiSelect extends StatefulWidget {
  final List<String> selectedTags;
  final List<String> tags;
  const MultiSelect(
      {super.key, required this.selectedTags, required this.tags});

  @override
  State<MultiSelect> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  final List<String> _selectedItems = [];

  @override
  void initState() {
    _selectedItems.addAll(widget.selectedTags);
    super.initState();
  }

  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (_selectedItems.length >= 3) {
          return;
        }
        _selectedItems.add(itemValue);
      } else {
        _selectedItems.remove(itemValue);
      }
    });
  }

  void _cancel() {
    Navigator.pop(context);
  }

  void _submit() {
    Navigator.pop(context, _selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select tags (Maximum of 3)'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.tags
              .map((item) => CheckboxListTile(
                    value: _selectedItems.contains(item),
                    title: Text(item),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (isChecked) => _itemChange(item, isChecked!),
                  ))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

SearchAnchor subjectSearchBar(
    SearchController searchController,
    String hintText,
    List<SubjectModel> items,
    FutureOr<Iterable<Widget>> Function(
            BuildContext context, SearchController controller)
        suggestions) {
  return SearchAnchor(
      searchController: searchController,
      builder: (context, controller) {
        return SearchBar(
          hintText: hintText,
          controller: controller,
          padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 12)),
          onTap: () {
            controller.openView();
          },
        );
      },
      suggestionsBuilder: suggestions);
}

ListTile addASubjectButton(BuildContext context) {
  return ListTile(
    title: const Text("Can't find your subject?"),
    subtitle: const Text("Add a new subject"),
    onTap: () {
      context.push("/addSubject");
    },
  );
}
