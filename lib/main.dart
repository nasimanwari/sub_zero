import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sub_zero/models/subscription.dart';
import 'package:sub_zero/screens/main_screen.dart'; // Bu satır çok önemli!
import 'package:sub_zero/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Status Bar'ı şeffaf yap
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  await Hive.initFlutter();
  Hive.registerAdapter(SubscriptionAdapter());
  
  await Hive.openBox('subscriptionsBox');
  await Hive.openBox('settingsBox'); 

  await NotificationService().initNotification();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settingsBox').listenable(),
      builder: (context, box, _) {
        bool isDark = box.get('darkMode', defaultValue: false);

        // Dark Mode'a göre status bar ikon rengini ayarla
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ));

        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Sub-Zero',
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.blue,
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFFF2F4F7),
              textTheme: GoogleFonts.poppinsTextTheme(),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                systemOverlayStyle: SystemUiOverlayStyle.dark,
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.blue,
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFF121212),
              textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                systemOverlayStyle: SystemUiOverlayStyle.light,
              ),
              cardColor: const Color(0xFF1E1E1E),
            ),
            home: const MainScreen(),
          ),
        );
      },
    );
  }
}