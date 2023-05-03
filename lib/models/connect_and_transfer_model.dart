import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';

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
  ConnectionStatus curruntStatus = ConnectionStatus.disconnected;
  List messageTrace = [];
  // SSHClient? client = null;

  void changeStatus(ConnectionStatus status, {String message = ""}) {
    curruntStatus = status;
    messageTrace.add(message);
    notifyListeners();
  }

  void connectClient(
    String ipAddress,
    String password, {
    int? port = 22,
    String username = "root",
  }) async {
    changeStatus(ConnectionStatus.connecting,
        message: "Waiting to connect to client");

    final client = SSHClient(
      await SSHSocket.connect(ipAddress, port!),
      username: username,
      onPasswordRequest: () => password,
    );

    changeStatus(ConnectionStatus.connected,
        message: "Successfully connected to client");

    final sftpClient = await client.sftp();

    // Create directory
    await sftpClient.mkdir("/Library/Application Support/dfi");

    changeStatus(ConnectionStatus.transfering,
        message: "Uploading program to client");

    // Upload file
    const remotePath = '/Library/Application Support/dfi/darwinFileIndexer';
    final file = await sftpClient.open(
      remotePath,
      mode: SftpFileOpenMode.truncate |
          SftpFileOpenMode.write |
          SftpFileOpenMode.create,
    );
    // print("Starting upload...");
    await file.write(File('darwinFileIndexer').openRead().cast()).done;
    // await file.write(File('darwinFileIndexer').openRead().cast());
    // print('File transfer completed');

    changeStatus(ConnectionStatus.connected, message: "Finished!");

    client.close();
    await client.done;
  }
}

// Future<void> connectAndTransferClient(
//   String ipAddress,
//   String password, {
//   int? port = 22,
//   String username = "root",
// }) async {
//   final client = SSHClient(
//     await SSHSocket.connect(ipAddress, port!),
//     username: username,
//     onPasswordRequest: () => password,
//   );

//   // Create sftp client
//   final sftp = await client.sftp();

//   // Create directory
//   await sftp.mkdir("/Library/Application Support/dfi");

//   // Upload file
//   const remotePath = '/Library/Application Support/dfi/darwinFileIndexer';
//   final file = await sftp.open(
//     remotePath,
//     mode: SftpFileOpenMode.truncate |
//         SftpFileOpenMode.write |
//         SftpFileOpenMode.create,
//   );
//   print("Starting upload...");
//   await file.write(File('darwinFileIndexer').openRead().cast()).done;
//   // await file.write(File('darwinFileIndexer').openRead().cast());
//   print('File transfer completed');

//   client.close();
//   await client.done;

//   return Future(() => null);
// }

// void main() async {
//   await connectAndTransferClient("127.0.0.1", "alpine", port: 2222);
// }
