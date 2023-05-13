// Dart in-built
import 'dart:io';

// Packages
import 'package:flutter/material.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

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
  List<String> messageTrace = [];

  void updateConnectionStatus(
      ConnectionStatus updatedStatus, String newMessage) {
    curruntStatus = updatedStatus;
    messageTrace.add(newMessage);
    notifyListeners();
  }

  // void connectClient(
  //   String ipAddress,
  //   String password, {
  //   int? port = 22,
  //   String username = "root",
  // }) async {
  // void connectClient() async {
  //   String ipAddress = "127.0.0.1";
  //   int port = 2222;
  //   String username = "root";
  //   String password = "alpine";

  //   // Connecting
  //   messageTrace.add("Connecting...");
  //   curruntStatus = ConnectionStatus.connecting;
  //   notifyListeners();

  //   final client = SSHClient(
  //     await SSHSocket.connect(ipAddress, port),
  //     username: username,
  //     onPasswordRequest: () => password,
  //   );

  //   // Connected
  //   messageTrace.add("Connected to the Client!");
  //   curruntStatus = ConnectionStatus.connected;
  //   notifyListeners();

  //   // Create sftp client
  //   final sftpClient = await client.sftp();

  //   // Upload file
  //   const remotePath = '/usr/local/bin/dfi';
  //   final file = await sftpClient.open(
  //     remotePath,
  //     mode: SftpFileOpenMode.truncate |
  //         SftpFileOpenMode.write |
  //         SftpFileOpenMode.create,
  //   );

  //   // Get file from assets
  //   ByteData data = await rootBundle.load('assets/dfi');
  //   final buffer = data.buffer;
  //   final tempDir = await getTemporaryDirectory();
  //   File tempFile = await File('${tempDir.path}/dfi').writeAsBytes(
  //       buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));

  //   // Start upload
  //   messageTrace.add("Transfering executable to client...");
  //   curruntStatus = ConnectionStatus.transfering;
  //   notifyListeners();

  //   await file.write(tempFile.openRead().cast()).done;

  //   client.close();
  //   await client.done;

  //   messageTrace.add("Connected!");
  //   curruntStatus = ConnectionStatus.connected;
  //   notifyListeners();
  // }
}
