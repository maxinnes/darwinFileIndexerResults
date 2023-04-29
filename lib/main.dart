import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:window_manager/window_manager.dart';
import 'package:dartssh2/dartssh2.dart';

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

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
        child: SizedBox(
          width: 100,
          height: 250,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("Connecting...   "),
                  SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(),
                  )
                ],
              ),
              SizedBox(
                height: 225,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
