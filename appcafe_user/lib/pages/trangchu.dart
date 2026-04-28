import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:appcafe_user/pages/fragment_account.dart';
import 'package:appcafe_user/pages/fragment_history.dart';
import 'package:appcafe_user/pages/fragment_home.dart';
import 'package:appcafe_user/pages/fragment_setting.dart';
import 'package:appcafe_user/pages/chat_user.dart';

class TrangChu extends StatefulWidget {
  const TrangChu({super.key});

  @override
  State<TrangChu> createState() => _TrangChuState();
}

class _TrangChuState extends State<TrangChu> {
  final supabase = Supabase.instance.client;

  int _currentIndex = 0;
  String tenNhanVien = "Hello, CFPLUS";

  final PageController _pageController = PageController();

  bool showFrame = false;
  bool showViewPager = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  // ==========================================
  // LẤY TÊN KHÁCH HÀNG TỪ SUPABASE
  // bảng users
  // id = auth uid
  // role bắt buộc customer
  // ==========================================
  Future<void> _loadUserName() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          tenNhanVien = "Xin chào quý khách!";
        });
      }
      return;
    }

    try {
      final data = await supabase
          .from('users')
          .select('full_name')
          .eq('id', user.id)
          .eq('role', 'customer')
          .single();

      final hoTen = (data['full_name'] ?? '').toString().trim();

      if (!mounted) return;

      setState(() {
        tenNhanVien = hoTen.isEmpty
            ? "Xin chào quý khách!"
            : "Xin chào quý khách, $hoTen !";
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        tenNhanVien = "Xin chào quý khách!";
      });

      debugPrint("Lỗi lấy tên khách hàng: $e");
    }
  }

  // ==========================================
  // CALLBACK TỪ HISTORY -> HOME
  // ==========================================
  void onThemHangClick() {
    setState(() {
      showFrame = false;
      showViewPager = true;
      _currentIndex = 0;
    });

    _pageController.jumpToPage(0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
            child: Image.asset(
              "lib/assets/cfplus.png",
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox(),
            ),
          ),

          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  "lib/assets/cfplus.png",
                  width: 50,
                  height: 50,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image, size: 50),
                ),
              ),

              Expanded(
                child: Text(
                  tenNhanVien,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.brown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // ================= BODY =================
          Expanded(
            child: Stack(
              children: [
                Visibility(
                  visible: showViewPager,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    children: [
                      FragmentHome(onThemHang: onThemHangClick),
                      FragmentHistory(onThemHang: onThemHangClick),
                      const FragmentAccount(),
                      const FragmentSetting(),
                    ],
                  ),
                ),

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

      // ================= BOTTOM NAV =================
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex.clamp(0, 4),
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          // Chat
          if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ChatUserScreen(),
              ),
            );
            return;
          }

          setState(() {
            _currentIndex = index;
            showFrame = false;
            showViewPager = true;
          });

          _pageController.jumpToPage(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Account",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Setting",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Chat",
          ),
        ],
      ),
    );
  }

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


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:appcafe_user/pages/fragment_account.dart';
// import 'package:appcafe_user/pages/fragment_history.dart';
// import 'package:appcafe_user/pages/fragment_home.dart';
// import 'package:appcafe_user/pages/fragment_setting.dart';
// import 'package:appcafe_user/pages/chat_user.dart';

// class TrangChu extends StatefulWidget {
//   const TrangChu({super.key});

//   @override
//   State<TrangChu> createState() => _TrangChuState();
// }

// class _TrangChuState extends State<TrangChu> {
//   int _currentIndex = 0;
//   String tenNhanVien = "Hello, CFPLUS";

//   final PageController _pageController = PageController();

//   bool showFrame = false;  // thay cho FrameLayout
//   bool showViewPager = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserName();
//   }

//   /// ================================
//   // 🔥 LẤY "Họ tên KH" từ Firestore
//   // Path: /Người dùng/Nhân viên/KhacHang/{uid}
//   // ================================
//   Future<void> _loadUserName() async {
//     User? user = FirebaseAuth.instance.currentUser;
    
//     // Nếu chưa đăng nhập
//     if (user == null) {
//       if (mounted) {
//         setState(() => tenNhanVien = "Xin chào quý khách!");
//       }
//       return;
//     }

//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection("Người dùng")
//           .doc("Nhân viên")
//           .collection("KhacHang")
//           .doc(user.uid)
//           .get()
//           .timeout(const Duration(seconds: 5));

//       if (doc.exists && mounted) {
//         final data = doc.data(); // Lấy dữ liệu dạng Map
        
//         // Kiểm tra xem field "Họ tên KH" có tồn tại và có dữ liệu không
//         if (data != null && data.containsKey("Họ tên KH")) {
//           String hoTen = data["Họ tên KH"].toString();

//           if (hoTen.isNotEmpty) {
//             setState(() {
//               // ✅ ĐÚNG YÊU CẦU: Thêm "quý khách" và dấu "!"
//               tenNhanVien = "Xin chào quý khách, $hoTen !"; 
//             });
//           } else {
//             setState(() => tenNhanVien = "Xin chào quý khách!");
//           }
//         } else {
//           // Có doc nhưng không có field tên
//           setState(() => tenNhanVien = "Xin chào quý khách!");
//         }
//       } else {
//         // Không tìm thấy document
//         if (mounted) setState(() => tenNhanVien = "Xin chào quý khách!");
//       }
//     } catch (e) {
//       // Lỗi kết nối hoặc lỗi khác
//       if (mounted) setState(() => tenNhanVien = "Xin chào quý khách!");
//       debugPrint("Lỗi lấy tên khách hàng: $e");
//     }
//   }

//   // =================================================
//   // 🔥 Callback từ FragmentHistory → quay về Home
//   // =================================================
//   void onThemHangClick() {
//     setState(() {
//       showFrame = false;
//       showViewPager = true;
//       _currentIndex = 0;
//     });
//     _pageController.jumpToPage(0);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [

//           // ================= HEADER =================
//           Container(
//             width: double.infinity,
//             height: 70,
//             color: const Color(0xFFF5E6CC),
//             child: Image.asset("lib/assets/cfplus.png", 
//               fit: BoxFit.contain,
//               errorBuilder: (context, error, stackTrace) => const SizedBox(),
//             ),
//           ),

//           Row(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8),
//                 child: Image.asset("lib/assets/cfplus.png", 
//                   width: 50, 
//                   height: 50,
//                   errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 50),
//                 ),
//               ),

//               Expanded(
//                 child: Text(
//                   tenNhanVien,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                       fontSize: 20, color: Colors.brown, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ],
//           ),

//           // ================== NỘI DUNG (STACK) ==================
//           Expanded(
//             child: Stack(
//               children: [

//                 // PageView (giống ViewPager2)
//                 Visibility(
//                   visible: showViewPager,
//                   child: PageView(
//                     controller: _pageController,
//                     onPageChanged: (index) {
//                       setState(() => _currentIndex = index);
//                     },
//                     children: [
//                       FragmentHome(onThemHang: onThemHangClick),
//                       FragmentHistory(onThemHang: onThemHangClick),
//                       const FragmentAccount(),
//                       const FragmentSetting(),
//                     ],
//                   ),
//                 ),

//                 // FrameLayout thay thế
//                 Visibility(
//                   visible: showFrame,
//                   child: Container(
//                     color: Colors.white,
//                     child: _buildSelectedFragment(),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),

//       // ================= BOTTOM NAV ==================
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         currentIndex: _currentIndex.clamp(0, 4),
//         selectedItemColor: Colors.brown,
//         unselectedItemColor: Colors.grey,
//         onTap: (index) {
//           // Nếu tap vào Chat (index 4)
//           if (index == 4) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const ChatUserScreen(),
//               ),
//             );
//             return;
//           }
          
//           setState(() {
//             _currentIndex = index;
//             showFrame = false;
//             showViewPager = true;
//           });
//           _pageController.jumpToPage(index);
//         },
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
//           BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Setting"),
//           BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
//         ],
//       ),
//     );
//   }

//   // Fragment khi showFrame = true
//   Widget _buildSelectedFragment() {
//     switch (_currentIndex) {
//       case 0:
//         return FragmentHome(onThemHang: onThemHangClick);
//       case 1:
//         return FragmentHistory(onThemHang: onThemHangClick);
//       case 2:
//         return const FragmentAccount();
//       case 3:
//         return const FragmentSetting();
//       default:
//         return Container();
//     }
//   }
// }
