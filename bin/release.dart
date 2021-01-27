import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:yaml/yaml.dart';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

import 'package:i18n_extension/i18n_getstrings.dart';

var newVersion;

Future<void> sdkUpdate() async {
  print((await Process.run("flutter", ["upgrade"], runInShell: true)).stdout);
}

Future<void> version() async {
  var pubspecContents = File("pubspec.yaml").readAsStringSync();
  var pubspec = loadYaml(pubspecContents);
  var versionData = pubspec["version"].toString().split("+");
  var currentVersion = versionData[0];
  var increment = int.parse(versionData[1]);

  print("New version number? (Last one was $currentVersion)");
  newVersion = stdin.readLineSync();

  if (newVersion == "") newVersion = currentVersion;

  if (newVersion != currentVersion) {
    increment++;
    pubspecContents = pubspecContents.replaceFirst(
        "version: ${pubspec["version"]}", "version: $newVersion+$increment");
    File("pubspec.yaml").writeAsStringSync(pubspecContents);
    print("Updated pubspec.yaml");
    print((await Process.run("git", ["add", "pubspec.yaml"], runInShell: true))
        .stdout);
    print((await Process.run("git", ["commit", "-m", "Release $newVersion"],
            runInShell: true))
        .stdout);
  } else {
    print("Okay, not changing pubspec.yaml");
  }
}

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
  print("Downloaded translations for ${archive.length/2} languages");
}

Future<void> build() async {
  var flutter = await Process.run(
      "flutter", ["build", "apk", "--split-per-abi"],
      runInShell: true);
  print(flutter.stdout);
}

Future<void> tag() async {
  print(
      (await Process.run("git", ["tag", newVersion], runInShell: true)).stdout);
}

Future<void> push() async {
  print("Push new tag? [y/n]");
  var choice = stdin.readLineSync();
  if (choice != "y") {
    return;
  }
  print(
      (await Process.run("git", ["push", "origin"], runInShell: true)).stdout);
  print((await Process.run("git", ["push", "origin", "+$newVersion"],
          runInShell: true))
      .stdout);
}

void main(List<String> arguments) async {
  print("▶ Checking for Flutter SDK upgrades...");
  await sdkUpdate();
  await version();
  print("▶ Updating translations...");
  await translation();
  print("▶ Building APKs...");
  await build();
  print("▶ Tagging new release");
  await tag();
  await push();
}
