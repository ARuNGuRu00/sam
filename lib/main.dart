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
      title: 'Bluetooth Devices',
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
  final BluetoothClassic bluetooth = BluetoothClassic();

  List<dynamic> devices = [];

  @override
  void initState() {
    super.initState();
    requestPermissions();
    getDevices();
  }

  Future<void> requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  Future<void> getDevices() async {
    try {
      await bluetooth.initPermissions();

      List<dynamic> paired = await bluetooth.getPairedDevices();

      setState(() {
        devices = paired;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paired Bluetooth Devices")),

      body: devices.isEmpty
          ? const Center(child: Text("Press refresh to load devices"))
          : ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                var device = devices[index];

                return ListTile(
                  leading: const Icon(Icons.bluetooth),
                  title: Text(device.name ?? "Unknown Device"),
                  subtitle: Text(device.address),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: getDevices,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
