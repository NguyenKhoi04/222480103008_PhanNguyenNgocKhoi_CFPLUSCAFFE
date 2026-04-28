import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SuaThongTinCaNhan extends StatefulWidget {
  const SuaThongTinCaNhan({super.key});

  @override
  State<SuaThongTinCaNhan> createState() => _SuaThongTinCaNhanState();
}

class _SuaThongTinCaNhanState extends State<SuaThongTinCaNhan> {
  final supabase = Supabase.instance.client;

  final TextEditingController edtHoTen = TextEditingController();
  final TextEditingController edtNgaySinh = TextEditingController();
  final TextEditingController edtGioiTinh = TextEditingController();
  final TextEditingController edtEmail = TextEditingController();
  final TextEditingController edtSoDienThoai = TextEditingController();

  String userId = "";

  @override
  void initState() {
    super.initState();

    final user = supabase.auth.currentUser;

    if (user != null) {
      userId = user.id;
      edtEmail.text = user.email ?? "";
      loadData();
    }
  }

  Future<void> loadData() async {
    try {
      final data = await supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      if (!mounted) return;

      edtHoTen.text = data['full_name'] ?? "";
      edtGioiTinh.text = data['gender'] ?? "";
      edtSoDienThoai.text = data['position'] ?? "";

      if (data['birthday'] != null) {
        final date = DateTime.parse(data['birthday']);
        edtNgaySinh.text =
            DateFormat("dd/MM/yyyy").format(date);
      }
    } catch (e) {
      debugPrint("Lỗi load data: $e");
    }
  }

  Future<void> saveData() async {
    try {
      DateTime? parsedDate;

      if (edtNgaySinh.text.trim().isNotEmpty) {
        parsedDate = DateFormat("dd/MM/yyyy")
            .parseStrict(edtNgaySinh.text.trim());
      }

      await supabase.from('users').upsert({
        'id': userId,
        'full_name': edtHoTen.text.trim(),
        'gender': edtGioiTinh.text.trim(),
        'email': edtEmail.text.trim(),
        'position': edtSoDienThoai.text.trim(),
        'birthday': parsedDate?.toIso8601String(),
        'role': 'customer',
        'updated_at':
            DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cập nhật thành công!"),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Lỗi: Sai định dạng ngày hoặc lỗi hệ thống!",
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    edtHoTen.dispose();
    edtNgaySinh.dispose();
    edtGioiTinh.dispose();
    edtEmail.dispose();
    edtSoDienThoai.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sửa thông tin cá nhân"),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildInput("Họ tên", edtHoTen),
            buildInput(
              "Ngày sinh (dd/MM/yyyy)",
              edtNgaySinh,
            ),
            buildInput("Giới tính", edtGioiTinh),
            buildInput(
              "Email",
              edtEmail,
              enabled: false,
            ),
            buildInput(
              "Số điện thoại",
              edtSoDienThoai,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: saveData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                minimumSize:
                    const Size(double.infinity, 50),
              ),
              child: const Text(
                "Lưu thay đổi",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 15),

            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 12,
                ),
                color: const Color(0xFF6D4C41),
                child: const Text(
                  "Trở về trang thông tin",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInput(
    String label,
    TextEditingController controller, {
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            enabled: enabled,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 12,
              ),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class SuaThongTinCaNhan extends StatefulWidget {
//   const SuaThongTinCaNhan({super.key});

//   @override
//   State<SuaThongTinCaNhan> createState() => _SuaThongTinCaNhanState();
// }

// class _SuaThongTinCaNhanState extends State<SuaThongTinCaNhan> {
//   TextEditingController edtHoTen = TextEditingController();
//   TextEditingController edtNgaySinh = TextEditingController();
//   TextEditingController edtGioiTinh = TextEditingController();
//   TextEditingController edtEmail = TextEditingController();
//   TextEditingController edtSoDienThoai = TextEditingController();

//   FirebaseFirestore db = FirebaseFirestore.instance;
//   FirebaseAuth auth = FirebaseAuth.instance;

//   late DocumentReference nhanVienRef;

//   @override
//   void initState() {
//     super.initState();
//     User? user = auth.currentUser;

//     if (user != null) {
//       edtEmail.text = user.email ?? "";
      
//       // --- CẬP NHẬT ĐƯỜNG DẪN TẠI ĐÂY ---
//       // Trỏ đúng vào document của User đang đăng nhập trong collection Khách hàng
//       nhanVienRef = db.collection("Người dùng")
//           .doc("Nhân Viên")
//           .collection("Khách hàng")
//           .doc(user.uid); 
          
//       loadData();
//     }
//   }

//   // -----------------------------
//   // Load dữ liệu từ Firestore
//   // -----------------------------
//   void loadData() async {
//     try {
//       var doc = await nhanVienRef.get();
//       if (doc.exists && mounted) {
//         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
//         setState(() {
//           // Kiểm tra null safety khi get dữ liệu
//           edtHoTen.text = data["Họ tên NV"] ?? ""; 
//           edtGioiTinh.text = data["Giới tính"] ?? "";
//           edtSoDienThoai.text = data["Số điện thoại"] ?? "";

//           var ngaySinh = data["Ngày sinh"];
//           if (ngaySinh != null && ngaySinh is Timestamp) {
//             edtNgaySinh.text = DateFormat("dd/MM/yyyy").format(ngaySinh.toDate());
//           } else if (ngaySinh != null) {
//             edtNgaySinh.text = ngaySinh.toString();
//           }
//         });
//       }
//     } catch (e) {
//       print("Lỗi load data: $e");
//     }
//   }

//   // -----------------------------
//   // Lưu dữ liệu lên Firestore
//   // -----------------------------
//   void saveData() async {
//     try {
//       // Parse ngày sinh
//       DateTime parsedDate = DateFormat("dd/MM/yyyy").parse(edtNgaySinh.text.trim());

//       Map<String, dynamic> data = {
//         "Họ tên NV": edtHoTen.text.trim(),
//         "Giới tính": edtGioiTinh.text.trim(),
//         "Email": edtEmail.text.trim(), // Lưu email để đồng bộ thông tin
//         "Số điện thoại": edtSoDienThoai.text.trim(),
//         "Ngày sinh": parsedDate,
//       };

//       // Dùng SetOptions(merge: true) để không bị mất các trường khác (nếu có)
//       await nhanVienRef.set(data, SetOptions(merge: true));

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Cập nhật thành công!")),
//         );
//         Navigator.pop(context); // Quay về trang trước
//       }

//     } catch (e) {
//       print(e);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Lỗi: Định dạng ngày không đúng hoặc lỗi mạng!")),
//         );
//       }
//     }
//   }

//   // -----------------------------
//   // Giao diện (GIỮ NGUYÊN)
//   // -----------------------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Sửa thông tin cá nhân"),
//         backgroundColor: Colors.brown,
//         foregroundColor: Colors.white, // Thêm màu chữ trắng cho đẹp
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [

//             buildInput("Họ tên", edtHoTen),
//             buildInput("Ngày sinh (dd/mm/yyyy)", edtNgaySinh),
//             buildInput("Giới tính", edtGioiTinh),
//             buildInput("Email", edtEmail, enabled: false), // Email thường không cho sửa
//             buildInput("Số điện thoại", edtSoDienThoai),

//             const SizedBox(height: 20),

//             ElevatedButton(
//               onPressed: saveData,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.brown,
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               child: const Text(
//                 "Lưu thay đổi",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
//               ),
//             ),

//             const SizedBox(height: 15),

//             GestureDetector(
//               onTap: () => Navigator.pop(context),
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 color: const Color(0xFF6D4C41),
//                 child: const Text(
//                   "Trở về trang thông tin", // Sửa nhẹ text cho phù hợp
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 18,
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   // Widget tạo khung nhập giống XML
//   Widget buildInput(String label, TextEditingController controller,
//       {bool enabled = true}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label,
//               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 6),
//           TextField(
//             controller: controller,
//             enabled: enabled,
//             decoration: InputDecoration(
//               filled: true,
//               fillColor: Colors.white,
//               contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }