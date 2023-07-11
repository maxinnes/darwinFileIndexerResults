// Native Libraries
import 'dart:io';

// Packages
import 'package:dartssh2/dartssh2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

// Models
import 'models/connect_and_transfer_model.dart';

import 'tools.dart';

class ConnectAndTransferOperations {
  static Stream<Map<String, dynamic>> connectClient() async* {
    String ipAddress = "127.0.0.1";
    int port = 2222;
    String username = "root";
    String password = "alpine";

    yield {
      "connectionStatus": ConnectionStatus.connecting,
      "newStatusMessage": "Connecting..."
    };

    var sshClient = SSHClient(
      await SSHSocket.connect(ipAddress, port),
      username: username,
      onPasswordRequest: () => password,
    );

    yield {
      "connectionStatus": ConnectionStatus.connected,
      "newStatusMessage": "Connected to the Client!"
    };

    final sftpClient = await sshClient.sftp();
    const remotePath = '/usr/local/bin/dfi';
    final file = await sftpClient.open(
      remotePath,
      mode: SftpFileOpenMode.truncate |
          SftpFileOpenMode.write |
          SftpFileOpenMode.create,
    );

    yield {
      "connectionStatus": ConnectionStatus.transfering,
      "newStatusMessage": "Transfering executable to client..."
    };

    // Get file from assets
    final ByteData data = await rootBundle.load('assets/dfi');
    final buffer = data.buffer;
    final tempDir = await getTemporaryDirectory();
    final File tempFile = await File('${tempDir.path}/dfi').writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));

    await file.write(tempFile.openRead().cast()).done;
    var currentFileAttributes = await file.stat();
    var newFileMode = SftpFileMode(
      userRead: true,
      userWrite: true,
      userExecute: true,
      groupRead: true,
      groupWrite: false,
      groupExecute: false,
      otherRead: true,
      otherWrite: false,
      otherExecute: false,
    );
    var newFileAttributes = SftpFileAttrs(
      size: currentFileAttributes.size,
      userID: 0,
      groupID: 0,
      mode: newFileMode,
      accessTime: currentFileAttributes.accessTime,
      modifyTime: currentFileAttributes.modifyTime,
      extended: currentFileAttributes.extended,
    );
    await file.setStat(newFileAttributes);

    tempFile.deleteSync();

    yield {
      "connectionStatus": ConnectionStatus.finished,
      "newStatusMessage": "Connected!",
      "result": sshClient
    };
  }

  static Stream<Map<String, dynamic>> startScan() async* {
    print("===== Connecting =====");
    // Connect SSH client
    String ipAddress = "127.0.0.1";
    int port = 2222;
    String username = "root";
    String password = "alpine";

    var sshClient = SSHClient(
      await SSHSocket.connect(ipAddress, port),
      username: username,
      onPasswordRequest: () => password,
    );

    print("===== Connected =====");

    print("===== Starting scan =====");
    // File stuff
    Directory documentPath = await getApplicationDocumentsDirectory();
    String documentPathString = documentPath.path;

    // Execute scan
    yield {
      "nextStatus": ScanStatus.startedScan,
      "nextMessage": "Started Scan..."
    };
    // callbackFunction(ScanStatus.startedScan, "Started Scan...");

    // bool isScanComplete = false;
    await sshClient.run('/usr/local/bin/dfi');
    // .whenComplete(() => isScanComplete = true);

    // while (!isScanComplete) {
    // await Future.delayed(const Duration(seconds: 1));
    // yield {
    //   "nextStatus": ScanStatus.startedScan,
    //   "nextMessage": "Waiting...",
    // };
    // }

    yield {
      "nextStatus": ScanStatus.finishedScan,
      "nextMessage": "Finished Scan!"
    };
    // callbackFunction(ScanStatus.finishedScan, "Finished Scan!!!");

    // Create scan folder
    List dbContents = await getJsonFileContents();
    int dbContentsLength = dbContents.length + 1;
    String newDirectoryPath = '$documentPathString/scans/$dbContentsLength';
    Directory(newDirectoryPath).createSync(recursive: true);

    // Download results
    var sftp = await sshClient.sftp();
    var remoteFile =
        await sftp.open('/var/root/file_info.db', mode: SftpFileOpenMode.read);
    yield {
      "nextStatus": ScanStatus.downloadingResults,
      "nextMessage": "Downloading results..."
    };
    // callbackFunction(ScanStatus.downloadingResults, "Downloading results...");
    Uint8List data = await remoteFile.readBytes();

    File localFile = File('$newDirectoryPath/file_info.db');
    localFile.writeAsBytesSync(data);

    // Once downloaded remove from phone
    yield {
      "nextStatus": ScanStatus.removingResultsFromRemoteDevice,
      "nextMessage":
          "Finished Downloading!\nDeleting results from remote device...",
    };
    // callbackFunction(ScanStatus.removingResultsFromRemoteDevice,
    //     "Finished Downloading!\nDeleting results from remote device...");
    await sshClient.run('rm -f /var/root/file_info.db');

    // Update DB
    Map<String, Object> newDbRecord = {
      "id": dbContentsLength,
      "dateTaken": DateTime.now().millisecondsSinceEpoch,
      "dbLocation": localFile.path
    };
    dbContents.add(newDbRecord);
    writeJsonFileContents(dbContents);
    var tableData = dbContents;

    yield {
      "nextStatus": ScanStatus.complete,
      "nextMessage": "Everything is finished!",
      "result": tableData
    };
    // callbackFunction(ScanStatus.complete, "Everything is finished!");
  }
}
