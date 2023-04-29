import 'dart:convert';
import 'dart:io';

import 'package:dartssh2/dartssh2.dart';

void connectAndTransferClient(String ipAddress, int port) async {
  final client = SSHClient(
    await SSHSocket.connect('localhost', 22),
    username: 'root',
    onPasswordRequest: () => 'alpine',
  );

  final sftp = await client.sftp();
  final items = await sftp.listdir('/');
  for (final item in items) {
    print(item.longname);
  }

  client.close();
  await client.done;
}

void main() {
  connectAndTransferClient("test", 12);
}
