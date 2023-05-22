// Dart in-built
import 'dart:io';

// Packages
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

// Tools
import '../tools.dart';

// enums
enum ConnectionStatus {
  disconnected,
  connecting,
  integrityCheck,
  transfering,
  failed,
  connected,
  finished,
}

enum ScanStatus {
  waitingToStart,
  startedScan,
  finishedScan,
  downloadingResults,
  removingResultsFromRemoteDevice,
  complete
}

class ConnectAndTransferModel extends ChangeNotifier {
  late SSHClient _sshClient;
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

  void connectClient(
      void Function(ConnectionStatus, String) callbackFunction) async {
    String ipAddress = "127.0.0.1";
    int port = 2222;
    String username = "root";
    String password = "alpine";

    callbackFunction(ConnectionStatus.connecting, "Connecting...");

    _sshClient = SSHClient(
      await SSHSocket.connect(ipAddress, port),
      username: username,
      onPasswordRequest: () => password,
    );

    callbackFunction(ConnectionStatus.connected, "Connected to the Client!");

    final sftpClient = await _sshClient.sftp();
    const remotePath = '/usr/local/bin/dfi';
    final file = await sftpClient.open(
      remotePath,
      mode: SftpFileOpenMode.truncate |
          SftpFileOpenMode.write |
          SftpFileOpenMode.create,
    );

    callbackFunction(
        ConnectionStatus.transfering, "Transfering executable to client...");

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

    callbackFunction(
      ConnectionStatus.finished,
      "Connected!",
    );
  }

  void startScan(void Function(ScanStatus, String) callbackFunction) async {
    print("===== Starting scan =====");
    // File stuff
    Directory documentPath = await getApplicationDocumentsDirectory();
    String documentPathString = documentPath.path;

    // Execute scan
    callbackFunction(ScanStatus.startedScan, "Started Scan...");
    await _sshClient.run('/usr/local/bin/dfi');
    callbackFunction(ScanStatus.finishedScan, "Finished Scan!!!");

    // Create scan folder
    List dbContents = await getJsonFileContents();
    int dbContentsLength = dbContents.length + 1;
    String newDirectoryPath = '$documentPathString/scans/$dbContentsLength';
    Directory(newDirectoryPath).createSync(recursive: true);

    // Download results
    var sftp = await _sshClient.sftp();
    var remoteFile =
        await sftp.open('/var/root/file_info.db', mode: SftpFileOpenMode.read);
    callbackFunction(ScanStatus.downloadingResults, "Downloading results...");
    Uint8List data = await remoteFile.readBytes();

    File localFile = File('$newDirectoryPath/file_info.db');
    localFile.writeAsBytesSync(data);

    // Once downloaded remove from phone
    callbackFunction(ScanStatus.removingResultsFromRemoteDevice,
        "Finished Downloading!\nDeleting results from remote device...");
    await _sshClient.run('rm -f /var/root/file_info.db');

    // Update DB
    Map<String, Object> newDbRecord = {
      "id": dbContentsLength,
      "dateTaken": DateTime.now().millisecondsSinceEpoch,
      "dbLocation": localFile.path
    };
    dbContents.add(newDbRecord);
    writeJsonFileContents(dbContents);
    _tableData = dbContents;

    callbackFunction(ScanStatus.complete, "Everything is finished!");
    notifyListeners();
  }
}
