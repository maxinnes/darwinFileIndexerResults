// Packages
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';

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
  SSHClient get sshClient => _sshClient;
  List get tableData => _tableData;

  void setSshClient(SSHClient newClient) {
    _sshClient = newClient;
    notifyListeners();
  }

  void setTableData(List newData) {
    _tableData = newData;
    notifyListeners();
  }
}
