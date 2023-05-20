// Dart in-built
import 'dart:io';
import 'dart:typed_data';

// Packages
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// Tools
import '../tools.dart';

enum ConnectionStatus {
  disconnected,
  connecting,
  integrityCheck,
  transfering,
  failed,
  connected,
  finished,
}

class ConnectAndTransferModel extends ChangeNotifier {
  SSHClient? _sshClient;
  List _tableData = [];

  // Getters
  SSHClient? get sshClient => _sshClient;
  List get tableData => _tableData;

  void setSshClient(SSHClient newClient) {
    _sshClient = newClient;
    notifyListeners();
  }

  void setTableData(List newData) {
    _tableData = newData;
    notifyListeners();
  }

  void startScan() async {
    // File stuff
    Directory documentPath = await getApplicationDocumentsDirectory();
    String documentPathString = documentPath.path;

    // Execute scan
    await _sshClient?.run('/usr/local/bin/dfi');

    // Create scan folder
    List dbContents = await getJsonFileContents();
    int dbContentsLength = dbContents.length + 1;
    String newDirectoryPath = '$documentPathString/scans/$dbContentsLength';
    Directory(newDirectoryPath).createSync(recursive: true);

    // Download results
    var sftp = await _sshClient?.sftp();
    var remoteFile =
        await sftp?.open('/var/root/file_info.db', mode: SftpFileOpenMode.read);
    Uint8List data = await remoteFile!.readBytes();

    File localFile = File('$newDirectoryPath/file_info.db');
    localFile.writeAsBytesSync(data);

    // Once downloaded remove from phone
    await _sshClient?.run('rm -f /var/root/file_info.db');

    // Update DB
    Map<String, Object> newDbRecord = {
      "id": dbContentsLength,
      "dateTaken": DateTime.now().millisecondsSinceEpoch,
      "dbLocation": localFile.path
    };
    dbContents.add(newDbRecord);
    writeJsonFileContents(dbContents);
    _tableData = dbContents;

    notifyListeners();
  }
}
