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
  String? _errorMessage; // Untuk menampilkan error jika ada
  
  // --- Logic Foto ---
  final List<XFile> _capturedPhotos = []; 
  XFile? _tempPhoto; 
  final int _maxSlots = 3; 

  // --- Logic Timer ---
  Timer? _globalTimer;
  int _globalTimeRemaining = 300; // 5 Menit
  
  Timer? _shutterTimer;
  int _shutterTimeRemaining = 5; 
  bool _isCountingDown = false; 

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

  // 1. Inisialisasi Kamera (Versi Stabil Windows)
  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        // Ambil kamera pertama
        final camera = _cameras!.first;

        _cameraController = CameraController(
          camera,
          // TIPS: Gunakan medium dulu agar aman di semua jenis webcam laptop
          ResolutionPreset.medium, 
          enableAudio: false,
          // PENTING: Wajib diset JPEG untuk Windows agar preview muncul
          imageFormatGroup: ImageFormatGroup.jpeg, 
        );

        await _cameraController!.initialize();
        
        // PENTING: Beri jeda sedikit agar driver kamera Windows siap
        await Future.delayed(const Duration(milliseconds: 200));

        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      } else {
        setState(() => _errorMessage = "Tidak ada kamera ditemukan!");
      }
    } catch (e) {
      debugPrint("Error inisialisasi kamera: $e");
      if (mounted) {
        setState(() => _errorMessage = "Gagal memuat kamera: $e");
      }
    }
  }

  // 2. Timer Global
  void _startGlobalTimer() {
    _globalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_globalTimeRemaining > 0) {
          setState(() {
            _globalTimeRemaining--;
          });
        } else {
          timer.cancel();
          _finishSession();
        }
      }
    });
  }

  // 3. Timer Shutter
  void _startShutterCountdown() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    setState(() {
      _isCountingDown = true;
      _shutterTimeRemaining = 5; // Hitung mundur 5 detik
    });

    _shutterTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_shutterTimeRemaining > 1) {
          setState(() {
            _shutterTimeRemaining--;
          });
        } else {
          timer.cancel();
          _takePicture();
        }
      }
    });
  }

  // 4. Proses Ambil Foto
  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    try {
      final XFile photo = await _cameraController!.takePicture();
      if (mounted) {
        setState(() {
          _isCountingDown = false;
          _tempPhoto = photo;
        });
      }
    } catch (e) {
      debugPrint("Gagal ambil foto: $e");
      if (mounted) {
        setState(() => _isCountingDown = false);
      }
    }
  }

  void _keepPhoto() {
    if (_tempPhoto != null) {
      setState(() {
        _capturedPhotos.add(_tempPhoto!);
        _tempPhoto = null;
      });

      if (_capturedPhotos.length >= _maxSlots) {
        _finishSession();
      }
    }
  }

  void _retakePhoto() {
    setState(() {
      _tempPhoto = null;
    });
  }

  void _finishSession() {
    _globalTimer?.cancel();
    Navigator.pushNamed(
      context, 
      '/editing', 
      arguments: _capturedPhotos, 
    );
  }

  @override
  Widget build(BuildContext context) {
    final String globalTimerStr = 
        '${(_globalTimeRemaining ~/ 60).toString().padLeft(2, '0')}:${(_globalTimeRemaining % 60).toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // A. LAYER KAMERA / PREVIEW
          Positioned.fill(
            child: _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
              : _isCameraInitialized
                ? (_tempPhoto == null)
                    ? AspectRatio(
                        aspectRatio: _cameraController!.value.aspectRatio,
                        child: CameraPreview(_cameraController!),
                      )
                    : Image.file(
                        File(_tempPhoto!.path),
                        fit: BoxFit.cover,
                      )
                : const Center(child: CircularProgressIndicator()),
          ),

          // B. LAYER OVERLAY UI
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _globalTimeRemaining < 60 
                        ? Colors.red.withValues(alpha: 0.8) 
                        : Colors.black54,
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

          // C. COUNTDOWN
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

          // D. CONTROLS
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: _tempPhoto == null
                  ? _buildCameraControls()
                  : _buildReviewControls(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraControls() {
    return _isCountingDown
        ? const SizedBox()
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

  Widget _buildReviewControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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