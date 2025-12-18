import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FragmentSetting extends StatelessWidget {
  const FragmentSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.account_circle_outlined),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Tài khoản",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_right),
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Thông tin cửa hàng",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_right),
                  ],
                ),
              ),
            ),

            // --- Đăng xuất ---
            GestureDetector(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.logout),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Đăng xuất",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
