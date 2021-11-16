import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:paperless_app/i18n.dart';

final _scaffoldKey = GlobalKey<ScaffoldState>();

class SettingsRoute extends StatefulWidget {
  SettingsRoute({Key? key}) : super(key: key);

  @override
  _SettingsRouteState createState() => _SettingsRouteState();
}

class _SettingsRouteState extends State<SettingsRoute> {
  bool invertDocumentPreview = true;
  late SharedPreferences prefs;
  _SettingsRouteState();

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  void loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      invertDocumentPreview = prefs.getBool("invert_document_preview") ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SettingsList(
        sections: [
          SettingsSection(
            title: 'View'.i18n,
            tiles: [
              SettingsTile.switchTile(
                title: 'Invert Document Preview in Dark Mode'.i18n,
                leading: Icon(Icons.invert_colors),
                switchValue: invertDocumentPreview,
                onToggle: (bool value) {
                  prefs.setBool("invert_document_preview", value);
                  setState(() {
                    invertDocumentPreview = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
