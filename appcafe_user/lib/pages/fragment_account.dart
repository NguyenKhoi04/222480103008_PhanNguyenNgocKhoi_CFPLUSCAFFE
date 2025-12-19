import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class FragmentAccount extends StatefulWidget {
  const FragmentAccount({super.key});

  @override
  State<FragmentAccount> createState() => _FragmentAccountState();
}

class _FragmentAccountState extends State<FragmentAccount> {
  String hoTen = '';
  String ngaySinh = '';
  String gioiTinh = '';
  String email = '';
  String soDienThoai = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection("Người dùng")
          .doc("Nhân viên")
          .get();

      if (doc.exists) {
        setState(() {
          hoTen = doc.get("Họ tên NV") ?? '';
          gioiTinh = doc.get("Giới tính") ?? '';
          email = doc.get("Email") ?? user.email ?? '';
          soDienThoai = doc.get("Số điện thoại") ?? '';
          
          var ngaySinhData = doc.get("Ngày sinh");
          if (ngaySinhData != null) {
            if (ngaySinhData is Timestamp) {
              ngaySinh = DateFormat("dd/MM/yyyy").format(ngaySinhData.toDate());
            } else {
              ngaySinh = ngaySinhData.toString();
            }
          }
        });
      } else {
        setState(() {
          email = user.email ?? '';
        });
      }
    } catch (e) {
      print('Lỗi load dữ liệu: $e');
    }
  }

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
            Text(
              hoTen.isEmpty ? "Chưa có thông tin" : hoTen,
              style: const TextStyle(fontSize: 18),
            ),

            // --- Ngày sinh ---
            const SizedBox(height: 10),
            const Text(
              "Ngày sinh:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              ngaySinh.isEmpty ? "Chưa có thông tin" : ngaySinh,
              style: const TextStyle(fontSize: 18),
            ),

            // --- Giới tính ---
            const SizedBox(height: 10),
            const Text(
              "Giới tính:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              gioiTinh.isEmpty ? "Chưa có thông tin" : gioiTinh,
              style: const TextStyle(fontSize: 18),
            ),

            // --- Email ---
            const SizedBox(height: 10),
            const Text(
              "Email:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              email.isEmpty ? "Chưa có thông tin" : email,
              style: const TextStyle(fontSize: 18),
            ),

            // --- Số điện thoại ---
            const SizedBox(height: 10),
            const Text(
              "Số điện thoại:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              soDienThoai.isEmpty ? "Chưa có thông tin" : soDienThoai,
              style: const TextStyle(fontSize: 18),
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
