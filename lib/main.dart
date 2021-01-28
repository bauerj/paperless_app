import 'package:flutter/material.dart';

import 'package:i18n_extension/i18n_widget.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:paperless_app/routes/home_route.dart';
import 'package:paperless_app/i18n.dart';

void main() {
  GetIt.I.registerSingleton<FlutterSecureStorage>(new FlutterSecureStorage());
  runApp(PaperlessApp());
}

class PaperlessApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    MyI18n.loadTranslations();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Paperless App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'AlegreyaSans',
      ),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.green.shade900,
          primarySwatch: Colors.lightGreen,
          accentColor: Colors.lightGreenAccent,
          fontFamily: 'AlegreyaSans'),
      home: I18n(child: HomeRoute()),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', "GB"),
        const Locale('de', "DE"),
      ],
    );
  }
}
