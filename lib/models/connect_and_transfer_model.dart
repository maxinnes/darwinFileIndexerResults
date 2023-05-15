// Dart in-built

// Packages
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
  SSHClient? _sshClient;
  List _tableData = [];

  SSHClient? get sshClient => _sshClient;
  List get tableData => _tableData;

  void setSshClient(SSHClient newClient) {
    _sshClient = newClient;
  }

  void setTableData(List newData) {
    _tableData = newData;
    notifyListeners();
  }
}
