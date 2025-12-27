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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          isLoading = false;
          email = "";
        });
      }
      return;
    }

    setState(() => isLoading = true);

    try {
      // --- SỬA ĐỔI ĐƯỜNG DẪN TẠI ĐÂY ---
      final doc = await FirebaseFirestore.instance
          .collection("Người dùng")       // Collection cha
          .doc("Nhân Viên")               // Document danh mục
          .collection("Khách hàng")       // Sub-collection Khách hàng
          .doc(user.uid)                  // Lấy document theo ID của user đang đăng nhập
          .get()
          .timeout(const Duration(seconds: 10)); // Tăng timeout lên xíu cho an toàn

      if (doc.exists && mounted) {
        setState(() {
          // Lưu ý: Đảm bảo tên field (trường) trong Firestore khớp chính xác với chuỗi bên dưới
          hoTen = doc.get("Họ tên NV") ?? ""; // Có thể bạn cần đổi thành "Họ tên KH" tùy database
          gioiTinh = doc.get("Giới tính") ?? "";
          email = doc.data()!.containsKey("Email") ? doc.get("Email") : (user.email ?? "");
          soDienThoai = doc.get("Số điện thoại") ?? "";

          var ngaySinhData = doc.data()!.containsKey("Ngày sinh") ? doc.get("Ngày sinh") : null;
          if (ngaySinhData != null) {
            if (ngaySinhData is Timestamp) {
              ngaySinh = DateFormat("dd/MM/yyyy").format(ngaySinhData.toDate());
            } else {
              ngaySinh = ngaySinhData.toString();
            }
          }
          isLoading = false;
        });
      } else if (mounted) {
        // Trường hợp đăng nhập thành công nhưng chưa có dữ liệu trong Firestore
        setState(() {
          email = user.email ?? "";
          isLoading = false;
        });
        print("Không tìm thấy document cho user: ${user.uid} tại đường dẫn này.");
      }
    } catch (e) {
      print("Lỗi load data: $e");
      if (mounted) {
        setState(() {
          email = user.email ?? "";
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                "THÔNG TIN KHÁCH HÀNG", // Đã sửa tiêu đề cho phù hợp context
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- Các trường thông tin ---
            _buildInfoRow("Họ Tên:", hoTen.isEmpty ? "Chưa cập nhật" : hoTen),
            const SizedBox(height: 10),
            _buildInfoRow("Ngày sinh:", ngaySinh.isEmpty ? "Chưa cập nhật" : ngaySinh),
            const SizedBox(height: 10),
            _buildInfoRow("Giới tính:", gioiTinh.isEmpty ? "Chưa cập nhật" : gioiTinh),
            const SizedBox(height: 10),
            _buildInfoRow("Email:", email.isEmpty ? "Chưa cập nhật" : email),
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
                  loadData(); 
                },
                child: const Text(
                  "SỬA THÔNG TIN CÁ NHÂN",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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