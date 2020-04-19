import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:paperless_app/routes/documents_route.dart';
import 'package:paperless_app/widgets/button_widget.dart';
import 'package:paperless_app/widgets/display_steps_widget.dart';
import 'package:paperless_app/widgets/textfield_widget.dart';

import '../api.dart';

final _formKey = GlobalKey<FormState>();
final _scaffoldKey = GlobalKey<ScaffoldState>();

class LoginRoute extends StatefulWidget {
  LoginRoute({Key key}) : super(key: key);

  @override
  _LoginRouteState createState() => _LoginRouteState();
}

class _LoginRouteState extends State<LoginRoute> {
  String username;
  String password;

  void save () async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      _formKey.currentState.deactivate();
      String serverUrl = await GetIt.I<FlutterSecureStorage>().read(key: "server_url");
      await GetIt.I<FlutterSecureStorage>().write(key: "username", value: username);
      await GetIt.I<FlutterSecureStorage>().write(key: "password", value: password);

      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text('Checking credentials...')));

      try {
        if (await API(serverUrl, username: username, password: password).checkCredentials()) {
          Navigator.pushReplacement (
            context,
            MaterialPageRoute(builder: (context) => DocumentsRoute()),
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
                        DisplayStepsWidget(currentStep: 1, totalSteps: 2),
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
                          "Welcome to Paperless",
                          style: TextStyle(fontSize: 30),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 25.0),
                        Text(
                          "Please enter your credentials to continue:",
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 15.0),
                        TextfieldWidget(
                          onFieldSubmitted: (String x) {
                            save();
                          },
                          autofocus: true,
                          hintText: "username",
                          keyboardType: TextInputType.emailAddress,
                          initialValue: username,
                          validator: (value) {
                            if (value.isEmpty)
                              return "Please enter your username";
                            return null;
                          },
                          onSaved: (String u) {
                            username = u.trim();
                          },
                        ),
                        SizedBox(height: 15.0),
                        TextfieldWidget(
                          onFieldSubmitted: (String x) {
                            save();
                          },
                          keyboardType: TextInputType.visiblePassword,
                          initialValue: password,
                          obscureText: true,
                          hintText: "Password",
                          validator: (value) {
                            if (value.isEmpty)
                              return "Please enter your password";
                            return null;
                          },
                          onSaved: (String u) {
                            password = u;
                          },
                        ),
                        SizedBox(height: 35.0),
                        ButtonWidget(
                          "Login",
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
