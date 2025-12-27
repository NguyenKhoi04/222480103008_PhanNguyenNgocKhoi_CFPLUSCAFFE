import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Đảm bảo đường dẫn import đúng với cấu trúc thư mục của bạn
import 'DanhGia.dart'; 

class FragmentSetting extends StatelessWidget {
  const FragmentSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Thêm background màu xám nhạt để các box màu trắng nổi bật hơn (tuỳ chọn)
      backgroundColor: Colors.white, 
      body: SingleChildScrollView( // Thêm Scroll để tránh lỗi tràn màn hình trên máy nhỏ
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- Tài khoản ---
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/account');
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [ // Thêm const để tối ưu
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.account_circle_outlined, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Tài khoản",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_right, color: Colors.grey),
                  ],
                ),
              ),
            ),

            // --- Thông tin cửa hàng ---
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/thongtin_cuahang');
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.store_outlined, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Thông tin cửa hàng",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_right, color: Colors.grey),
                  ],
                ),
              ),
            ),

            // --- Đánh giá & Phản hồi (MỚI THÊM) ---
            GestureDetector(
              onTap: () {
                // Chuyển hướng đến trang DanhGiaPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DanhGiaPage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  children: const [
                    // Icon ngôi sao hoặc phản hồi
                    Icon(Icons.rate_review_outlined, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Đánh giá & Phản hồi",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_right, color: Colors.grey),
                  ],
                ),
              ),
            ),

            // --- Đăng xuất ---
            GestureDetector(
              onTap: () async {
                // Hiển thị dialog xác nhận trước khi đăng xuất
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Đăng xuất'),
                    content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (route) => false);
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Đăng xuất",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}