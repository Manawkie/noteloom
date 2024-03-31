import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PreviewPage extends StatelessWidget {
  const PreviewPage({super.key, required this.name, required this.path});
  final String name;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(name, style: const TextStyle(fontSize: 30)),
          const Text("Note Preview"),
          Container(
            child: SfPdfViewer.file(
              File(path)
            ),
          )
        ],
      ),
    ));
  }
}
