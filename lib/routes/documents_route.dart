import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:paperless_app/delegates/paperless_text_delegate.dart';
import 'package:paperless_app/i18n.dart';
import 'package:paperless_app/routes/about_route.dart';
import 'package:paperless_app/routes/document_detail_route.dart';
import 'package:paperless_app/routes/select_order_route.dart';
import 'package:paperless_app/routes/server_details_route.dart';
import 'package:paperless_app/routes/settings_route.dart';
import 'package:paperless_app/scan.dart';
import 'package:paperless_app/widgets/correspondent_widget.dart';
import 'package:paperless_app/widgets/document_preview.dart';
import 'package:paperless_app/widgets/search_app_bar.dart';
import 'package:paperless_app/widgets/tag_widget.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../api.dart';

class DocumentsRoute extends StatefulWidget {
  static DateFormat dateFormat = DateFormat();
  @override
  State<StatefulWidget> createState() => _DocumentsRouteState();
}

class _DocumentsRouteState extends State<DocumentsRoute> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  ResponseList<Document>? documents;
  ResponseList<Tag>? tags;
  ResponseList<Correspondent>? correspondents;
  ScrollController? scrollController;
  bool requesting = true;
  String ordering = "-created";
  String? searchString;
  String? autocompleteString;
  Tag? tagFilter;
  Correspondent? correspondentFilter;
  int scanAmount = 0;
  int shareAmount = 0;
  ScanHandler scanHandler = ScanHandler();
  late StreamSubscription intentDataStreamSubscription;
  List<SharedMediaFile>? sharedFiles;
  List<String> autocompletions = [];
  bool searchOpen = false;
  bool invertDocumentPreview = true;

  Future<void> setOrdering(String ordering) async {
    this.ordering = ordering;
    reloadDocuments();
  }

  void toggleSearch(bool isOpen) {
    setState(() {
      searchOpen = isOpen;
    });
  }

  void showDocument(Document? doc) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              DocumentDetailRoute(doc!, tags, correspondents)),
    );
    reloadDocuments();
  }

  Future<void> searchDocument(String? searchString) async {
    if (searchString == this.searchString) {
      return;
    }
    this.searchString = searchString;
    await reloadDocuments();
  }

  Future<void> getAutocompletions(String? autocompleteString) async {
    setState(() {
      this.autocompleteString = autocompleteString;
    });
    List<String> a = [];
    if (autocompleteString!.isNotEmpty)
      a = await API.instance!.getAutocompletions(autocompleteString);
    setState(() {
      autocompletions = a;
    });
  }

  Future<void> reloadDocuments() async {
    scanHandler.handleScans();
    setState(() {
      requesting = true;
      documents = null;
    });
    try {
      var _documents = await API.instance!.getDocuments(
          ordering: ordering,
          search: searchString,
          tag: tagFilter,
          correspondent: correspondentFilter);

      setState(() {
        documents = _documents;
        requesting = false;
      });
    } catch (e) {
      showDialog(
          context: _scaffoldKey.currentContext!,
          builder: (BuildContext context) {
            return AlertDialog(
                title: Text("Error while connecting to server".i18n),
                content: Text(e.toString()),
                actions: <Widget>[
                  new TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        reloadDocuments();
                      },
                      child: Text("Retry".i18n)),
                  new TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ServerDetailsRoute()),
                        );
                      },
                      child: Text("Edit Server Details".i18n))
                ]);
          });
    }
  }

  bool isFiltered() {
    return tagFilter != null ||
        searchString != null ||
        correspondentFilter != null;
  }

  Future<void> scanDocument() async {
    try {
      scanHandler.scanDocument();
    } catch (e) {
      showDialog(
          context: _scaffoldKey.currentContext!,
          builder: (BuildContext context) {
            return AlertDialog(
                title: Text("Error while uploading document".i18n),
                content: Text(e.toString()));
          });
    }
  }

  Widget getCurrentMainWidget() {
    if (documents == null) {
      return Container();
    }
    if (searchOpen) {
      // TODO: Tags und Korrespondenten in den ersten zwei Zeilen
      List<Widget> suggestions = [
        Column(children: [
          Text("With Tag".i18n),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: tags == null
                  ? [Text("None found".i18n)]
                  : tags!.results
                      .where(
                        (element) =>
                            autocompleteString == null ||
                            element != null &&
                                element.name != null &&
                                element.name!.toLowerCase().contains(
                                      autocompleteString!.toLowerCase(),
                                    ),
                      )
                      .map(
                        (t) => InkWell(
                          onTap: () {
                            this.tagFilter = t;
                            this.correspondentFilter = null;
                            this.searchString = null;
                            this.searchOpen = false;
                            this.reloadDocuments();
                          },
                          child: Padding(
                            child: TagWidget(t!),
                            padding: EdgeInsets.all(5),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
          Text("With Correspondent".i18n),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: correspondents == null
                  ? [Text("None found".i18n)]
                  : correspondents!.results
                      .where(
                        (element) =>
                            autocompleteString == null ||
                            element != null &&
                                element.name != null &&
                                element.name!.toLowerCase().contains(
                                      autocompleteString!.toLowerCase(),
                                    ),
                      )
                      .map(
                        (t) => InkWell(
                          onTap: () {
                            this.correspondentFilter = t;
                            this.tagFilter = null;
                            this.searchString = null;
                            this.searchOpen = false;

                            this.reloadDocuments();
                          },
                          child: Padding(
                            child: Text(t!.name!),
                            padding: EdgeInsets.all(5),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ]),
      ];
      for (var a in autocompletions) {
        suggestions.add(
          InkWell(
            child: Text(a),
            onTap: () {
              this.searchOpen = false;
              searchDocument(a);
            },
          ),
        );
      }
      return Column(children: suggestions);
    }
    return RefreshIndicator(
        onRefresh: reloadDocuments,
        child: ListView.builder(
          controller: scrollController,
          itemCount: documents!.results.length,
          itemBuilder: (context, index) {
            List<TagWidget?> tagWidgets = documents!.results[index]!.tags!
                .map((t) => TagWidget.fromTagId(t, tags))
                .toList();
            return Card(
              margin: EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  DocumentPreview(
                    invertDocumentPreview,
                    documents!.results[index],
                    onTap: () => showDocument(documents!.results[index]),
                  ),
                  Padding(
                    padding: EdgeInsets.all(7),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                            '${DocumentsRoute.dateFormat.format(documents!.results[index]!.created..toLocal())}',
                            textAlign: TextAlign.left),
                        CorrespondentWidget.fromCorrespondentId(
                            documents!.results[index]!.correspondent,
                            correspondents)!,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: tagWidgets.whereType<Widget>().toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ));
  }

  Widget getLeadingAppbarWidget() {
    var leading = isFiltered()
        ? IconButton(
            icon: Icon(Icons.arrow_left),
            onPressed: () {
              setState(() {
                this.searchString = null;
                this.tagFilter = null;
                this.correspondentFilter = null;
              });
              this.reloadDocuments();
            })
        : Padding(
            child: SvgPicture.asset("assets/logo.svg", color: Colors.white),
            padding: EdgeInsets.all(13));
    return leading;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showPicker(context);
          },
          child: Icon(Icons.add)),
      appBar: SearchAppBar(
          leading: getLeadingAppbarWidget(),
          key: UniqueKey(),
          title: Text(
            "Documents".i18n,
          ),
          searchListener: searchDocument,
          toggleSearch: toggleSearch,
          autoCompleteListener: getAutocompletions,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.sort_by_alpha),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => SelectOrderRoute(
                    setOrdering: setOrdering,
                    ordering: ordering,
                  ),
                );
              },
            ),
            PopupMenuButton<String>(
              onSelected: (String selected) async {
                if (selected == "settings") {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsRoute()),
                  );
                  loadSettings();
                } else if (selected == "logout") {
                  await GetIt.I<FlutterSecureStorage>().deleteAll();
                  API.instance = null;
                  await Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServerDetailsRoute()),
                  );
                } else if (selected == "about") {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutRoute()),
                  );
                }
              },
              itemBuilder: (BuildContext context) {
                return <PopupMenuItem<String>>[
                  PopupMenuItem<String>(
                      value: "settings", child: Text("Settings".i18n)),
                  PopupMenuItem<String>(
                      value: "about", child: Text("About".i18n)),
                  PopupMenuItem<String>(
                      value: "logout", child: Text("Logout".i18n)),
                ];
              },
            )
          ]),
      body: Stack(
        children: <Widget>[
          Center(
            child: getCurrentMainWidget(),
          ),
          PreferredSize(
            child: requesting ? LinearProgressIndicator() : Container(),
            preferredSize: Size.fromHeight(5),
          ),
          Padding(
            child: scanAmount > 0 || shareAmount > 0
                ? Card(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 50),
                        CircularProgressIndicator(),
                        SizedBox(width: 10),
                        Flexible(
                            child: Text(
                          "Uploading 1 scanned document"
                              .plural(scanAmount + shareAmount),
                          textAlign: TextAlign.center,
                        )),
                        SizedBox(width: 10),
                        Icon(Icons.upload_file)
                      ],
                    ),
                  )
                : Container(),
            padding: EdgeInsets.all(20),
          ),
        ],
      ),
    );
  }

  void loadTags() async {
    var _tags = await API.instance!.getTags();
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
    var _correspondents = await API.instance!.getCorrespondents();
    while (_correspondents.hasMoreData()) {
      var moreCorrespondents = await _correspondents.getNext();
      _correspondents.next = moreCorrespondents.next;
      _correspondents.results.addAll(moreCorrespondents.results);
    }
    setState(() {
      correspondents = _correspondents;
    });
  }

  void loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      invertDocumentPreview = prefs.getBool("invert_document_preview") ?? true;
    });
  }

  void onScanAmountChange(int _scanAmount) {
    setState(() {
      scanAmount = _scanAmount;
    });
  }

  void uploadSharedDocuments() async {
    if (sharedFiles != null && sharedFiles!.isNotEmpty) {
      for (var f in sharedFiles!) {
        await API.instance!.uploadFile(f.path);
        setState(() {
          shareAmount--;
        });
      }
    }
  }

  void loadShareSheet() {
    // For sharing images coming from outside the app while the app is in the memory
    intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream().listen(
        (List<SharedMediaFile> value) {
      setState(() {
        sharedFiles = value;
        if (sharedFiles != null) {
          shareAmount += sharedFiles!.length;
        }
      });
      uploadSharedDocuments();
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      setState(() {
        sharedFiles = value;
        if (sharedFiles != null) {
          shareAmount += sharedFiles!.length;
        }
      });
      uploadSharedDocuments();
    });
  }

  @override
  void initState() {
    reloadDocuments();
    loadTags();
    loadCorrespondents();
    initializeDateFormatting();
    loadSettings();
    DocumentsRoute.dateFormat = new DateFormat.yMMMMd(I18n.language);
    scrollController = new ScrollController()..addListener(_scrollListener);
    scanHandler.attachListener(onScanAmountChange);
    loadShareSheet();
    super.initState();
  }

  @override
  void dispose() {
    scrollController!.removeListener(_scrollListener);
    intentDataStreamSubscription.cancel();
    super.dispose();
  }

  void _scrollListener() async {
    if (scrollController!.position.extentAfter < 900 &&
        !requesting &&
        documents!.hasMoreData()) {
      setState(() {
        requesting = true;
      });
      var _documents = await documents!.getNext();
      setState(() {
        documents!.next = _documents.next;
        documents!.results.addAll(_documents.results);
        requesting = false;
      });
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    title: Text(
                  "Add Document from".i18n,
                  style: TextStyle(fontSize: 20),
                )),
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: Text('Gallery'.i18n),
                    onTap: () {
                      _getImage(context);
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: Text('Camera'.i18n),
                  onTap: () {
                    scanDocument();
                    Navigator.of(bc).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  Future _getImage(context) async {
    List<AssetEntity>? assets = await AssetPicker.pickAssets(context,
        requestType: RequestType.image,
        sortPathDelegate: PaperlessSortPathDelegate(),
        maxAssets: 100,
        pickerTheme: Theme.of(context),
        textDelegate: paperlessAssetsPickerTextDelegate());
    Navigator.of(context).pop();
    if (assets != null && assets.length > 0) {
      setState(() {
        shareAmount += assets.length;
      });

      for (var image in assets) {
        File? img = await (image.file);
        await API.instance!.uploadFile(img!.path);
        setState(() {
          shareAmount--;
        });
      }
    }
  }
}
