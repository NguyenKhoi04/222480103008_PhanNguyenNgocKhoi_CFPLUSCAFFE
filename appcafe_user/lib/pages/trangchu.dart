import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:appcafe_user/pages/fragment_account.dart';
import 'package:appcafe_user/pages/fragment_history.dart';
import 'package:appcafe_user/pages/fragment_home.dart';
import 'package:appcafe_user/pages/fragment_setting.dart';

class TrangChu extends StatefulWidget {
  const TrangChu({super.key});

  @override
  State<TrangChu> createState() => _TrangChuState();
}

class _TrangChuState extends State<TrangChu> {
  int _currentIndex = 0;
  String tenNhanVien = "Hello, CFPLUS";

  final PageController _pageController = PageController();

  bool showFrame = false;  // thay cho FrameLayout
  bool showViewPager = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  // ================================
  // 🔥 LẤY "Họ tên NV" từ Firestore
  // ================================
  Future<void> _loadUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => tenNhanVien = "Xin chào!");
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection("Người dùng")
          .doc("Nhân viên")
          .get()
          .timeout(const Duration(seconds: 5));

      if (doc.exists && mounted) {
        String? email = doc.get("Email");
        String? hoTen = doc.get("Họ tên NV");

        if (email == user.email && hoTen != null && hoTen.isNotEmpty) {
          setState(() {
            tenNhanVien = "Xin chào, $hoTen";
          });
        } else {
          setState(() => tenNhanVien = "Xin chào!");
        }
      } else if (mounted) {
        setState(() => tenNhanVien = "Xin chào!");
      }
    } catch (e) {
      if (mounted) {
        setState(() => tenNhanVien = "Xin chào!");
      }
    }
  }

  // =================================================
  // 🔥 Callback từ FragmentHistory → quay về Home
  // =================================================
  void onThemHangClick() {
    setState(() {
      showFrame = false;
      showViewPager = true;
      _currentIndex = 0;
    });
    _pageController.jumpToPage(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

          // ================= HEADER =================
          Container(
            width: double.infinity,
            height: 70,
            color: const Color(0xFFF5E6CC),
            child: Image.asset("lib/assets/cfplus.png", 
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),

          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset("lib/assets/cfplus.png", 
                  width: 50, 
                  height: 50,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 50),
                ),
              ),

              Expanded(
                child: Text(
                  tenNhanVien,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20, color: Colors.brown, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          // ================== NỘI DUNG (STACK) ==================
          Expanded(
            child: Stack(
              children: [

                // PageView (giống ViewPager2)
                Visibility(
                  visible: showViewPager,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    children: [
                      FragmentHome(onThemHang: onThemHangClick),
                      FragmentHistory(onThemHang: onThemHangClick),
                      const FragmentAccount(),
                      const FragmentSetting(),
                    ],
                  ),
                ),

                // FrameLayout thay thế
                Visibility(
                  visible: showFrame,
                  child: Container(
                    color: Colors.white,
                    child: _buildSelectedFragment(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ================= BOTTOM NAV ==================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            showFrame = false;
            showViewPager = true;
          });
          _pageController.jumpToPage(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Setting"),
        ],
      ),
    );
  }

  // Fragment khi showFrame = true
  Widget _buildSelectedFragment() {
    switch (_currentIndex) {
      case 0:
        return FragmentHome(onThemHang: onThemHangClick);
      case 1:
        return FragmentHistory(onThemHang: onThemHangClick);
      case 2:
        return const FragmentAccount();
      case 3:
        return const FragmentSetting();
      default:
        return Container();
    }
  }
}
