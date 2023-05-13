// import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:window_manager/window_manager.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:path_provider/path_provider.dart';

import 'models/connect_and_transfer_model.dart';
// import 'tools.dart';

void main() async {
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

class LandingPage extends StatefulWidget {
  const LandingPage({
    super.key,
  });

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  // Form stuff
  final _formKey = GlobalKey<FormState>();

  // Text input validators
  bool isIpAddressFieldValid(String ipAddress) {
    RegExp exp = RegExp(r'^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$');
    bool isValid = exp.hasMatch(ipAddress);
    return isValid;
  }

  // Connect button control
  bool isDisabled = true;

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
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Instructions",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
                Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Commodo ullamcorper a lacus vestibulum sed. Malesuada bibendum arcu vitae elementum curabitur. Amet tellus cras adipiscing enim. Volutpat lacus laoreet non curabitur gravida arcu ac.\n\n1. Jailbreak device\n2. Install a SSH client on the device\n3. Connect device to this device\n4. Enter the SSH\n\nLeave the port field blank for default SSH port (22)",
                ),
              ],
            ),
            Form(
              onChanged: () {
                // If no errors
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    isDisabled = false;
                  });
                } else {
                  setState(() {
                    isDisabled = true;
                  });
                }
              },
              key: _formKey,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "SSH Credentials",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 140,
                              height: 75,
                              child: TextFormField(
                                validator: (value) {
                                  if (isIpAddressFieldValid(value!)) {
                                    return null;
                                  } else {
                                    return "IP Adress not valid";
                                  }
                                },
                                maxLength: 15,
                                decoration: const InputDecoration(
                                  labelText: "IP Address",
                                  counterText: "",
                                ),
                              ),
                            ),
                            const Text(
                              ":",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              width: 55,
                              height: 75,
                              child: TextFormField(
                                maxLength: 5,
                                decoration: const InputDecoration(
                                  labelText: "Port",
                                  counterText: "",
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          width: 206,
                          height: 75,
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "This field cannot be empty";
                              } else {
                                return null;
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: "Username",
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 206,
                          height: 75,
                          child: TextFormField(
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "Password",
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: SizedBox(
                      height: 204,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: isDisabled
                                ? null
                                : () {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) =>
                                          const LoadingDialog(),
                                    );
                                  },
                            child: const Text("Connect"),
                          ),
                        ],
                      ),
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

class LoadingDialog extends StatefulWidget {
  const LoadingDialog({
    super.key,
  });

  @override
  State<LoadingDialog> createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> {
  ConnectionStatus curruntStatus = ConnectionStatus.disconnected;
  List<String> messageTrace = [];

  // void connectClient(
  //   String ipAddress,
  //   String password, {
  //   int? port = 22,
  //   String username = "root",
  // }) async {
  void connectClient() async {
    String ipAddress = "127.0.0.1";
    int port = 2222;
    String username = "root";
    String password = "alpine";

    // sleep(const Duration(seconds: 2));

    setState(() {
      curruntStatus = ConnectionStatus.connecting;
      messageTrace.add("Connecting...");
    });
    // changeStatus(ConnectionStatus.connecting,
    //     message: "Waiting to connect to client");

    final client = SSHClient(
      await SSHSocket.connect(ipAddress, port),
      username: username,
      onPasswordRequest: () => password,
    );

    setState(() {
      curruntStatus = ConnectionStatus.connected;
      messageTrace.add("Connected to the Client!");
    });
    // changeStatus(ConnectionStatus.connected,
    //     message: "Successfully connected to client");

    final sftpClient = await client.sftp();

    // Create directory
    // await sftpClient.mkdir("/Library/Application Support/dfi");

    setState(() {
      curruntStatus = ConnectionStatus.transfering;
      messageTrace.add("Transfering executable to client...");
    });
    // changeStatus(ConnectionStatus.transfering,
    //     message: "Uploading program to client");

    // Upload file
    const remotePath = '/usr/local/bin/dfi';
    final file = await sftpClient.open(
      remotePath,
      mode: SftpFileOpenMode.truncate |
          SftpFileOpenMode.write |
          SftpFileOpenMode.create,
    );

    // Get file from assets
    ByteData data = await rootBundle.load('assets/dfi');
    final buffer = data.buffer;
    final tempDir = await getTemporaryDirectory();
    File tempFile = await File('${tempDir.path}/dfi').writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));

    // Start upload
    print(Directory.current);
    print('breakpoint');

    await file.write(tempFile.openRead().cast()).done;

    client.close();
    await client.done;

    setState(() {
      curruntStatus = ConnectionStatus.finished;
      messageTrace.add("Finished!");
    });
  }

  @override
  void initState() {
    super.initState();

    connectClient();
  }

  @override
  Widget build(BuildContext context) {
    var statusMessage = "Connecting...";
    List<Widget> userMessageLog = [];

    for (String message in messageTrace) {
      userMessageLog.add(Text(message));
    }

    switch (curruntStatus) {
      case ConnectionStatus.disconnected:
      case ConnectionStatus.connecting:
        break;
      case ConnectionStatus.transfering:
        statusMessage = "Transfering...";
        break;
      case ConnectionStatus.finished:
        statusMessage = "Finished!";
        break;
      default:
    }

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
        child: SizedBox(
          width: 100,
          height: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: Text(statusMessage),
                  ),
                  const SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(),
                  )
                ],
              ),
              SizedBox(
                height: 175,
                width: 260,
                child: ListView(
                  children: userMessageLog,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: curruntStatus == ConnectionStatus.finished
                    ? const Text("Finished")
                    : const Text("Cancel"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
