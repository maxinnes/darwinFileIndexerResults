import 'dart:convert';
import 'dart:io';

import 'package:dartssh2/dartssh2.dart';

enum ConnectionStatus { connecting, transfering, failed, connected }

void connectAndTransferClient(
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

  final sftp = await client.sftp();
  final file = await sftp.open(
    'file.txt',
    mode: SftpFileOpenMode.truncate | SftpFileOpenMode.write,
  );

  await file.write(File('local_file.txt').openRead().cast()).done;
  print('done');

  client.close();
  await client.done;
}

void main() {
  connectAndTransferClient("127.0.0.1", "alpine", port: 2222);
}
