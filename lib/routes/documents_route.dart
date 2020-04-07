import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:paperless_app/widgets/tag_widget.dart';

import '../api.dart';

class DocumentsRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DocumentsRouteState();
}

class _DocumentsRouteState extends State<DocumentsRoute> {
  ResponseList<Document> documents;
  ResponseList<Tag> tags;
  ResponseList<Correspondent> correspondents;
  ScrollController scrollController;
  bool requesting = false;
  DateFormat dateFormat;

  final List<double> invertMatrix = [
    -1, 0, 0, 0, 255, //
    0, -1, 0, 0, 255, //
    0, 0, -1, 0, 255, //
    0, 0, 0, 1, 0, //
  ];
  final List<double> identityMatrix = [
    1, 0, 0, 0, //
    0, 0, 1, 0, //
    0, 0, 0, 0, //
    1, 0, 0, 0, //
    0, 0, 1, 0, //
  ];

  @override
  Widget build(BuildContext context) {
    bool invertImage =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
        body: Center(
      child: documents != null
          ? ListView.builder(
              controller: scrollController,
              itemCount: documents.results.length,
              itemBuilder: (context, index) {
                List<TagWidget> tagWidgets = documents.results[index].tags.map((t) => TagWidget.fromTagId(t, tags)).toList();
                return Card(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      Stack(children: <Widget>[
                        ColorFiltered(
                            colorFilter: ColorFilter.matrix(
                                invertImage ? invertMatrix : identityMatrix),
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              height: 200,
                              width: double.infinity,
                              imageUrl: API.instance.baseURL +
                                  documents.results[index].thumbnailUrl,
                              httpHeaders: {
                                "Authorization":
                                    API.instance.client.getAuthString()
                              },
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            )),
                        Container(
                          padding: EdgeInsets.all(5.0),
                          height: 200,
                          alignment: Alignment.bottomCenter,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Colors.white.withAlpha(0),
                                Colors.white.withAlpha(0),
                                Colors.white30,
                                Colors.white,
                                Colors.white,
                              ],
                            ),
                          ),
                          child: Text(
                            '${documents.results[index].title}',
                            textAlign: TextAlign.start,
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                      ]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                              '${dateFormat.format(documents.results[index].created)}',
                              textAlign: TextAlign.left),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: tagWidgets,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            )
          : CircularProgressIndicator(),
    ));
  }

  void loadDocuments() async {
    var _documents = await API.instance.getDocuments();
    setState(() {
      documents = _documents;
    });
  }

  void loadTags() async {
    var _tags = await API.instance.getTags();
    while (_tags.hasMoreData()) {
      var moreTags = await _tags.getNext();
      _tags.next = moreTags.next;
      _tags.results.addAll(moreTags.results);
    }
    setState(() {
      tags = _tags;
    });
  }

  void loadCorrespondents() async {
    var _correspondents = await API.instance.getCorrespondents();
    while (_correspondents.hasMoreData()) {
      var moreCorrespondents = await _correspondents.getNext();
      _correspondents.next = moreCorrespondents.next;
      _correspondents.results.addAll(moreCorrespondents.results);
    }
    setState(() {
      correspondents = _correspondents;
    });
  }

  @override
  void initState() {
    loadDocuments();
    loadTags();
    loadCorrespondents();
    initializeDateFormatting();
    dateFormat = new DateFormat.yMMMMd();
    scrollController = new ScrollController()..addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() async {
    if (scrollController.position.extentAfter < 900 &&
        !requesting &&
        documents.hasMoreData()) {
      requesting = true;
      var _documents = await documents.getNext();
      setState(() {
        documents.next = _documents.next;
        documents.results.addAll(_documents.results);
      });
      requesting = false;
    }
  }
}
