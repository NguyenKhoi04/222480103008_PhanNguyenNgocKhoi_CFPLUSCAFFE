import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class TrangDangKy extends StatefulWidget {
  const TrangDangKy({super.key});

  @override
  State<TrangDangKy> createState() => _TrangDangKyState();
}

class _TrangDangKyState extends State<TrangDangKy> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController passAgainController = TextEditingController();

  bool showEmailError = false;
  bool showPassError = false;
  bool showPassAgainError = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Image.asset("lib/assets/cfplus.png", width: 180, height: 180),

            Text(
              "ĐĂNG KÝ",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.brown[700],
              ),
            ),

            // EMAIL
            const SizedBox(height: 15),
            _buildTitle("Email"),
            _buildTextField(emailController, "Nhập email của bạn"),

            if (showEmailError)
              const Text(
                "Email không đúng định dạng!",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),

            // PASS
            const SizedBox(height: 15),
            _buildTitle("Mật khẩu mới"),
            _buildPasswordField(passController, "Nhập mật khẩu mới của bạn"),

            if (showPassError)
              const Text(
                "Mật khẩu phải từ 6 ký tự, gồm chữ và số!",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),

            // PASS AGAIN
            const SizedBox(height: 15),
            _buildTitle("Nhập lại mật khẩu"),
            _buildPasswordField(passAgainController, "Nhập lại mật khẩu"),

            if (showPassAgainError)
              const Text(
                "Mật khẩu nhập lại không khớp!",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),

            const SizedBox(height: 20),
            _buildButton("Đăng ký", _validateAndShowOTP),

            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Bạn đã có tài khoản?",
                    style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    "Đăng nhập",
                    style: TextStyle(
                        color: Colors.brown[700],
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  // ----- UI Component -----

  Widget _buildTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown[700]),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        hintText: hint,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      style: const TextStyle(fontSize: 18),
    );
  }

  Widget _buildPasswordField(
      TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        filled: true,
        hintText: hint,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      style: const TextStyle(fontSize: 18),
    );
  }

  Widget _buildButton(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text,
            style: TextStyle(
                color: Colors.brown[700],
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  // =============================
  // VALIDATE + SHOW OTP DIALOG
  // =============================

  void _validateAndShowOTP() {
    final email = emailController.text.trim();
    final pass = passController.text.trim();
    final passAgain = passAgainController.text.trim();

    setState(() {
      showEmailError = !RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$")
          .hasMatch(email);

      showPassError = pass.length < 6 ||
          !pass.contains(RegExp(r'[A-Za-z]')) ||
          !pass.contains(RegExp(r'\d'));

      showPassAgainError = pass != passAgain;
    });

    if (!showEmailError && !showPassError && !showPassAgainError) {
      _showOtpDialog(email);
    }
  }

  // =============================
  // OTP DIALOG
  // =============================

  void _showOtpDialog(String email) {
    final TextEditingController otpController = TextEditingController();
    String otp = (Random().nextInt(900000) + 100000).toString();

    // Gửi OTP
    _sendOtpToEmail(email, otp);

    int count = 120;
    Timer? timer;

    showDialog(
      context: context,
      builder: (context) {
        timer = Timer.periodic(const Duration(seconds: 1), (t) {
          setState(() => count--);
          if (count <= 0) t.cancel();
        });

        return AlertDialog(
          title: const Text("Xác thực OTP"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("OTP đã gửi tới email của bạn"),
              const SizedBox(height: 10),
              TextField(
                controller: otpController,
                decoration: const InputDecoration(hintText: "Nhập OTP"),
              ),
              const SizedBox(height: 10),
              Text("Mã hết hạn sau: ${count}s",
                  style: const TextStyle(color: Colors.red)),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  if (otpController.text.trim() == otp) {
                    Navigator.pop(context);
                    timer?.cancel();
                    _registerFirebase();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("OTP sai!")),
                    );
                  }
                },
                child: const Text("Xác nhận")),
          ],
        );
      },
    );
  }

  // =============================
  // GỬI OTP MAILER
  // =============================

  Future<void> _sendOtpToEmail(String email, String otp) async {
    String username = "ngkhoi04@gmail.com";
    String password = "kozc bukv vjoz nswq"; // app password của Gmail

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, "CFPLUS Cafe")
      ..recipients.add(email)
      ..subject = "Mã OTP xác thực"
      ..text = "Mã OTP của bạn là: $otp\nCó hiệu lực trong 2 phút.";

    try {
      await send(message, smtpServer);
      print("Gửi email thành công");
    } catch (e) {
      print("Gửi email lỗi: $e");
    }
  }

  // =============================
  // FIREBASE REGISTER
  // =============================

  Future<void> _registerFirebase() async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đăng ký thành công!")),
      );

      Navigator.pushReplacementNamed(context, "/trangchu");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi đăng ký: $e")),
      );
    }
  }
}
