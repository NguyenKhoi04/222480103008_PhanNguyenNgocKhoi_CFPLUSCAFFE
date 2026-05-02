import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:appcafe_user/pages/fragment_account.dart';
import 'package:appcafe_user/pages/fragment_setting.dart';
import 'package:appcafe_user/pages/trangchu.dart';
import 'package:appcafe_user/pages/trang_dangky.dart';
import 'package:appcafe_user/pages/chitiet_sanpham.dart';
import 'package:appcafe_user/pages/sua_thongtincanhan.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nocauttwlkmsapbtasec.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5vY2F1dHR3bGttc2FwYnRhc2VjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU0NTcxMTAsImV4cCI6MjA5MTAzMzExMH0.FIcnXKTXWyAeXftywMDufERvhukD3341JOnRI7V1fps',
  );

  runApp(const MyApp());
}

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<bool> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final response =
          await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response.user != null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  Session? getCurrentSession() {
    return _client.auth.currentSession;
  }
}
  final SupabaseClient _client = Supabase.instance.client;

  // =========================
  // ĐĂNG NHẬP EMAIL PASSWORD
  // =========================
  Future<bool> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final response =
          await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response.user != null;
    } catch (e) {
      rethrow;
    }
  }

  

  // =========================
  // QUÊN MẬT KHẨU
  // =========================
  Future<void> resetPassword(
    String email,
  ) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo:
            'com.example.appcafe_user://reset-password',
      );
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // ĐĂNG XUẤT
  // =========================
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // =========================
  // USER HIỆN TẠI
  // =========================
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  Session? getCurrentSession() {
    return _client.auth.currentSession;
  }


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CFPLUS Cafe',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.brown,
      ),
      routes: {
        '/login': (context) => const TrangDangNhap(),
        '/trangchu': (context) => const TrangChu(),
        '/dangky': (context) => const TrangDangKy(),
        '/account': (context) => const FragmentAccount(),
        '/setting': (context) => const FragmentSetting(),
        '/suaThongTin': (context) => const SuaThongTinCaNhan(),
        '/thongtin_cuahang': (context) =>
            const TrangThongTinCuaHang(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/chitiet' ||
            settings.name == '/chitiet_sanpham') {
          final args =
              settings.arguments as Map<String, dynamic>?;

          if (args != null) {
            return MaterialPageRoute(
              builder: (_) => ChiTietSanPham(
                categoryId: args['categoryId'] ??
                    args['CategoryId'] ??
                    0,
                ten: args['ten'] ??
                    args['Ten'] ??
                    '',
                gia: args['gia'] ??
                    args['Gia'] ??
                    '',
                hinhAnh: args['hinhAnh'] ??
                    args['hinh'] ??
                    '',
              ),
            );
          }
        }

        return null;
      },
      home: const AuthWrapper(),
    );
  }
}

// ==========================================
// 1. WIDGET TRANG THÔNG TIN CỬA HÀNG (MỚI)
// ==========================================
class TrangThongTinCuaHang extends StatelessWidget {
  const TrangThongTinCuaHang({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Thông tin cửa hàng')),
      body: const Center(
        child: Text('Thông tin cửa hàng'),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() =>
      _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _loading = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final session = Supabase
        .instance.client.auth.currentSession;

    setState(() {
      _loggedIn = session != null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _loggedIn
        ? const TrangChu()
        : const TrangDangNhap();
  }
}

// ==========================================
// 3. TRANG ĐĂNG NHẬP
// ==========================================
class TrangDangNhap extends StatefulWidget {
  const TrangDangNhap({super.key});

  @override
  State<TrangDangNhap> createState() =>
      _TrangDangNhapState();
}

class _TrangDangNhapState
    extends State<TrangDangNhap> {
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();

  bool _remember = false;
  bool _obscure = true;

  int _failedAttempts = 0;
  bool _isLocked = false;
  int _remainingSeconds = 0;

  static const int _lockMs = 60000;

  Timer? _timer;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();

    _failedAttempts =
        _prefs?.getInt('failedAttempts') ?? 0;

    final remember =
        _prefs?.getBool('remember') ?? false;

    final savedEmail =
        _prefs?.getString('savedEmail') ?? '';

    final savedPw =
        _prefs?.getString('savedPw') ?? '';

    final lockStart =
        _prefs?.getInt('lockStartTime') ?? 0;

    if (remember) {
      _emailCtrl.text = savedEmail;
      _pwCtrl.text = savedPw;
      _remember = true;
    }

    if (lockStart > 0) {
      final now =
          DateTime.now().millisecondsSinceEpoch;

      final diff = now - lockStart;

      if (diff < _lockMs) {
        _startLock(_lockMs - diff);
      } else {
        _resetLock();
      }
    }

    if (mounted) setState(() {});
  }

  Future<void> _login() async {
    if (_isLocked) {
      _showMsg(
          'Bạn đang bị khóa tạm thời.');
      return;
    }

    final email =
        _emailCtrl.text.trim();
    final password =
        _pwCtrl.text.trim();

    if (email.isEmpty) {
      _showMsg('Vui lòng nhập email');
      return;
    }

    if (password.isEmpty) {
      _showMsg('Vui lòng nhập mật khẩu');
      return;
    }

    try {
      final service =
          SupabaseService();

      final success =
          await service.signInWithEmail(
        email,
        password,
      );

      if (success) {
        _failedAttempts = 0;

        await _prefs?.setInt(
            'failedAttempts', 0);

        if (_remember) {
          await _prefs?.setString(
              'savedEmail', email);
          await _prefs?.setString(
              'savedPw', password);
          await _prefs?.setBool(
              'remember', true);
        } else {
          await _prefs?.remove(
              'savedEmail');
          await _prefs?.remove(
              'savedPw');
          await _prefs?.setBool(
              'remember', false);
        }

        if (!mounted) return;

        _showMsg(
            'Đăng nhập thành công');

        Navigator.pushReplacementNamed(
          context,
          '/trangchu',
        );
      } else {
        _failedAttempts++;

        await _prefs?.setInt(
          'failedAttempts',
          _failedAttempts,
        );

        _showMsg(
          'Sai thông tin lần $_failedAttempts',
        );

        if (_failedAttempts >= 3) {
          final now = DateTime.now()
              .millisecondsSinceEpoch;

          await _prefs?.setInt(
            'lockStartTime',
            now,
          );

          _startLock(_lockMs);
        }
      }
    } catch (e) {
      _showMsg(
        'Lỗi đăng nhập: $e',
      );
    }
  }

  void _startLock(int ms) {
    _timer?.cancel();

    setState(() {
      _isLocked = true;
      _remainingSeconds =
          (ms / 1000).ceil();
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_remainingSeconds <= 1) {
          timer.cancel();
          _resetLock();
        } else {
          setState(() {
            _remainingSeconds--;
          });
        }
      },
    );
  }

  void _resetLock() {
    _timer?.cancel();

    setState(() {
      _isLocked = false;
      _failedAttempts = 0;
      _remainingSeconds = 0;
    });

    _prefs?.setInt(
        'failedAttempts', 0);
    _prefs?.setInt(
        'lockStartTime', 0);
  }

  Future<void> _forgotPassword() async {
    final email =
        _emailCtrl.text.trim();

    if (email.isEmpty) {
      _showMsg(
          'Vui lòng nhập email');
      return;
    }

    try {
      final service =
          SupabaseService();

      await service.resetPassword(
          email);

      _showMsg(
          'Đã gửi email khôi phục');
    } catch (e) {
      _showMsg(
          'Không gửi được: $e');
    }
  }

  void _showMsg(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(msg),
      ),
    );
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
          child:
              SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                // Logo
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.asset(
                    'lib/assets/cfplus.png',
                    fit: BoxFit.contain,
                    errorBuilder:
                        (_, __, ___) =>
                            const Icon(
                      Icons.image,
                      size: 200,
                    ),
                  ),
                ),
                const SizedBox(
                    height: 8),
                Text(
                  'ĐĂNG NHẬP',
                  style: TextStyle(
                    fontSize: 30,
                    color: brown,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(
                    height: 16),
                Align(
                  alignment:
                      Alignment.centerLeft,
                  child: Text(
                    'Người dùng',
                    style: TextStyle(
                      fontSize: 20,
                      color: brown,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                    height: 8),
                TextField(
                  controller:
                      _emailCtrl,
                  decoration:
                      InputDecoration(
                    hintText:
                        'Nhập tên email của bạn',
                    filled: true,
                    fillColor:
                        Colors.grey[100],
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                              12),
                      borderSide:
                          BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(
                    height: 12),
                Align(
                  alignment:
                      Alignment.centerLeft,
                  child: Text(
                    'Mật khẩu',
                    style: TextStyle(
                      fontSize: 20,
                      color: brown,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                    height: 8),
                TextField(
                  controller:
                      _pwCtrl,
                  obscureText:
                      _obscure,
                  decoration:
                      InputDecoration(
                    hintText:
                        'Nhập mật khẩu của bạn',
                    filled: true,
                    fillColor:
                        Colors.grey[100],
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                              12),
                      borderSide:
                          BorderSide.none,
                    ),
                    suffixIcon:
                        IconButton(
                      onPressed: () {
                        setState(() {
                          _obscure =
                              !_obscure;
                        });
                      },
                      icon: Icon(
                        _obscure
                            ? Icons
                                .visibility_off
                            : Icons
                                .visibility,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                    height: 8),
                if (_isLocked)
                  Text(
                    'Bạn đã đăng nhập sai 3 lần. Đợi $_remainingSeconds giây...',
                    style:
                        const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                Row(
                  children: [
                    Checkbox(
                      value:
                          _remember,
                      onChanged:
                          (v) {
                        setState(() {
                          _remember =
                              v ??
                                  false;
                        });
                      },
                    ),
                    const Text(
                      'Nhớ mật khẩu',
                    ),
                  ],
                ),
                const SizedBox(
                    height: 8),
                SizedBox(
                  width: double.infinity,
                  child:
                      ElevatedButton(
                    onPressed:
                        _isLocked
                            ? null
                            : _login,
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.brown[
                              200],
                      padding:
                          const EdgeInsets.symmetric(
                        vertical:
                            12,
                      ),
                    ),
                    child:
                        const Text(
                      'Đăng nhập',
                      style:
                          TextStyle(
                        fontSize:
                            20,
                        color: Colors
                            .white,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed:
                      _forgotPassword,
                  child:
                      const Text(
                    'Quên mật khẩu?',
                  ),
                ),
                const SizedBox(
                    height: 12),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                  children: [
                    const Text(
                      'Chưa có tài khoản?',
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/dangky',
                        );
                      },
                      child:
                          const Text(
                        'Đăng ký',
                        style:
                            TextStyle(
                          color: Colors
                              .brown,
                        ),
                      ),
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