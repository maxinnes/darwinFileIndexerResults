import 'package:flutter/material.dart';
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
        displayContent = const StarContent();
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
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
                            const StartScanDialog(),
                      );
                    },
                    child: const Text("New scan"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      startScan(context);
                    },
                    child: const Text("testing"),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text("Button 3"),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text("Button 4"),
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

class StartScanDialog extends StatelessWidget {
  const StartScanDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 300,
        width: 300,
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Waiting for scan to complete",
              style: TextStyle(fontSize: 20),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        ),
      ),
    );
  }
}

class StarContent extends StatelessWidget {
  const StarContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 728,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
        child: Column(
          children: const [
            Text(
              "Previous Scans",
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
