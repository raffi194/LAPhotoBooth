import 'package:flutter/material.dart';

class AppColors {
  // Warna utama (Hitam Elegan untuk Kiosk)
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  
  // Warna Aksen (Neon/Vivid untuk kesan Photobooth)
  static const Color primary = Color(0xFF3B82F6); // Biru (mirip Tailwind blue-500)
  static const Color secondary = Color(0xFFEC4899); // Pink (mirip Tailwind pink-500)
  static const Color accent = Color(0xFFF59E0B); // Amber
  
  static const Color textWhite = Colors.white;
  static const Color textGray = Colors.grey;
}

class AppTextStyles {
  static const TextStyle h1 = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 18,
    color: Colors.white70,
  );
}