import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:paperless_app/api.dart';
import 'package:paperless_app/i18n.dart';
import 'package:paperless_app/widgets/correspondent_widget.dart';
import 'package:paperless_app/widgets/document_preview.dart';
import 'package:paperless_app/widgets/heading.dart';
import 'package:paperless_app/widgets/online_pdf_dialog.dart';
import 'package:paperless_app/widgets/tag_widget.dart';

import 'documents_route.dart';

class DocumentDetailRoute extends StatefulWidget {
  final Document document;
  final ResponseList<Tag> tags;
  final ResponseList<Correspondent> correspondents;

  const DocumentDetailRoute(this.document, this.tags, this.correspondents,
      {Key key})
      : super(key: key);

  @override
  _DocumentDetailRouteState createState() {
    return _DocumentDetailRouteState(document, tags, correspondents);
  }
}

// Oben in der Statusleiste Dokumentenname, Share, ...(Löschen)
class _DocumentDetailRouteState extends State<DocumentDetailRoute> {
  final Document _document;
  final ResponseList<Tag> _tags;
  final ResponseList<Correspondent> _correspondents;

  _DocumentDetailRouteState(this._document, this._tags, this._correspondents);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: Icon(Icons.share),
              onPressed: () async {
                shareDocumentPdf(_document);
              }),
          PopupMenuButton<String>(
            onSelected: (String selected) async {
              if (selected == "delete") {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                          title: Text("Confirm removal".i18n),
                          content: Text(
                              "Are you sure you want to remove this document?"
                                  .i18n),
                          actions: <Widget>[
                            new TextButton(
                                onPressed: () {
                                  // TODO: API.instance
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: Text("Remove".i18n)),
                            new TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("Cancel".i18n))
                          ]);
                    });
              }
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<String>>[
                PopupMenuItem<String>(
                    value: "delete", child: Text("Delete".i18n)),
              ];
            },
          )
        ],
        title: Text(
          _document.title,
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          DocumentPreview(
            true,
            _document,
            height: 300,
            showTitle: false,
            showOpen: true,
            onTap: () => showDocumentPdf(_document),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 7, right: 10),
                    child: Heading("Created".i18n, factor: 0.5),
                  ),
                  Text(DocumentsRoute.dateFormat.format(_document.created))
                ]),
                Heading(
                  "Correspondent".i18n,
                  factor: 0.5,
                ),
                CorrespondentWidget.fromCorrespondentId(
                    _document.correspondent, _correspondents),
                Padding(
                  padding: EdgeInsets.only(bottom: 5, right: 10),
                  child: Heading("Tags".i18n, factor: 0.5),
                ),
                Row(
                    children: _document.tags
                        .map((e) => TagWidget.fromTagId(e, _tags))
                        .toList())
              ],
            ),
          )
        ]),
      ),
    );
  }

  void showDocumentPdf(Document doc) {
    showDialog(
      context: context,
      builder: (BuildContext context) => OnlinePdfDialog(doc),
    );
  }

  void shareDocumentPdf(Document doc) {
    showDialog(
      context: context,
      builder: (BuildContext context) => OnlinePdfDialog(doc, shareOnly: true),
    );
  }
}
