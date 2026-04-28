import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FragmentAccount extends StatefulWidget {
  const FragmentAccount({super.key});

  @override
  State<FragmentAccount> createState() => _FragmentAccountState();
}

class _FragmentAccountState extends State<FragmentAccount> {
  final supabase = Supabase.instance.client;

  String hoTen = "";
  String ngaySinh = "";
  String gioiTinh = "";
  String email = "";
  String chucVu = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final data = await supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      if (mounted) {
        setState(() {
          hoTen = data['full_name'] ?? "";
          gioiTinh = data['gender'] ?? "";
          email = data['email'] ?? user.email ?? "";
          chucVu = data['position'] ?? "";

          if (data['birthday'] != null) {
            final date = DateTime.parse(data['birthday']);
            ngaySinh = DateFormat('dd/MM/yyyy').format(date);
          }

          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          email = user.email ?? "";
          isLoading = false;
        });
      }
    }
  }

  Future<void> luuThongTin() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await supabase.from('users').upsert({
        'id': user.id,
        'full_name': hoTen,
        'email': email,
        'role': 'customer', // bắt buộc customer
        'position': chucVu,
        'gender': gioiTinh,
        'birthday': ngaySinh.isNotEmpty
            ? DateFormat('dd/MM/yyyy').parse(ngaySinh).toIso8601String()
            : null,
        'updated_at': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lưu thành công")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi lưu: $e")),
      );
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: const Color(0xFFFFEEDB),
              child: const Text(
                "THÔNG TIN KHÁCH HÀNG",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            _buildInfoRow("Họ tên:", hoTen),
            _buildInfoRow("Ngày sinh:", ngaySinh),
            _buildInfoRow("Giới tính:", gioiTinh),
            _buildInfoRow("Email:", email),
            _buildInfoRow("Chức vụ:", chucVu),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
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
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: luuThongTin,
                child: const Text("LƯU THÔNG TIN"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.brown),
        borderRadius: BorderRadius.circular(10),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 18),
          children: [
            TextSpan(
              text: "$label ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: value.isEmpty ? "Chưa cập nhật" : value,
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';

// class FragmentAccount extends StatefulWidget {
//   const FragmentAccount({super.key});

//   @override
//   State<FragmentAccount> createState() => _FragmentAccountState();
// }

// class _FragmentAccountState extends State<FragmentAccount> {
//   String hoTen = "";
//   String ngaySinh = "";
//   String gioiTinh = "";
//   String email = "";
//   String soDienThoai = "";
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     loadData();
//   }

//   void loadData() async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//           email = "";
//         });
//       }
//       return;
//     }

//     setState(() => isLoading = true);

//     try {
//       // --- SỬA ĐỔI ĐƯỜNG DẪN TẠI ĐÂY ---
//       final doc = await FirebaseFirestore.instance
//           .collection("Người dùng")       // Collection cha
//           .doc("Nhân Viên")               // Document danh mục
//           .collection("Khách hàng")       // Sub-collection Khách hàng
//           .doc(user.uid)                  // Lấy document theo ID của user đang đăng nhập
//           .get()
//           .timeout(const Duration(seconds: 10)); // Tăng timeout lên xíu cho an toàn

//       if (doc.exists && mounted) {
//         setState(() {
//           // Lưu ý: Đảm bảo tên field (trường) trong Firestore khớp chính xác với chuỗi bên dưới
//           hoTen = doc.get("Họ tên NV") ?? ""; // Có thể bạn cần đổi thành "Họ tên KH" tùy database
//           gioiTinh = doc.get("Giới tính") ?? "";
//           email = doc.data()!.containsKey("Email") ? doc.get("Email") : (user.email ?? "");
//           soDienThoai = doc.get("Số điện thoại") ?? "";

//           var ngaySinhData = doc.data()!.containsKey("Ngày sinh") ? doc.get("Ngày sinh") : null;
//           if (ngaySinhData != null) {
//             if (ngaySinhData is Timestamp) {
//               ngaySinh = DateFormat("dd/MM/yyyy").format(ngaySinhData.toDate());
//             } else {
//               ngaySinh = ngaySinhData.toString();
//             }
//           }
//           isLoading = false;
//         });
//       } else if (mounted) {
//         // Trường hợp đăng nhập thành công nhưng chưa có dữ liệu trong Firestore
//         setState(() {
//           email = user.email ?? "";
//           isLoading = false;
//         });
//         print("Không tìm thấy document cho user: ${user.uid} tại đường dẫn này.");
//       }
//     } catch (e) {
//       print("Lỗi load data: $e");
//       if (mounted) {
//         setState(() {
//           email = user.email ?? "";
//           isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // --- Tiêu đề ---
//             Container(
//               padding: const EdgeInsets.all(12),
//               color: const Color(0xFFFFEEDB),
//               child: const Text(
//                 "THÔNG TIN KHÁCH HÀNG", // Đã sửa tiêu đề cho phù hợp context
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),

//             // --- Các trường thông tin ---
//             _buildInfoRow("Họ Tên:", hoTen.isEmpty ? "Chưa cập nhật" : hoTen),
//             const SizedBox(height: 10),
//             _buildInfoRow("Ngày sinh:", ngaySinh.isEmpty ? "Chưa cập nhật" : ngaySinh),
//             const SizedBox(height: 10),
//             _buildInfoRow("Giới tính:", gioiTinh.isEmpty ? "Chưa cập nhật" : gioiTinh),
//             const SizedBox(height: 10),
//             _buildInfoRow("Email:", email.isEmpty ? "Chưa cập nhật" : email),
//             const SizedBox(height: 10),
//             _buildInfoRow("Số điện thoại:", soDienThoai.isEmpty ? "Chưa cập nhật" : soDienThoai),

//             const SizedBox(height: 30),

//             // --- Nút sửa thông tin ---
//             SizedBox(
//               height: 50,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF8B4513),
//                 ),
//                 onPressed: () async {
//                   await Navigator.pushNamed(context, '/suaThongTin');
//                   loadData(); 
//                 },
//                 child: const Text(
//                   "SỬA THÔNG TIN CÁ NHÂN",
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: const TextStyle(fontSize: 18),
//         ),
//       ],
//     );
//   }
// }