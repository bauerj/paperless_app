import 'dart:io';

import 'package:yaml/yaml.dart';

import 'download_translations.dart';

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
