// Dart in-built
import 'dart:io';

// Packages
import 'package:flutter/material.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Pages
import 'dashboard_page.dart';

// Models
import '../models/connect_and_transfer_model.dart';

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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
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
  const LoadingDialog({super.key});

  @override
  State<LoadingDialog> createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> {
  // State
  ConnectionStatus curruntStatus = ConnectionStatus.disconnected;
  List<String> messageTrace = [];

  void connectClient() async {
    String ipAddress = "127.0.0.1";
    int port = 2222;
    String username = "root";
    String password = "alpine";

    // Connecting
    setState(() {
      curruntStatus = ConnectionStatus.connecting;
      messageTrace.add("Connecting...");
    });
    // messageTrace.add("Connecting...");
    // curruntStatus = ConnectionStatus.connecting;
    // notifyListeners();

    final client = SSHClient(
      await SSHSocket.connect(ipAddress, port),
      username: username,
      onPasswordRequest: () => password,
    );

    Provider.of<ConnectAndTransferModel>(context, listen: false)
        .setSshClient(client);

    // Connected
    setState(() {
      curruntStatus = ConnectionStatus.connected;
      messageTrace.add("Connected to the Client!");
    });
    // messageTrace.add("Connected to the Client!");
    // curruntStatus = ConnectionStatus.connected;
    // notifyListeners();

    // Create sftp client
    final sftpClient = await client.sftp();

    // Upload file
    const remotePath = '/usr/local/bin/dfi';
    final file = await sftpClient.open(
      remotePath,
      mode: SftpFileOpenMode.truncate |
          SftpFileOpenMode.write |
          SftpFileOpenMode.create,
    );

    // Start upload
    setState(() {
      curruntStatus = ConnectionStatus.transfering;
      messageTrace.add("Transfering executable to client...");
    });

    // Get file from assets
    ByteData data = await rootBundle.load('assets/dfi');
    final buffer = data.buffer;
    final tempDir = await getTemporaryDirectory();
    File tempFile = await File('${tempDir.path}/dfi').writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));

    // Start upload
    // setState(() {
    //   curruntStatus = ConnectionStatus.transfering;
    //   messageTrace.add("Transfering executable to client...");
    // });
    // messageTrace.add("Transfering executable to client...");
    // curruntStatus = ConnectionStatus.transfering;
    // notifyListeners();

    await file.write(tempFile.openRead().cast()).done;

    // Make executable
    var currentFileAttributes = await file.stat();
    var newFileMode = SftpFileMode(
      userRead: true,
      userWrite: true,
      userExecute: true,
      groupRead: true,
      groupWrite: false,
      groupExecute: false,
      otherRead: true,
      otherWrite: false,
      otherExecute: false,
    );
    var newFileAttributes = SftpFileAttrs(
      size: currentFileAttributes.size,
      userID: 0,
      groupID: 0,
      mode: newFileMode,
      accessTime: currentFileAttributes.accessTime,
      modifyTime: currentFileAttributes.modifyTime,
      extended: currentFileAttributes.extended,
    );
    await file.setStat(newFileAttributes);

    // client.close();
    // await client.done;

    // Done
    setState(() {
      curruntStatus = ConnectionStatus.finished;
      messageTrace.add("Connected!");
    });
    // messageTrace.add("Connected!");
    // curruntStatus = ConnectionStatus.connected;
    // notifyListeners();
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
                onPressed: curruntStatus == ConnectionStatus.finished
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const DashboardPage(),
                          ),
                        );
                      }
                    : () => Navigator.pop(context),
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
