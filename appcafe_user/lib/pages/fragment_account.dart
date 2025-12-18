import 'package:flutter/material.dart';

class FragmentAccount extends StatelessWidget {
  const FragmentAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Tiêu đề ---
            Container(
              padding: const EdgeInsets.all(12),
              color: const Color(0xFFFFEEDB), // màu kem tương tự Android
              child: const Text(
                "THÔNG TIN NHÂN VIÊN",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- Họ tên ---
            const Text(
              "Họ Tên:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            // --- Ngày sinh ---
            const SizedBox(height: 10),
            const Text(
              "Ngày sinh:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            // --- Giới tính ---
            const SizedBox(height: 10),
            const Text(
              "Giới tính:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            // --- Email ---
            const SizedBox(height: 10),
            const Text(
              "Email:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            // --- Số điện thoại ---
            const SizedBox(height: 10),
            const Text(
              "Số điện thoại:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            // --- Nút sửa thông tin ---
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B4513), // màu brown
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/suaThongTin');
                },
                child: const Text(
                  "SỬA THÔNG TIN CÁ NHÂN",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
