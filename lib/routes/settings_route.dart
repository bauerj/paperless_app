import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:paperless_app/api.dart';

import '../widgets/display_steps_widget.dart';
import 'package:paperless_app/widgets/button_widget.dart';

import 'login_route.dart';

final _formKey = GlobalKey<FormState>();
final _scaffoldKey = GlobalKey<ScaffoldState>();

class SettingsRoute extends StatefulWidget {
  final String url;
  final bool isWelcome;

  SettingsRoute({Key key, this.url, this.isWelcome = true}) : super(key: key);

  @override
  _SettingsRouteState createState() => _SettingsRouteState(url);
}

class _SettingsRouteState extends State<SettingsRoute> {
  String serverUrl;

  _SettingsRouteState(this.serverUrl);

  void save() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      _formKey.currentState.deactivate();
      await GetIt.I<FlutterSecureStorage>()
          .write(key: "server_url", value: serverUrl);
      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text('Connecting to $serverUrl...')));
      try {
        if (await API(serverUrl).testConnection()) {
          Navigator.pushReplacement (
            context,
            MaterialPageRoute(builder: (context) => LoginRoute()),
          );
        }
      } catch (e) {
        showDialog(
            context: _scaffoldKey.currentContext,
            builder: (BuildContext ctx) {
              return AlertDialog(
                  title: Text("Connection Error"), content: Text(e.toString()));
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: SingleChildScrollView(
            child: Center(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 20),
                    DisplayStepsWidget(currentStep: 0, totalSteps: 3),
                    SizedBox(height: 60),
                    Text(
                      "Please review these settings:",
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 15.0),
                    // Dark Mode
                    // Use local index to speed up search
                    // Store all documents for offline usage
                    ButtonWidget(
                      "Start",
                      onPressed: save,
                    ),
                  ],
                ),
              ),
            ),
          ),
        )));
  }
}
