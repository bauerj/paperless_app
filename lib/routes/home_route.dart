import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:paperless_app/routes/login_route.dart';
import 'package:paperless_app/routes/server_details_route.dart';

class HomeRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:  Center(
      child:
        SizedBox(
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
    var url = await GetIt.I<FlutterSecureStorage>().read(key: "server_url");
    if (url == null) {
      Navigator.pushReplacement (
        context,
        MaterialPageRoute(builder: (context) => ServerDetailsRoute()),
      );
      return;
    }

    var username = await GetIt.I<FlutterSecureStorage>().read(key: "username");
    var password = await GetIt.I<FlutterSecureStorage>().read(key: "password");

    if (username == null || password == null) {
      Navigator.pushReplacement (
        context,
        MaterialPageRoute(builder: (context) => LoginRoute()),
      );
    }
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }
}
