import 'package:flutter/foundation.dart'; // [1] Tambahkan import ini untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';

// Pastikan import halaman sudah benar (sesuai perbaikan sebelumnya)
import 'ui/pages/onboarding_page.dart';
import 'ui/pages/payment_page.dart';
import 'ui/pages/settings_page.dart';
import 'ui/pages/camera_session_page.dart';
import 'ui/pages/editing_page.dart';
import 'ui/pages/print_page.dart';

// Ganti dengan kredensial Anda
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
  // [2] Cek: Hanya jalankan konfigurasi window jika TIDAK di Web
  if (!kIsWeb) {
    try {
      await windowManager.ensureInitialized();
      WindowOptions windowOptions = const WindowOptions(
        size: Size(1080, 1920), // Resolusi Vertikal
        center: true,
        backgroundColor: Colors.black,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
      );
      
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
        // await windowManager.setFullScreen(true); 
      });
    } catch (e) {
      // Jika dijalankan di Android/iOS (Mobile), window_manager mungkin error
      // Kita tangkap errornya agar aplikasi tidak crash
      debugPrint("Window Manager tidak support di platform ini: $e");
    }
  }

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
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF121212),
        useMaterial3: true,
      ),
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