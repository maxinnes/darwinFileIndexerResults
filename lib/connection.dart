// Native Libraries
import 'dart:io';

// Packages
import 'package:dartssh2/dartssh2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

// Models
import 'models/connect_and_transfer_model.dart';

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
    // callbackFunction(ConnectionStatus.connecting, "Connecting...");

    // Testing only
    print("BEGIN DELAY");
    await Future.delayed(const Duration(seconds: 5));
    print("ENDED DELAY");

    var sshClient = SSHClient(
      await SSHSocket.connect(ipAddress, port),
      username: username,
      onPasswordRequest: () => password,
    );

    yield {
      "connectionStatus": ConnectionStatus.connected,
      "newStatusMessage": "Connected to the Client!"
    };
    // callbackFunction(ConnectionStatus.connected, "Connected to the Client!");

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
    // callbackFunction(
    //     ConnectionStatus.transfering, "Transfering executable to client...");

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
      "newStatusMessage": "Connected!"
    };
    // callbackFunction(
    //   ConnectionStatus.finished,
    //   "Connected!",
    // );

    // Testing only
    print("Function ended");
  }
}
