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
  final ResponseList<Tag>? tags;
  final ResponseList<Correspondent>? correspondents;

  const DocumentDetailRoute(this.document, this.tags, this.correspondents,
      {Key? key})
      : super(key: key);

  @override
  _DocumentDetailRouteState createState() {
    return _DocumentDetailRouteState(document, tags, correspondents);
  }
}

class _DocumentDetailRouteState extends State<DocumentDetailRoute> {
  final Document _document;
  final ResponseList<Tag>? _tags;
  final ResponseList<Correspondent>? _correspondents;

  _DocumentDetailRouteState(this._document, this._tags, this._correspondents);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool editable = true;
//        API.instance.getCapabilities().contains(APICapability.UPDATE_DOCUMENTS);
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
                return showDialog(
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
                                  API.instance!.deleteDocument(_document);
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
              if (selected == "rename") {
                TextEditingController _textFieldController =
                    TextEditingController();
                _textFieldController.value =
                    TextEditingValue(text: _document.title!);
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Enter new document name".i18n),
                        actions: <Widget>[
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("Cancel".i18n)),
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  _document.title =
                                      _textFieldController.value.text;
                                });
                                saveTitle();
                                Navigator.of(context).pop();
                              },
                              child: Text("OK".i18n)),
                        ],
                        content: TextField(
                          onChanged: (value) {},
                          controller: _textFieldController,
                        ),
                      );
                    });
              }
            },
            itemBuilder: (BuildContext context) {
              return editable
                  ? <PopupMenuItem<String>>[
                      PopupMenuItem<String>(
                          value: "rename", child: Text("Rename".i18n)),
                      PopupMenuItem<String>(
                          value: "delete", child: Text("Delete".i18n)),
                    ]
                  : [];
            },
          )
        ],
        title: Text(
          _document.title!,
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
                _EditableHeading(
                  "Created".i18n,
                  editable: editable,
                  onEdit: () async {
                    DateTime? newDate = await showDatePicker(
                        initialDate: _document.created.toLocal(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now().add(Duration(days: 100)),
                        context: context);
                    if (newDate != null) {
                      setState(() {
                        _document.created = newDate;
                        saveCreatedDate();
                      });
                    }
                  },
                ),
                Text(DocumentsRoute.dateFormat
                    .format(_document.created..toLocal())),
                _EditableHeading(
                  "Correspondent".i18n,
                  editable: editable,
                  onEdit: () {
                    List<Widget> options = [];
                    options.add(
                      SimpleDialogOption(
                        child: Text(
                          "None".i18n,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _document.correspondent = null;
                            saveCorrespondent();
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                    for (var c in _correspondents!.results) {
                      options.add(SimpleDialogOption(
                        child: Text(c!.name!),
                        onPressed: () {
                          setState(() {
                            _document.correspondent = c.id;
                            saveCorrespondent();
                          });
                          Navigator.of(context).pop();
                        },
                      ));
                    }
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return SimpleDialog(
                            title: Text("Select Correspondent".i18n),
                            children: options,
                          );
                        });
                  },
                ),
                CorrespondentWidget.fromCorrespondentId(
                    _document.correspondent, _correspondents,
                    showIfNone: true)!,
                _EditableHeading(
                  "Tags".i18n,
                  editable: editable,
                  onEdit: () {
                    List<Widget> items = [];
                    for (var t in _tags!.results) {
                      items.add(
                        SelectableTagWidget(
                          TagWidget.fromTagId(t!.id, _tags),
                          _document.tags!.contains(t.id),
                          onEdit: (v) {
                            setState(() {
                              if (v!)
                                _document.tags!.add(t.id);
                              else
                                _document.tags!
                                    .removeWhere((tag) => t.id == tag);
                              saveTags();
                            });
                          },
                        ),
                      );
                    }
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Select Tags".i18n),
                            actions: <Widget>[
                              TextButton(
                                child: Text("OK".i18n),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                            content: SingleChildScrollView(
                              child: Container(
                                width: double.maxFinite,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight:
                                        MediaQuery.of(context).size.height *
                                            0.7,
                                  ),
                                  child: ListView(
                                    children: items,
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                  },
                ),
                Row(
                    children: _document.tags!
                        .map((e) => TagWidget.fromTagId(e, _tags))
                        .whereType<Widget>()
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

  Future<void> saveTags() async {
    await API.instance!.updateDocument(_document.id, {"tags": _document.tags});
  }

  Future<void> saveCreatedDate() async {
    await API.instance!.updateDocument(
        _document.id, {"created": _document.created.toIso8601String()});
  }

  Future<void> saveCorrespondent() async {
    await API.instance!.updateDocument(
        _document.id, {"correspondent": _document.correspondent});
  }

  Future<void> saveTitle() async {
    await API.instance!
        .updateDocument(_document.id, {"title": _document.title});
  }
}

class _EditableHeading extends StatefulWidget {
  final VoidCallback? onEdit;
  final String text;
  final bool? editable;

  const _EditableHeading(this.text, {Key? key, this.onEdit, this.editable})
      : super(key: key);

  @override
  _EditableHeadingState createState() {
    return _EditableHeadingState(text, onEdit, editable);
  }
}

class _EditableHeadingState extends State<_EditableHeading> {
  final String text;
  final VoidCallback? onEdit;
  final bool? editable;

  _EditableHeadingState(this.text, this.onEdit, this.editable);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 10),
        child: Row(
          children: [
            Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Heading(
                  text,
                  factor: 0.5,
                )),
            editable!
                ? IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: onEdit,
                    iconSize: 12,
                    splashRadius: 12.0,
                    splashColor: Colors.greenAccent,
                    color: Color.fromARGB(255, 120, 120, 120))
                : Text(""),
          ],
        ));
  }
}
