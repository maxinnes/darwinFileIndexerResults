// Packages
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Models
import '../models/connect_and_transfer_model.dart';

// Tools
import '../tools.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  changeDestination(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget displayContent = const MainContent();

    switch (_selectedIndex) {
      case 0:
        displayContent = const MainContent();
        break;
      case 1:
        displayContent = const ScanContent();
        break;
      default:
    }

    return Scaffold(
        body: Row(
      children: [
        NavigationRail(
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.house_outlined),
              selectedIcon: Icon(Icons.house),
              label: Text('Home'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.table_chart_outlined),
              selectedIcon: Icon(Icons.table_chart),
              label: Text('Scans'),
            )
          ],
          selectedIndex: _selectedIndex,
          onDestinationSelected: changeDestination,
          labelType: NavigationRailLabelType.all,
          elevation: 5,
          leading: const SizedBox(height: 10),
        ),
        displayContent
      ],
    ));
  }
}

class MainContent extends StatelessWidget {
  const MainContent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 728,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "iPhone",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  "Dashboard",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  "Status:",
                  textAlign: TextAlign.end,
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) =>
                              const StartScanDialog());
                      // context.read<ConnectAndTransferModel>().startScan();
                    },
                    child: const Text("New scan"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      myTestingFunction();
                    },
                    child: const Text("testing"),
                  ),
                  const ElevatedButton(
                    onPressed: null,
                    child: Text("Button 3"),
                  ),
                  const ElevatedButton(
                    onPressed: null,
                    child: Text("Button 4"),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class StartScanDialog extends StatefulWidget {
  const StartScanDialog({
    super.key,
  });

  @override
  State<StartScanDialog> createState() => _StartScanDialogState();
}

class _StartScanDialogState extends State<StartScanDialog> {
  ScanStatus currentStatus = ScanStatus.waitingToStart;
  List<String> messages = ["Waiting to start"];

  void updateScanStatus(ScanStatus newStatus, String newMessage) {
    setState(() {
      currentStatus = newStatus;
      messages.add(newMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    String modelTitle = "Waiting to start scan";
    String btnText = "Cancel";
    List<Widget> modelMessages = [];

    for (String message in messages) {
      modelMessages.add(Text(message));
    }

    if (currentStatus == ScanStatus.waitingToStart) {
      context.read<ConnectAndTransferModel>().startScan(updateScanStatus);
    }

    switch (currentStatus) {
      case ScanStatus.waitingToStart:
        break;
      case ScanStatus.startedScan:
        modelTitle = "Now scanning";
        break;
      case ScanStatus.finishedScan:
      case ScanStatus.downloadingResults:
        modelTitle = "Downloading results";
        break;
      case ScanStatus.removingResultsFromRemoteDevice:
      case ScanStatus.complete:
        modelTitle = "Finished";
        btnText = "Done";
        break;
    }

    return Dialog(
      child: Container(
        height: 300,
        width: 300,
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Text(
                modelTitle,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            Expanded(
              child: ListView(
                children: modelMessages,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(btnText),
            ),
          ],
        ),
      ),
    );
  }
}

class ScanContent extends StatelessWidget {
  const ScanContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 728,
      padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
      child: const Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: Text(
              "Previous Scans",
              style: TextStyle(fontSize: 20),
            ),
          ),
          ScansTable()
        ],
      ),
    );
  }
}

class ScansTable extends StatelessWidget {
  const ScansTable({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    List tableData = context.watch<ConnectAndTransferModel>().tableData;

    List<TableRow> dataRows = [
      const TableRow(children: [
        Padding(
          padding: EdgeInsets.all(5.0),
          child: Text("ID"),
        ),
        Padding(
          padding: EdgeInsets.all(5.0),
          child: Text("Date"),
        ),
        Padding(
          padding: EdgeInsets.all(5.0),
          child: Text("File path"),
        ),
      ])
    ];

    for (var row in tableData) {
      int timestamp = row["dateTaken"];
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      String format = 'yyyy-MM-dd HH:mm:ss';
      DateFormat formatter = DateFormat(format);
      String formattedDate = formatter.format(dateTime);

      dataRows.add(TableRow(children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(row["id"].toString()),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(formattedDate),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(row["dbLocation"]),
        )
      ]));
    }

    return Table(
      // columnWidths: const {0: FractionColumnWidth(.05)}, IntrinsicColumnWidth
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: IntrinsicColumnWidth()
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder.all(color: Colors.white),
      children: dataRows,
    );
  }
}
