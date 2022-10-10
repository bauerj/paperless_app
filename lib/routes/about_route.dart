import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:paperless_app/i18n.dart';
import 'package:paperless_app/widgets/button_widget.dart';
import 'package:paperless_app/widgets/heading.dart';

class AboutRoute extends StatefulWidget {
  @override
  _AboutRouteState createState() {
    return _AboutRouteState();
  }
}

class _AboutRouteState extends State<AboutRoute> {
  List<dynamic>? contributors = [];
  List<dynamic>? translators = [];

  Future<void> loadContributors() async {
    var _contributors = (await Dio().get(
            "https://bauerj.github.io/paperless_app/contributors-combined.json"))
        .data;

    setState(() {
      translators = _contributors["translators"]["data"]
          .map((e) => e["data"]["fullName"] ?? e["data"]["username"])
          .toList();
      contributors =
          _contributors["contributors"].map((e) => e["login"]).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    loadContributors();
  }

  @override
  Widget build(BuildContext context) {
    List<Text> contributorsTexts = contributors!.map((e) => Text(e)).toList();
    List<Text> translatorsTexts = translators!.map((e) => Text(e)).toList();
    return Scaffold(
        body: Center(
            child: SingleChildScrollView(
                padding: EdgeInsets.all(30),
                child: Column(
                  children: [
                    Heading(
                      "About".i18n,
                      factor: 2,
                    ),
                    Text(
                      "Paperless App is open-source software licenced under the GNU General Public Licence."
                          .i18n,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "Paperless App would not have been possible without the help of some awesome people."
                          .i18n,
                      textAlign: TextAlign.center,
                    ),
                    Heading("Code contributors".i18n),
                    Text("The following people have submitted code on Github:"
                        .i18n
                        .i18n),
                    SizedBox(
                      height: 10,
                    ),
                    Column(children: contributorsTexts),
                    Heading("Translators".i18n),
                    Text(
                        "Translations for Paperless App were made on Crowdin by:"
                            .i18n),
                    SizedBox(
                      height: 10,
                    ),
                    Column(children: translatorsTexts),
                    Heading("Special Thanks".i18n),
                    Text("Daniel Quinn"),
                    Text("Jonas Winkler"),
                    Text(
                        "And everyone else who worked on Paperless(-NG).".i18n),
                    Heading("Open Source libraries".i18n),
                    SizedBox(
                      height: 10,
                    ),
                    ButtonWidget(
                      "Show licence information".i18n,
                      onPressed: () => showLicensePage(context: context),
                      scale: 0.8,
                    )
                  ],
                ))));
  }
}
