import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';

Future<void> translation() async {
  var translation = await Dio()
      .get("https://crowdin.com/backend/download/project/paperless-app.zip",
          options: Options(
            responseType: ResponseType.bytes,
          ));
  final archive = ZipDecoder().decodeBytes(translation.data);
  for (final file in archive) {
    final filename = file.name.split("strings-").last;
    if (file.isFile) {
      final data = file.content as List<int>;
      File('assets/locales/$filename')
        ..createSync(recursive: true)
        ..writeAsBytesSync(data);
    }
  }
  print("Downloaded translations for ${archive.length / 2} languages");
}

void main(List<String> arguments) async {
  print("▶ Updating translations...");
  await translation();
}
