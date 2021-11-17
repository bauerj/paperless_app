import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:paperless_app/i18n.dart';
import 'package:paperless_app/routes/home_route.dart';

void main() {
  runApp(PaperlessApp());
}

class PaperlessApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PaperlessAppState();
  }
}

class _PaperlessAppState extends State<PaperlessApp> {
  Future<void>? loadAsync;

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    final ThemeData darkTheme = ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.green.shade900,
        primarySwatch: Colors.lightGreen,
        fontFamily: 'AlegreyaSans');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Paperless App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'AlegreyaSans',
      ),
      darkTheme: darkTheme.copyWith(
        colorScheme: darkTheme.colorScheme.copyWith(
            surface: Colors.green.shade900, secondary: Colors.green.shade500),
      ),
      home: FutureBuilder(
        future: loadAsync,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.done)
            return I18n(
              child: HomeRoute(),
            );
          return Center(
              child: SizedBox(
            height: 155.0,
            child: SvgPicture.asset(
              "assets/logo.svg",
              color: Colors.lightGreen,
              fit: BoxFit.contain,
            ),
          ));
        },
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', "GB"),
        const Locale('de', "DE"),
        const Locale('nl', "NL"),
        const Locale('fr', "FR"),
        const Locale('it', "IT"),
        const Locale('pt', "PT"),
        const Locale('pt', "BR"),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    GetIt.I.registerSingleton<FlutterSecureStorage>(new FlutterSecureStorage());
    loadAsync = MyI18n.loadTranslations();
  }
}
