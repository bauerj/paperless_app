import 'dart:io';

import 'package:dio/dio.dart';

void main(List<String> arguments) async {
  if (!Directory("build").existsSync()) {
    Directory("build").createSync();
  }

  var p = await Process.run("flutter",
      ["pub", "run", "i18n_extension:getstrings", "-f", "build/strings.pot"],
      runInShell: true);
  print(p.stdout);
  print(p.stderr);

  if (p.exitCode != 0) {
    print("Error: i18n_extension:getstrings failed.");
    exit(p.exitCode);
  }

  if (!Platform.environment.containsKey("CROWDIN_API_KEY")) {
    print("Warning: Skipping upload since CROWDIN_API_KEY is not set");
    exit(0);
  }
  String key = Platform.environment["CROWDIN_API_KEY"];

  var dio = Dio();
  dio.options.headers["Authorization"] = "Bearer $key";

  var response = await dio.post("https://api.crowdin.com/api/v2/storages",
      data: File("build/strings.pot").readAsStringSync(),
      options: Options(headers: {
        "Content-Type": "application/octet-stream",
        "Crowdin-API-FileName": "strings.pot"
      }));

  print("${response.statusCode}: ${response.data["data"]["id"]}");
  var storageId = response.data["data"]["id"];

  response =
      await dio.put("https://api.crowdin.com/api/v2/projects/405180/files/10",
          options: Options(headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          }),
          data: '{"storageId": $storageId}');

  print("${response.statusCode}: ${response.data}");

  response = await dio.post(
      "https://api.crowdin.com/api/v2/projects/405180/translations/builds",
      options: Options(headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      }),
      data: '{"skipUntranslatedStrings": true}');

  print("${response.statusCode}: ${response.data}");
  print("OK");
}
