import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appcafe_user/pages/fragment_account.dart';
import 'package:appcafe_user/pages/fragment_history.dart';
import 'package:appcafe_user/pages/fragment_home.dart';
import 'package:appcafe_user/pages/fragment_setting.dart';
import 'package:appcafe_user/pages/trangchu.dart';
import 'package:appcafe_user/pages/trang_dangky.dart';
import 'package:appcafe_user/pages/chitiet_sanpham.dart';
import 'package:appcafe_user/pages/sua_thongtincanhan.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const TrangDangNhap(),
        '/trangchu': (context) => const TrangChu(),
        '/dangky': (context) => const TrangDangKy(),
        '/account': (context) => const FragmentAccount(),
        '/setting': (context) => const FragmentSetting(),
        '/suaThongTin': (context) => const SuaThongTinCaNhan(),
        '/thongtin_cuahang': (context) => Scaffold(
          appBar: AppBar(title: const Text('Thông tin cửa hàng')),
          body: const Center(child: Text('Thông tin cửa hàng')),
        ),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/chitiet' || settings.name == '/chitiet_sanpham') {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args != null) {
            return MaterialPageRoute(
              builder: (context) => ChiTietSanPham(
                ten: args['ten'] ?? args['Ten'] ?? '',
                gia: args['gia'] ?? args['Gia'] ?? '',
                hinhAnh: args['hinhAnh'] ?? args['hinh'] ?? '',
              ),
            );
          }
        }
        return null;
      },
      title: 'CFPLUS Cafe',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.brown),
      home: const AuthWrapper(),
    );
  }
}

// Widget kiểm tra trạng thái đăng nhập
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _isLoggedIn = user != null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return _isLoggedIn ? const TrangChu() : const TrangDangNhap();
  }
}

class TrangDangNhap extends StatefulWidget {
  const TrangDangNhap({super.key});
  @override
  State<TrangDangNhap> createState() => _TrangDangNhapState();
}

class _TrangDangNhapState extends State<TrangDangNhap> {
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _remember = false;
  bool _obscure = true;
  int _failedAttempts = 0;
  bool _isLocked = false;
  int _remainingSeconds = 0;
  static const int _lockMs = 60 * 1000; // 1 minute
  Timer? _timer;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _failedAttempts = _prefs?.getInt('failedAttempts') ?? 0;
    final lockStart = _prefs?.getInt('lockStartTime') ?? 0;
    if (lockStart > 0) {
      final elapsed = DateTime.now().millisecondsSinceEpoch - lockStart;
      if (elapsed < _lockMs) {
        _startLock(_lockMs - elapsed);
      } else {
        _resetLock();
      }
    }
    final savedEmail = _prefs?.getString('savedEmail');
    final savedPw = _prefs?.getString('savedPw');
    final remember = _prefs?.getBool('remember') ?? false;
    if (remember && savedEmail != null && savedPw != null) {
      _emailCtrl.text = savedEmail;
      _pwCtrl.text = savedPw;
      setState(() => _remember = true);
    }
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass = _pwCtrl.text.trim();
    if (email.isEmpty) {
      _showMsg('Vui lòng nhập email!');
      return;
    }
    if (pass.isEmpty) {
      _showMsg('Vui lòng nhập mật khẩu!');
      return;
    }
    if (_isLocked) {
      _showMsg('Tài khoản bị khóa tạm thời. Vui lòng đợi.');
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pass);
      _showMsg('Đăng nhập thành công!');
      _failedAttempts = 0;
      _prefs?.setInt('failedAttempts', 0);
      if (_remember) {
        _prefs?.setString('savedEmail', email);
        _prefs?.setString('savedPw', pass);
        _prefs?.setBool('remember', true);
      } else {
        _prefs?.remove('savedEmail');
        _prefs?.remove('savedPw');
        _prefs?.setBool('remember', false);
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/trangchu');
    } on FirebaseAuthException {
      _failedAttempts++;
      _prefs?.setInt('failedAttempts', _failedAttempts);
      _showMsg('Sai thông tin! Lần thứ $_failedAttempts');
      if (_failedAttempts >= 3) {
        final now = DateTime.now().millisecondsSinceEpoch;
        _prefs?.setInt('lockStartTime', now);
        _startLock(_lockMs);
      }
    } catch (e) {
      _showMsg('Lỗi: ${e.toString()}');
    }
  }

  void _startLock(int milliseconds) {
    setState(() {
      _isLocked = true;
      _remainingSeconds = (milliseconds / 1000).ceil();
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final next = _remainingSeconds - 1;
      if (next <= 0) {
        t.cancel();
        _resetLock();
      } else {
        setState(() => _remainingSeconds = next);
      }
    });
  }

  void _resetLock() {
    setState(() {
      _isLocked = false;
      _failedAttempts = 0;
      _remainingSeconds = 0;
    });
    _prefs?.setInt('failedAttempts', 0);
    _prefs?.setInt('lockStartTime', 0);
    _timer?.cancel();
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _showMsg('Vui lòng nhập email!');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showMsg('Đã gửi email khôi phục mật khẩu.');
    } catch (e) {
      _showMsg('Không gửi được email: ${e.toString()}');
    }
  }

  void _showMsg(String s) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brown = Colors.brown;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.asset('lib/assets/cfplus.png', 
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 200),
                  ),
                ),
                const SizedBox(height: 8),
                Text('ĐĂNG NHẬP', style: TextStyle(fontSize: 30, color: brown, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Align(alignment: Alignment.centerLeft, child: Text('Người dùng', style: TextStyle(fontSize: 20, color: brown, fontWeight: FontWeight.bold))),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Nhập tên email của bạn',
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerLeft, child: Text('Mật khẩu', style: TextStyle(fontSize: 20, color: brown, fontWeight: FontWeight.bold))),
                const SizedBox(height: 8),
                TextField(
                  controller: _pwCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: 'Nhập mật khẩu của bạn',
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (_isLocked)
                  Text('Bạn đã đăng nhập sai 3 lần. Vui lòng đợi $_remainingSeconds giây...', style: const TextStyle(color: Colors.red)),
                Row(
                  children: [
                    Checkbox(value: _remember, onChanged: (v) => setState(() => _remember = v ?? false)),
                    const SizedBox(width: 4),
                    const Text('Nhớ mật khẩu', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLocked ? null : _login,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.brown[200], padding: const EdgeInsets.symmetric(vertical: 12)),
                    child: const Text('Đăng nhập', style: TextStyle(fontSize: 20, color: Colors.white)),
                  ),
                ),
                TextButton(onPressed: _forgotPassword, child: const Text('Quên mật khẩu?', style: TextStyle(fontSize: 16))),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Chưa có tài khoản?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed('/dangky'),
                      child: const Text('Đăng ký', style: TextStyle(fontSize: 18, color: Colors.brown)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

