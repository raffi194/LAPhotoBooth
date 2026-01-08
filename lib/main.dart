import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'ui/pages/01_onboarding_page.dart';
import 'ui/pages/02_payment_page.dart';
import 'ui/pages/03_settings_page.dart';
import 'ui/pages/04_camera_session_page.dart';
import 'ui/pages/05_editing_page.dart';
import 'ui/pages/06_print_page.dart';

// Ganti dengan kredensial Anda (Sebaiknya nanti pakai .env)
const supabaseUrl = 'https://jwcwctikegcxbtjmzuwd.supabase.co';
const supabaseKey = 'GANTI_DENGAN_SUPABASE_ANON_KEY_ANDA';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  // 2. Konfigurasi Window (Kiosk Mode Setup)
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1080, 1920), // Resolusi Vertikal (Portrait Kiosk)
    center: true,
    backgroundColor: Colors.black,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal, // Ganti .hidden jika ingin full kiosk tanpa bar
  );
  
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    // await windowManager.setFullScreen(true); // Aktifkan nanti untuk mode produksi
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LA PhotoBooth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark, // Tema Gelap
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF121212), // Background hitam
        useMaterial3: true,
      ),
      // Definisi Rute Halaman
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingPage(),
        '/payment': (context) => const PaymentPage(),
        '/settings': (context) => const SettingsPage(),
        '/camera': (context) => const CameraSessionPage(),
        '/editing': (context) => const EditingPage(),
        '/print': (context) => const PrintPage(),
      },
    );
  }
}