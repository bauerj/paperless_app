import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:paperless_app/routes/home_route.dart';

import './routes/login_route.dart';
import 'routes/server_details_route.dart';

void main() {
  GetIt.I.registerSingleton<FlutterSecureStorage>(new FlutterSecureStorage());
  runApp(PaperlessApp());
}

class PaperlessApp extends StatelessWidget {


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Paperless App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'AlegreyaSans',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        primarySwatch: Colors.lightGreen,
        accentColor: Colors.lightGreenAccent,
        fontFamily: 'AlegreyaSans'
      ),
      home: HomeRoute(),
    );
  }
}
