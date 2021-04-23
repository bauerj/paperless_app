import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share/share.dart';

import '../api.dart';
import 'package:paperless_app/i18n.dart';

class OnlinePdfDialog extends StatefulWidget {
  final Document document;
  final bool shareOnly;

  @override
  _OnlinePdfDialogState createState() =>
      _OnlinePdfDialogState(document, shareOnly);

  OnlinePdfDialog(this.document, {this.shareOnly: false});
}

class _OnlinePdfDialogState extends State<OnlinePdfDialog> {
  double value = 0.0;
  String valueText = "0%";
  final Document doc;
  final bool shareOnly;

  @override
  void initState() {
    downloadDocument();
    super.initState();
  }

  static Future<String> getDownloadPath(Document doc) async {
    String fileName = doc.archivedFileName ?? doc.originalFileName ?? "x.pdf";
    final fileType = fileName.split(".").last;
    final tempDir = await getTemporaryDirectory();
    return '${tempDir.path}/${doc.id}.$fileType';
  }

  _OnlinePdfDialogState(this.doc, this.shareOnly);

  void onReceiveProgress(int c, int t) {
    setState(() {
      value = c / t;
      valueText = (100 * value).round().toString() + "%";
    });
  }

  void downloadDocument() async {
    final pdfPath = await getDownloadPath(doc);

    if (!await io.File(pdfPath).exists()) {
      await API.instance.downloadFile(doc.getDownloadUrl(), pdfPath,
          onReceiveProgress: onReceiveProgress);
    }

    if (shareOnly) {
      Share.shareFiles([await getDownloadPath(doc)], text: doc.title);
    } else {
      OpenFile.open(pdfPath);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(
            child: Container(
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
          )
        ]));
  }
}
