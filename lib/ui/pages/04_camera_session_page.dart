import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../core/constants.dart';

class CameraSessionPage extends StatefulWidget {
  const CameraSessionPage({super.key});

  @override
  State<CameraSessionPage> createState() => _CameraSessionPageState();
}

class _CameraSessionPageState extends State<CameraSessionPage> {
  // --- Controller & State ---
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  
  // --- Logic Foto ---
  final List<XFile> _capturedPhotos = []; // Menyimpan foto yang sudah di-keep
  XFile? _tempPhoto; // Foto sementara saat review (sebelum di-keep)
  final int _maxSlots = 3; // Nanti ini bisa diambil dari argument Frame yang dipilih

  // --- Logic Timer ---
  Timer? _globalTimer;
  int _globalTimeRemaining = 300; // 5 Menit (300 detik)
  
  Timer? _shutterTimer;
  int _shutterTimeRemaining = 10; // 10 Detik sebelum jepret
  bool _isCountingDown = false; // Sedang menghitung mundur untuk foto?

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _startGlobalTimer();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _globalTimer?.cancel();
    _shutterTimer?.cancel();
    super.dispose();
  }

  // 1. Inisialisasi Kamera (Cari kamera pertama/webcam)
  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        // Gunakan kamera pertama (biasanya webcam default)
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high, // Resolusi tinggi untuk cetak
          enableAudio: false,
        );

        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      } else {
        debugPrint("Tidak ada kamera ditemukan!");
      }
    } catch (e) {
      debugPrint("Error inisialisasi kamera: $e");
    }
  }

  // 2. Timer Global (Sesi 5 Menit)
  void _startGlobalTimer() {
    _globalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_globalTimeRemaining > 0) {
        setState(() {
          _globalTimeRemaining--;
        });
      } else {
        // Waktu Habis -> Paksa selesai atau kembali ke awal
        timer.cancel();
        _finishSession();
      }
    });
  }

  // 3. Timer Shutter (10 detik sebelum foto)
  void _startShutterCountdown() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    setState(() {
      _isCountingDown = true;
      _shutterTimeRemaining = 10; // Reset ke 10 detik
    });

    _shutterTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_shutterTimeRemaining > 1) {
        setState(() {
          _shutterTimeRemaining--;
        });
      } else {
        // Waktu jepret!
        timer.cancel();
        _takePicture();
      }
    });
  }

  // 4. Proses Ambil Foto
  Future<void> _takePicture() async {
    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _isCountingDown = false; // Stop countdown UI
        _tempPhoto = photo; // Tampilkan mode review
      });
    } catch (e) {
      debugPrint("Gagal ambil foto: $e");
      setState(() => _isCountingDown = false);
    }
  }

  // 5. User Memilih "Keep" (Simpan Foto)
  void _keepPhoto() {
    if (_tempPhoto != null) {
      setState(() {
        _capturedPhotos.add(_tempPhoto!);
        _tempPhoto = null; // Kembali ke mode kamera
      });

      // Cek apakah slot sudah penuh?
      if (_capturedPhotos.length >= _maxSlots) {
        _finishSession();
      }
    }
  }

  // 6. User Memilih "Retake" (Buang Foto)
  void _retakePhoto() {
    setState(() {
      _tempPhoto = null; // Hapus temp, kembali ke kamera
    });
  }

  // 7. Selesai Sesi -> Pindah ke Editing
  void _finishSession() {
    _globalTimer?.cancel();
    // Kirim data foto ke halaman berikutnya
    Navigator.pushNamed(
      context, 
      '/editing', 
      arguments: _capturedPhotos, // Kirim list foto
    );
  }

  @override
  Widget build(BuildContext context) {
    // Format Waktu Menit:Detik
    final String globalTimerStr = 
        '${(_globalTimeRemaining ~/ 60).toString().padLeft(2, '0')}:${(_globalTimeRemaining % 60).toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // A. LAYER KAMERA / PREVIEW
          Positioned.fill(
            child: _isCameraInitialized
                ? (_tempPhoto == null)
                    // Jika tidak sedang review, tampilkan kamera live
                    ? AspectRatio(
                        aspectRatio: _cameraController!.value.aspectRatio,
                        child: CameraPreview(_cameraController!),
                      )
                    // Jika sedang review, tampilkan hasil foto
                    : Image.file(
                        File(_tempPhoto!.path),
                        fit: BoxFit.cover,
                      )
                : const Center(child: CircularProgressIndicator()),
          ),

          // B. LAYER OVERLAY UI (Timer & Progress)
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Indikator Jumlah Foto
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Foto: ${_capturedPhotos.length} / $_maxSlots",
                    style: AppTextStyles.h2,
                  ),
                ),
                // Indikator Global Timer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _globalTimeRemaining < 60 ? Colors.red.withOpacity(0.8) : Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(globalTimerStr, style: AppTextStyles.h2),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // C. LAYER COUNTDOWN TENGAH (3..2..1)
          if (_isCountingDown)
            Center(
              child: Text(
                "$_shutterTimeRemaining",
                style: const TextStyle(
                  fontSize: 200,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(blurRadius: 20, color: Colors.black, offset: Offset(0, 0))
                  ],
                ),
              ),
            ),

          // D. LAYER TOMBOL KONTROL BAWAH
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: _tempPhoto == null
                  ? _buildCameraControls() // Tombol Shutter
                  : _buildReviewControls(), // Tombol Keep/Retake
            ),
          ),
        ],
      ),
    );
  }

  // Widget Tombol Mulai Foto
  Widget _buildCameraControls() {
    return _isCountingDown
        ? const SizedBox() // Sembunyikan tombol saat hitung mundur
        : InkWell(
            onTap: _startShutterCountdown,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 4),
              ),
              child: const Icon(Icons.camera_alt, size: 40, color: AppColors.primary),
            ),
          );
  }

  // Widget Tombol Review (Keep / Retake)
  Widget _buildReviewControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Tombol Retake
        ElevatedButton.icon(
          onPressed: _retakePhoto,
          icon: const Icon(Icons.refresh),
          label: const Text("Retake"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
        ),
        const SizedBox(width: 40),
        // Tombol Keep
        ElevatedButton.icon(
          onPressed: _keepPhoto,
          icon: const Icon(Icons.check),
          label: const Text("Keep"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
        ),
      ],
    );
  }
}