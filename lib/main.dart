// Packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

// Pages
import 'pages/landing_page.dart';

// Models
import 'models/connect_and_transfer_model.dart';

// Other
import 'tools.dart';

void main() async {
  // Check required files
  doesJsonFileExist();

  // Start window manager
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  // Configure window options
  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    // backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.setResizable(false);
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // runApp(const MyApp());
  runApp(ChangeNotifierProvider(
    create: (context) => ConnectAndTransferModel(),
    child: const MyApp(),
  ));
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
