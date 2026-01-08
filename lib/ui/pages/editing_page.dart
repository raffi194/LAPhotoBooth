import 'package:flutter/material.dart';
class EditingPage extends StatelessWidget {
  const EditingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit & Stiker")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/print'),
          child: const Text("Cetak"),
        ),
      ),
    );
  }
}