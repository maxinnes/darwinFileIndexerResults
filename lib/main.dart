// Packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Pages
import 'pages/landing_page.dart';

// Models
import 'models/connect_and_transfer_model.dart';

// Other
import 'tools.dart';

void main() async {
  // set up window
  setUpWindow();
  // Check required files
  doesJsonFileExist();

  runApp(ChangeNotifierProvider(
    create: (context) => ConnectAndTransferModel(),
    child: const MyApp(),
  ));

  startUpLoggeringInfo();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    getJsonFileContents().then((jsonContents) => {
          context.read<ConnectAndTransferModel>().setTableData(jsonContents)
          // Provider.of<ConnectAndTransferModel>(context, listen: false)
          //     .setTableData(jsonContents)
        });
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
      ),
      home: const LandingPage(),
    );
  }
}
