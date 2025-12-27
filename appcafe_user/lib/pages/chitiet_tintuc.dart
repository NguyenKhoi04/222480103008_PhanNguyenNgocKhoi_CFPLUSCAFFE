import 'package:flutter/material.dart';

class ChitietTinTuc extends StatelessWidget {
  final String hinhAnh;
  final String tuaDe;
  final String tomTat;
  final String noiDung;

  const ChitietTinTuc({
    super.key,
    required this.hinhAnh,
    required this.tuaDe,
    required this.tomTat,
    required this.noiDung,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tuaDe, style: const TextStyle(fontSize: 16))),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hinhAnh.isNotEmpty)
              Image.network(hinhAnh,
                  width: double.infinity, height: 220, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tuaDe,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(tomTat,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black54)),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(noiDung.isNotEmpty ? noiDung : tomTat,
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
