import 'package:flutter/material.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Bluetooth Paired Devices'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String pDevices = "Loading devices...";

  @override
  void initState() {
    super.initState();
    loadDevices();
  }

  Future<void> loadDevices() async {
    String devices = await pairedDevices();

    setState(() {
      pDevices = devices;
    });
  }

  Future<String> pairedDevices() async {
    try {
      final bluetoothClassicPlugin = BluetoothClassic();

      await bluetoothClassicPlugin.initPermissions();

      List<dynamic> discoveredDevices = await bluetoothClassicPlugin
          .getPairedDevices();

      return discoveredDevices.toString();
    } catch (e) {
      return "Error getting devices";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Paired Bluetooth Devices",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Text(pDevices, textAlign: TextAlign.center),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: loadDevices,
              child: const Text("Refresh Devices"),
            ),
          ],
        ),
      ),
    );
  }
}
