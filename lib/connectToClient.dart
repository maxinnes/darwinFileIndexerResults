import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';

enum ConnectionStatus {
  connecting,
  integrityCheck,
  transfering,
  failed,
  connected,
}

Future<void> connectAndTransferClient(
  String ipAddress,
  String password, {
  int? port = 22,
  String username = "root",
}) async {
  final client = SSHClient(
    await SSHSocket.connect(ipAddress, port!),
    username: username,
    onPasswordRequest: () => password,
  );

  // Create sftp client
  final sftp = await client.sftp();

  // Create directory
  await sftp.mkdir("/Library/Application Support/dfi");

  // Upload file
  const remotePath = '/Library/Application Support/dfi/darwinFileIndexer';
  final file = await sftp.open(
    remotePath,
    mode: SftpFileOpenMode.truncate |
        SftpFileOpenMode.write |
        SftpFileOpenMode.create,
  );
  print("Starting upload...");
  await file.write(File('darwinFileIndexer').openRead().cast()).done;
  // await file.write(File('darwinFileIndexer').openRead().cast());
  print('File transfer completed');

  client.close();
  await client.done;

  return Future(() => null);
}

void main() async {
  await connectAndTransferClient("127.0.0.1", "alpine", port: 2222);
}
