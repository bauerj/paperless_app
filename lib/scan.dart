import 'dart:async';
import 'dart:io';

import 'package:edge_detection/edge_detection.dart';
import 'package:paperless_app/api.dart';
import 'package:path_provider/path_provider.dart';

class ScanHandler {
  late Directory scansDir;
  List<Function(int scansAmount)> statusListeners = [];
  bool running = false;

  Future<void> _init() async {
    scansDir = new Directory((await getTemporaryDirectory()).path + "/scans");
    if (!await scansDir.exists()) {
      scansDir.create();
    }
  }

  void attachListener(Function(int scansAmount) listener) {
    statusListeners.add(listener);
  }

  Future<void> handleScans() async {
    if (running) return;
    await _init();
    running = true;
    while (true) {
      var scansAmount = await scansDir.list().length;
      print("Amount: $scansAmount");
      statusListeners.first(scansAmount);
      if (scansAmount == 0) break;
      await handleScan(await (scansDir.list().first));
    }

    running = false;
  }

  Future<void> handleScan(FileSystemEntity? scannedDocument) async {
    await API.instance!.uploadFile(scannedDocument!.path);
    await scannedDocument.delete();
  }

  Future<void> scanDocument() async {
    // EdgeDetection.useInternalStorage(true);
    String? imagePath = await EdgeDetection.detectEdge;
    File(imagePath!).rename(scansDir.path + "/" + imagePath.split("/").last);
    handleScans();
  }
}
