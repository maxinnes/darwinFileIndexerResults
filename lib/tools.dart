// In built librarys
import 'dart:io';
import 'dart:convert';

// Packages
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

// Models
import 'models/connect_and_transfer_model.dart';

void startScan(BuildContext context) async {
  // File stuff
  var documentPath = await getApplicationDocumentsDirectory();
  var documentPathString = documentPath.path;

  // Execute scan
  print("Starting SCAN!!!");
  SSHClient? client =
      Provider.of<ConnectAndTransferModel>(context, listen: false).sshClient;
  final uptime = await client?.run('/usr/local/bin/dfi');
  print(utf8.decode(uptime!));
  print("FINISHED SCAN!!!");

  // Create scan folder
  var dbContents = await getJsonFileContents();
  var dbContentsLength = dbContents.length;
  if (dbContentsLength == 0) dbContentsLength = 1;
  var newDirectoryPath = '$documentPathString/scans/$dbContentsLength';
  Directory(newDirectoryPath).createSync(recursive: true);

  // Download results
  var sftp = await client?.sftp();
  var remoteFile =
      await sftp?.open('/var/root/file_info.db', mode: SftpFileOpenMode.read);
  var data = await remoteFile?.readBytes();

  var localFile = File('$newDirectoryPath/file_info.db');
  await localFile.writeAsBytes(data!); // Write bytes directly to the file
  print("File downloaded");

  await client?.run('rm -f /var/root/file_info.db');
  print("Removed previous file");

  var newDbRecord = {
    "id": dbContentsLength,
    "dateTaken": DateTime.now().millisecondsSinceEpoch,
    "dbLocation": localFile.path
  };
  dbContents.add(newDbRecord);
  writeJsonFileContents(dbContents);
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

void writeJsonFileContents(dynamic data) async {
  var documentPath = await getApplicationDocumentsDirectory();
  var documentPathString = documentPath.path;
  var fileName = "results.json";
  var jsonFile = File("$documentPathString/$fileName");

  var newData = json.encode(data);
  jsonFile.writeAsStringSync(newData);
}
