import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:paperless_app/routes/documents_route.dart';
import 'package:paperless_app/routes/login_route.dart';
import 'package:paperless_app/routes/server_details_route.dart';

import '../api.dart';

class HomeRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Center(
          child: SizedBox(
            height: 155.0,
            child: SvgPicture.asset(
              "assets/logo.svg",
              color: Colors.green,
              fit: BoxFit.contain,
            ),
          ),
        ));
  }

  void loadData() async {
    var url;
    try {
      url = await GetIt.I<FlutterSecureStorage>().read(key: "server_url");
    } catch (e, s) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text("Unable to access secure storage: $e ($s))"),
        duration: Duration(seconds: 15),
      ));
    }
    if (url == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ServerDetailsRoute()),
      );
      return;
    }

    var username = await GetIt.I<FlutterSecureStorage>().read(key: "username");
    var password = await GetIt.I<FlutterSecureStorage>().read(key: "password");
    var trustedCertificateSha512 = await GetIt.I<FlutterSecureStorage>()
        .read(key: "trustedCertificateSha512");
    var apiFlavour =
        await GetIt.I<FlutterSecureStorage>().read(key: "api_flavour");

    if (username == null || password == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginRoute()),
      );
      return;
    }
    if (apiFlavour == null) {
      apiFlavour = "paperless";
    }

    API.trustedCertificateSha512 = trustedCertificateSha512;

    API(url, username: username, password: password, apiFlavour: apiFlavour);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DocumentsRoute()),
    );
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }
}
