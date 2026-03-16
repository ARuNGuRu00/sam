import 'package:flutter/material.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Bluetooth Devices",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String devicesText = "Press button to load devices";

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  // Request runtime permissions
  Future<void> requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  // Get paired devices
  Future<void> getDevices() async {
    final bluetooth = BluetoothClassic();

    try {
      await bluetooth.initPermissions();

      List devices = await bluetooth.getPairedDevices();

      setState(() {
        devicesText = devices.toString();
      });
    } catch (e) {
      setState(() {
        devicesText = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paired Bluetooth Devices")),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              const Text(
                "Bluetooth Paired Devices",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              Text(devicesText, textAlign: TextAlign.center),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: getDevices,
                child: const Text("Get Paired Devices"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
