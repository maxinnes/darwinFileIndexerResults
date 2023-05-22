// In built librarys
import 'dart:io';
import 'dart:convert';

// Packages
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_size/window_size.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

// Init logger
var logger = Logger();

void startUpLoggeringInfo() async {
  var documentPath = await getApplicationDocumentsDirectory();
  var documentPathString = documentPath.path;
  final tempDir = await getTemporaryDirectory();
  final tempDirString = tempDir.path;

  logger.d('Document path: $documentPathString');
  logger.d('Temp path: $tempDirString');
}

void setUpWindow() {
  const double windowWidth = 800;
  const double windowHeight = 625;

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();
    setWindowTitle('Darwin File Indexer');
    setWindowMinSize(const Size(windowWidth, windowHeight));
    setWindowMaxSize(const Size(windowWidth, windowHeight));
    getCurrentScreen().then((screen) {
      setWindowFrame(Rect.fromCenter(
        center: screen!.frame.center,
        width: windowWidth,
        height: windowHeight,
      ));
    });
  }
}

void myTestingFunction() async {
  // TODO look how to use CancelableCompleter. Refer to chatGPT
  print("test");
  var completer = CancelableCompleter<String>();
  var operation = completer.operation;

  operation.valueOrCancellation().then((value) {
    if (value == null) {
      print('Operation was cancelled.');
    } else {
      print('Operation completed with value: $value');
    }
  });
}

void doesJsonFileExist() async {
  var documentPath = await getApplicationDocumentsDirectory();
  var documentPathString = documentPath.path;
  var fileName = "results.json";

  var jsonFile = File("$documentPathString/$fileName");

  if (!jsonFile.existsSync()) {
    jsonFile.createSync();
    var jsonData = json.encode([]);
    jsonFile.writeAsString(jsonData);
  }
}

Future<List> getJsonFileContents() async {
  var documentPath = await getApplicationDocumentsDirectory();
  var documentPathString = documentPath.path;
  var fileName = "results.json";
  var jsonFile = File("$documentPathString/$fileName");

  var data = json.decode(jsonFile.readAsStringSync());

  return data;
}

void writeJsonFileContents(var data) async {
  var documentPath = await getApplicationDocumentsDirectory();
  var documentPathString = documentPath.path;
  var fileName = "results.json";
  var jsonFile = File("$documentPathString/$fileName");

  var newData = json.encode(data);
  jsonFile.writeAsStringSync(newData);
}
