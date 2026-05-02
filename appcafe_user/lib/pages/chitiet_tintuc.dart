import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class ChitietTinTuc extends StatelessWidget {
  final String hinhAnh;
  final String tuaDe;
  final String tomTat;
  final String noiDung;
  final String thoiGian;

    String get formattedDate {
      try {
        final dateTime = DateTime.parse(thoiGian);
        return DateFormat('dd/MM/yyyy').format(dateTime);
      } catch (e) {
        return '';
      }
    }
    
  const ChitietTinTuc({
    super.key,
    required this.hinhAnh,
    required this.tuaDe,
    required this.tomTat,
    required this.noiDung,
    required this.thoiGian,
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
              Image.network(
                  hinhAnh,
                  height: 70,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 70,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image),
                  ),
                )
            else
              Container(
                height: 70,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported),
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tuaDe,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  
                  if (formattedDate.isNotEmpty)
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),

                  const SizedBox(height: 10),

                  Text(
                    tomTat,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),

                  Text(
                    noiDung.isNotEmpty ? noiDung : tomTat,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
