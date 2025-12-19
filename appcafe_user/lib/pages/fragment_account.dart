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
  String hoTen = "";
  String ngaySinh = "";
  String gioiTinh = "";
  String email = "";
  String soDienThoai = "";

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
          hoTen = doc.get("Họ tên NV") ?? "";
          gioiTinh = doc.get("Giới tính") ?? "";
          email = doc.get("Email") ?? user.email ?? "";
          soDienThoai = doc.get("Số điện thoại") ?? "";

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
          email = user.email ?? "";
        });
      }
    } catch (e) {
      print("Lỗi load data: $e");
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
              color: const Color(0xFFFFEEDB),
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
            _buildInfoRow("Họ Tên:", hoTen.isEmpty ? "Chưa cập nhật" : hoTen),

            // --- Ngày sinh ---
            const SizedBox(height: 10),
            _buildInfoRow("Ngày sinh:", ngaySinh.isEmpty ? "Chưa cập nhật" : ngaySinh),

            // --- Giới tính ---
            const SizedBox(height: 10),
            _buildInfoRow("Giới tính:", gioiTinh.isEmpty ? "Chưa cập nhật" : gioiTinh),

            // --- Email ---
            const SizedBox(height: 10),
            _buildInfoRow("Email:", email.isEmpty ? "Chưa cập nhật" : email),

            // --- Số điện thoại ---
            const SizedBox(height: 10),
            _buildInfoRow("Số điện thoại:", soDienThoai.isEmpty ? "Chưa cập nhật" : soDienThoai),

            const SizedBox(height: 30),

            // --- Nút sửa thông tin ---
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B4513),
                ),
                onPressed: () async {
                  await Navigator.pushNamed(context, '/suaThongTin');
                  loadData(); // Reload sau khi sửa
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

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}
