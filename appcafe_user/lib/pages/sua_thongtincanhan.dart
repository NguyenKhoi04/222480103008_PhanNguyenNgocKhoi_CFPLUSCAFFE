import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SuaThongTinCaNhan extends StatefulWidget {
  const SuaThongTinCaNhan({super.key});

  @override
  State<SuaThongTinCaNhan> createState() => _SuaThongTinCaNhanState();
}

class _SuaThongTinCaNhanState extends State<SuaThongTinCaNhan> {
  TextEditingController edtHoTen = TextEditingController();
  TextEditingController edtNgaySinh = TextEditingController();
  TextEditingController edtGioiTinh = TextEditingController();
  TextEditingController edtEmail = TextEditingController();
  TextEditingController edtSoDienThoai = TextEditingController();

  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  late DocumentReference nhanVienRef;

  @override
  void initState() {
    super.initState();
    User? user = auth.currentUser;

    if (user != null) {
      edtEmail.text = user.email ?? "";
      nhanVienRef = db.collection("Người dùng").doc("Nhân viên");
      loadData();
    }
  }

  // -----------------------------
  // Load dữ liệu từ Firestore
  // -----------------------------
  void loadData() async {
    var doc = await nhanVienRef.get();
    if (doc.exists) {
      setState(() {
        edtHoTen.text = doc["Họ tên NV"] ?? "";
        edtGioiTinh.text = doc["Giới tính"] ?? "";
        edtSoDienThoai.text = doc["Số điện thoại"] ?? "";

        var ngaySinh = doc["Ngày sinh"];
        if (ngaySinh is Timestamp) {
          edtNgaySinh.text = DateFormat("dd/MM/yyyy").format(ngaySinh.toDate());
        }
      });
    }
  }

  // -----------------------------
  // Lưu dữ liệu lên Firestore
  // -----------------------------
  void saveData() async {
    try {
      DateTime parsedDate =
          DateFormat("dd/MM/yyyy").parse(edtNgaySinh.text.trim());

      Map<String, dynamic> data = {
        "Họ tên NV": edtHoTen.text.trim(),
        "Giới tính": edtGioiTinh.text.trim(),
        "Email": edtEmail.text.trim(),
        "Số điện thoại": edtSoDienThoai.text.trim(),
        "Ngày sinh": parsedDate,
      };

      await nhanVienRef.set(data);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cập nhật thành công!")),
      );

      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Định dạng ngày không đúng!")),
      );
    }
  }

  // -----------------------------
  // Giao diện
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sửa thông tin cá nhân"),
        backgroundColor: Colors.brown,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [

            buildInput("Họ tên", edtHoTen),
            buildInput("Ngày sinh (dd/mm/yyyy)", edtNgaySinh),
            buildInput("Giới tính", edtGioiTinh),
            buildInput("Email", edtEmail, enabled: false),
            buildInput("Số điện thoại", edtSoDienThoai),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: saveData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                "Lưu thay đổi",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            SizedBox(height: 15),

            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12),
                color: const Color(0xFF6D4C41),
                child: Text(
                  "Trở về trang thông tin nhân viên",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Widget tạo khung nhập giống XML
  Widget buildInput(String label, TextEditingController controller,
      {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          TextField(
            controller: controller,
            enabled: enabled,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
