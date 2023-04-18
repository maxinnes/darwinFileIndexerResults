import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  // Window Options
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.setResizable(false);
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
      ),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Darwin File Indexer Results',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(100, 25, 100, 25),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Instructions",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                  Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Commodo ullamcorper a lacus vestibulum sed. Malesuada bibendum arcu vitae elementum curabitur. Amet tellus cras adipiscing enim. Volutpat lacus laoreet non curabitur gravida arcu ac.\n\n1. Jailbreak device\n2. Install a SSH client on the device\n3. Connect device to this device\n4. Enter the SSH",
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "SSH Credentials",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                  Row(
                    children: const [
                      SizedBox(
                        width: 140,
                        height: 50,
                        child: TextField(
                          decoration: InputDecoration(labelText: "IP Address"),
                        ),
                      ),
                      Text(
                        ":",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 55,
                        height: 50,
                        child: TextField(
                          decoration: InputDecoration(labelText: "Port"),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    width: 206,
                    height: 50,
                    child: TextField(
                      decoration: InputDecoration(labelText: "Username"),
                    ),
                  ),
                  const SizedBox(
                    width: 206,
                    height: 50,
                    child: TextField(
                      decoration: InputDecoration(labelText: "Password"),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
