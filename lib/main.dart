import 'dart:typed_data';
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
      title: "Bluetooth Controller",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const BluetoothPage(),
    );
  }
}

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  final BluetoothClassic bluetooth = BluetoothClassic();

  List<dynamic> devices = [];
  Uint8List receivedData = Uint8List(0);

  bool connected = false;

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
    await bluetooth.initPermissions();

    List<dynamic> paired = await bluetooth.getPairedDevices();

    setState(() {
      devices = paired;
    });
  }

  // Connect to selected device
  Future<void> connectDevice(String address) async {
    try {
      await bluetooth.connect(address, "00001101-0000-1000-8000-00805f9b34fb");

      bluetooth.onDeviceDataReceived().listen((event) {
        setState(() {
          receivedData = Uint8List.fromList([...receivedData, ...event]);
        });
      });

      setState(() {
        connected = true;
      });
    } catch (e) {
      print("Connection error: $e");
    }
  }

  // Send data
  Future<void> sendData() async {
    if (connected) {
      await bluetooth.write("ping");
    }
  }

  // Disconnect
  Future<void> disconnectDevice() async {
    await bluetooth.disconnect();

    setState(() {
      connected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bluetooth Devices")),

      body: Column(
        children: [
          ElevatedButton(
            onPressed: getDevices,
            child: const Text("Load Paired Devices"),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                var device = devices[index];

                return ListTile(
                  leading: const Icon(Icons.bluetooth),

                  title: Text(device.name ?? "Unknown Device"),

                  subtitle: Text(device.address),

                  onTap: () {
                    connectDevice(device.address);
                  },
                );
              },
            ),
          ),

          if (connected)
            Column(
              children: [
                const Text("Connected"),

                ElevatedButton(
                  onPressed: sendData,
                  child: const Text("Send Ping"),
                ),

                ElevatedButton(
                  onPressed: disconnectDevice,
                  child: const Text("Disconnect"),
                ),

                const SizedBox(height: 10),

                Text("Received: ${String.fromCharCodes(receivedData)}"),
              ],
            ),
        ],
      ),
    );
  }
}
