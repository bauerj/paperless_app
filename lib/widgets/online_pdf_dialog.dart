import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../api.dart';
import 'package:paperless_app/i18n.dart';

class OnlinePdfDialog extends StatefulWidget {
  final Document document;

  @override
  _OnlinePdfDialogState createState() => _OnlinePdfDialogState(document);

  OnlinePdfDialog(this.document);
}

class _OnlinePdfDialogState extends State<OnlinePdfDialog> {
  double value = 0.0;
  String valueText = "0%";
  final Document doc;

  @override
  void initState() {
    downloadDocument();
    super.initState();
  }

  _OnlinePdfDialogState(this.doc);

  void onReceiveProgress(int c, int t) {
    setState(() {
      value = c / t;
      valueText = (100 * value).round().toString() + "%";
    });
  }

  static Future<String> getDownloadPath(Document doc) async {
    final tempDir = await getTemporaryDirectory();
    return '${tempDir.path}/${doc.checksum}.pdf';
  }

  void downloadDocument() async {
    final pdfPath = await getDownloadPath(doc);

    if (!await io.File(pdfPath).exists()) {
      await API.instance.downloadFile(doc.downloadUrl, pdfPath,
          onReceiveProgress: onReceiveProgress);
    }

    OpenFile.open(pdfPath);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(),
        child: Center(
          child: Container(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Column(
                children: <Widget>[
                  Text(
                    "Downloading Document".i18n,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25),
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(value: value),
                  SizedBox(height: 10),
                  Text(valueText)
                ],
              ),
            ),
          ),
        ));
  }
}
