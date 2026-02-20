import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/qr_scan_screen.dart';
import 'screens/ble_devices_screen.dart';
import 'screens/floor_selection_screen.dart';
import 'screens/call_screen.dart';
import 'services/ble_service.dart';
import 'theme.dart';

void main() {
  runApp(const ElevatorCallApp());
}

class ElevatorCallApp extends StatelessWidget {
  const ElevatorCallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BleService()),
      ],
      child: MaterialApp(
        title: '엘리베이터 호출',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/qr_scan': (context) => const QRScanScreen(),
          '/ble_devices': (context) => const BleDevicesScreen(),
          '/floor_selection': (context) => const FloorSelectionScreen(),
          '/call': (context) => const CallScreen(),
        },
      ),
    );
  }
}
