// In built librarys
import 'dart:io';
import 'dart:convert';

// Packages
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_size/window_size.dart';
import 'package:flutter/foundation.dart';

void startUpLoggeringInfo() async {
  var documentPath = await getApplicationDocumentsDirectory();
  var documentPathString = documentPath.path;
  print("Document path: $documentPathString");

  // logger.d("Document path: $documentPathString");
}

void setUpWindow() {
  const double windowWidth = 800;
  const double windowHeight = 625;

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();
    setWindowTitle('Provider Demo');
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
  print("===== NEW =====");
  var dbContents = await getJsonFileContents();
  var dbContentsLength = dbContents.length;
  print("Length before: $dbContentsLength");

  if (dbContentsLength == 0) print("If statement triggered");

  var newDbRecord = {"dateTaken": DateTime.now().millisecondsSinceEpoch};
  dbContents.add(newDbRecord);
  writeJsonFileContents(dbContents);
  dbContents = await getJsonFileContents();
  dbContentsLength = dbContents.length;
  print("Length after: $dbContentsLength");
}

void doesJsonFileExist() async {
  var documentPath = await getApplicationDocumentsDirectory();
  var documentPathString = documentPath.path;
  var fileName = "results.json";

  var jsonFile = File("$documentPathString/$fileName");

  if (jsonFile.existsSync()) {
    print("It exists");
  } else {
    print("It doesnt exist");
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
