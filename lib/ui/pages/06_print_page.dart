import 'package:flutter/material.dart';
class PrintPage extends StatelessWidget {
  const PrintPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cetak & Download")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/')),
          child: const Text("Selesai (Kembali ke Awal)"),
        ),
      ),
    );
  }
}