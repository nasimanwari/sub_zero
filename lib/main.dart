import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sub_zero/models/subscription.dart';
import 'package:sub_zero/screens/home_screen.dart';
import 'package:sub_zero/services/notification_service.dart'; // Import the service

void main() async {
  // 1. Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(SubscriptionAdapter());
  await Hive.openBox('subscriptionsBox');

  // 3. Initialize Notifications
  await NotificationService().initNotification();

  // 4. Run the App
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sub-Zero',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}