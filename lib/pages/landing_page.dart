// Packages
import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// Classes
import '../connection.dart';

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
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

  // TODO READ THIS
  // https://stackoverflow.com/questions/44450758/cancel-stream-ondata
  // Issue might be todo with the "late" statement
  late StreamSubscription connectionStreamSubscription;

  // void updateConnectionStatus(ConnectionStatus newStatus, String newMessage) {
  //   setState(() {
  //     curruntStatus = newStatus;
  //     messageTrace.add(newMessage);
  //   });
  // }

  Future<void> startConnection() async {
    var newConnectionStream = ConnectAndTransferOperations.connectClient();
    var newConnectionStreamSubscription = newConnectionStream.listen((event) {
      var newStatus = event["connectionStatus"];
      var newMessage = event["newStatusMessage"];
      setState(() {
        curruntStatus = newStatus;
        messageTrace.add(newMessage);
      });
    });

    setState(() {
      connectionStreamSubscription = newConnectionStreamSubscription;
    });
  }

  @override
  Widget build(BuildContext context) {
    var statusMessage = "Connecting...";
    List<Widget> userMessageLog = [];

    for (String message in messageTrace) {
      userMessageLog.add(Text(message));
    }

    if (curruntStatus == ConnectionStatus.disconnected) {
      startConnection();
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
                    : () {
                        connectionStreamSubscription.cancel();
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
