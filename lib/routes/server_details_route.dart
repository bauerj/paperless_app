import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:paperless_app/api.dart';
import 'package:paperless_app/widgets/textfield_widget.dart';

import '../widgets/display_steps_widget.dart';
import 'package:paperless_app/widgets/button_widget.dart';
import 'package:paperless_app/i18n.dart';

import 'login_route.dart';

final _formKey = GlobalKey<FormState>();
final _scaffoldKey = GlobalKey<ScaffoldState>();

class ServerDetailsRoute extends StatefulWidget {
  final String url;
  final bool isWelcome;

  ServerDetailsRoute({Key key, this.url, this.isWelcome = true})
      : super(key: key);

  @override
  _ServerDetailsRouteState createState() => _ServerDetailsRouteState(url);
}

class _ServerDetailsRouteState extends State<ServerDetailsRoute> {
  String serverUrl;

  _ServerDetailsRouteState(this.serverUrl);

  void save() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      _formKey.currentState.deactivate();
      await GetIt.I<FlutterSecureStorage>()
          .write(key: "server_url", value: serverUrl);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('Connecting to %s...'.i18nFormat([serverUrl]))));
      try {
        if (await API(serverUrl).testConnection()) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginRoute()),
          );
        }
      } catch (e) {
        showDialog(
            context: _scaffoldKey.currentContext,
            builder: (BuildContext ctx) {
              return AlertDialog(
                  title: Text("Error while connecting to server".i18n),
                  content: Text(e.toString()));
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
                    DisplayStepsWidget(currentStep: 0, totalSteps: 2),
                    SizedBox(height: 60),
                    SizedBox(
                      height: 155.0,
                      child: SvgPicture.asset(
                        "assets/logo.svg",
                        color: Colors.green,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 40),
                    Text(
                      "Welcome to Paperless".i18n,
                      style: TextStyle(fontSize: 30),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 25.0),
                    Text(
                      "Please enter your Paperless server URL:".i18n,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 15.0),
                    TextfieldWidget(
                      onFieldSubmitted: (String x) {
                        save();
                      },
                      hintText: "https://paperless.example.com",
                      autocorrect: false,
                      autofocus: true,
                      keyboardType: TextInputType.url,
                      initialValue: serverUrl,
                      validator: (value) {
                        if (value.isEmpty || Uri.tryParse(value) == null)
                          return "Please enter a URL".i18n;
                        return null;
                      },
                      onSaved: (String url) {
                        serverUrl = url;
                      },
                    ),
                    SizedBox(height: 35.0),
                    ButtonWidget(
                      "Connect".i18n,
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
