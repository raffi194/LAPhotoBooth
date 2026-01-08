import 'package:flutter/material.dart';
import '../../core/constants.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: InkWell(
        // Seluruh layar bisa diklik untuk mulai
        onTap: () {
          Navigator.pushNamed(context, '/payment');
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Background Image (Opsional, ganti dengan Image.asset nanti)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background,
                    AppColors.primary.withOpacity(0.2),
                  ],
                ),
              ),
            ),

            // 2. Konten Tengah
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  size: 120,
                  color: AppColors.secondary,
                ),
                const SizedBox(height: 40),
                const Text(
                  "LA PHOTOBOOTH",
                  style: AppTextStyles.h1,
                ),
                const SizedBox(height: 20),
                Text(
                  "Sentuh Layar untuk Memulai",
                  style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 60),
                
                // Instruksi Singkat
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _InstructionItem(icon: Icons.timer, text: "5 Menit Sesi"),
                      SizedBox(width: 30),
                      _InstructionItem(icon: Icons.print, text: "Cetak Langsung"),
                      SizedBox(width: 30),
                      _InstructionItem(icon: Icons.qr_code, text: "Download Digital"),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InstructionItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InstructionItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 32),
        const SizedBox(height: 8),
        Text(text, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}