import 'package:flutter/material.dart';
import 'package:sub_zero/screens/home_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async{
  await Hive.initFlutter();
  await Hive.openBox('subscriptionsBox');
  
  runApp(
    MaterialApp(
      title: 'Sub-Zero',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.cyan, brightness: Brightness.dark),
      ),
      themeMode: ThemeMode.system, 
      
      home: const HomeScreen(),
    ),
  );
}