import 'package:flutter/material.dart';
class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pembayaran")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/settings'),
          child: const Text("Simulasi Bayar Sukses"), // Tombol debug
        ),
      ),
    );
  }
}