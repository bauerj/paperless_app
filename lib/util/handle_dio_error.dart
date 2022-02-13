import 'dart:io';

import 'package:convert/convert.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:paperless_app/i18n.dart';

import '../api.dart';

void handleDioError(DioError e, BuildContext ctx) {
  if (e.error.runtimeType == HandshakeException &&
      SelfSignedCertHttpOverride.lastFailedCert != null) {
    String fingerprint =
        hex.encode(SelfSignedCertHttpOverride.lastFailedCert!.sha1);
    showDialog(
        context: ctx,
        builder: (BuildContext ctx) {
          return AlertDialog(
            backgroundColor: Colors.red.shade900,
            title: Text("This is not a secure connection".i18n),
            content: Text(
                "The certificate for %s is not valid. Do you still want to trust the certificate with fingerprint %s?"
                        .i18n
                        .fill([e.requestOptions.uri.host, fingerprint]) +
                    "\n" +
                    "WARNING: The connection is not secure if you do not compare the fingerprint."
                        .i18n),
            actions: [
              TextButton(
                onPressed: () {
                  API.trustedCertificateSha512 =
                      SelfSignedCertHttpOverride.toSha512(
                          SelfSignedCertHttpOverride.lastFailedCert!);
                  GetIt.I<FlutterSecureStorage>().write(
                      key: "trustedCertificateSha512",
                      value: API.trustedCertificateSha512);
                  Navigator.of(ctx).pop();
                },
                child: Text('Yes'.i18n),
              ),
              TextButton(
                onPressed: () {
                  // Close the dialog
                  Navigator.of(ctx).pop();
                },
                child: Text('No'.i18n),
              ),
            ],
          );
        });
  } else
    showDialog(
        context: ctx,
        builder: (BuildContext ctx) {
          return AlertDialog(
              title: Text("Error while connecting to server".i18n),
              content: Text(e.toString()));
        });
}
