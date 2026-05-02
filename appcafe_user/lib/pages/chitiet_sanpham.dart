import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChiTietSanPham extends StatefulWidget {
  final String ten;
  final double gia;
  final String hinhAnh;
  final int categoryId;

  static const routeName = "/chitiet_sanpham";

  const ChiTietSanPham({
    super.key,
    required this.ten,
    required this.gia,
    required this.hinhAnh,
    required this.categoryId,
  });


  @override
  State<ChiTietSanPham> createState() => _ChiTietSanPhamState();
}

class _ChiTietSanPhamState extends State<ChiTietSanPham> {
  int soLuong = 1;
  late int giaSanPham;

  String? selectedSize;
  String? selectedIce;

  @override
  void initState() {
    super.initState();
    giaSanPham = widget.gia.toInt();
  }

  int get tongTien => soLuong * giaSanPham;

  String formatTien(int tien) {
    return tien.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
        );
  }

  bool get isExtraProduct => 
      widget.categoryId == 9 || widget.categoryId == 10;
      
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text("Chi tiết sản phẩm"),
        backgroundColor: Colors.brown,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.hinhAnh,
                width: 220,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              widget.ten,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown),
              textAlign: TextAlign.center,
            ),
            if (!isExtraProduct) ...[
              const SizedBox(height: 20),
              _buildBlock(
                title: "Chọn Size",
                child: Column(
                  children: [
                    _radioSize("S"),
                    _radioSize("M"),
                    _radioSize("L"),
                  ],
                ),
              ),
            ],
           if (!isExtraProduct) ...[
              const SizedBox(height: 20),
              _buildBlock(
                title: "Chọn mức đá",
                child: Column(
                  children: [
                    _radioIce("Đá bình thường"),
                    _radioIce("Ít đá"),
                    _radioIce("Đá riêng"),
                    _radioIce("Không đá"),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Số lượng",
                        style: TextStyle(color: Colors.grey)),
                    Text(
                      "Tổng tiền: ${formatTien(tongTien)} đ",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.brown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (soLuong > 1) {
                          setState(() => soLuong--);
                        }
                      },
                    ),
                    Text(
                      "$soLuong",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() => soLuong++);
                      },
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 20),
            _button(
              text: "Thêm vào giỏ hàng",
              onTap: () {
                if (!isExtraProduct && (selectedSize == null || selectedIce == null)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Vui lòng chọn size và mức đá")),
                  );
                  return;
                }
                _showThongTinDialog();
              },
            ),
            const SizedBox(height: 12),
            _button(
              text: "Trở về trang chủ",
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // ================= WIDGET =================

  Widget _buildBlock({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.brown,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _radioSize(String s) {
    return RadioListTile<String>(
      title: Text(s),
      value: s,
      groupValue: selectedSize,
      onChanged: (v) => setState(() => selectedSize = v),
    );
  }

  Widget _radioIce(String s) {
    return RadioListTile<String>(
      title: Text(s),
      value: s,
      groupValue: selectedIce,
      onChanged: (v) => setState(() => selectedIce = v),
    );
  }

  Widget _button({required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
            color: Colors.brown, borderRadius: BorderRadius.circular(10)),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

 // ================= DIALOG + FIRESTORE =================

  void _showThongTinDialog() {
    final editBan = TextEditingController();
    final editSdt = TextEditingController();
    final editNv = TextEditingController();
    
    // 🔥 SỬA LỖI: Khai báo biến này Ở NGOÀI StatefulBuilder
    String hinhThuc = "Mang về"; 

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          // KHÔNG ĐƯỢC khai báo hinhThuc ở đây

          return AlertDialog(
            title: const Text("Thông tin đặt"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: editBan,
                    decoration: const InputDecoration(
                      labelText: "Tên bàn",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: editSdt,
                    decoration: const InputDecoration(
                      labelText: "Số điện thoại",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: editNv,
                    decoration: const InputDecoration(
                      labelText: "Tên nhân viên",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Hình thức đặt:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                  ),
                  
                  // Radio Button 1: Mang về
                  RadioListTile<String>(
                    title: const Text("Mang về"),
                    value: "Mang về",
                    groupValue: hinhThuc,
                    onChanged: (v) {
                      setState(() {
                        hinhThuc = v!;
                      });
                    },
                  ),
                  
                  // Radio Button 2: Tại chỗ
                  RadioListTile<String>(
                    title: const Text("Tại chỗ"),
                    value: "Tại chỗ",
                    groupValue: hinhThuc,
                    onChanged: (v) {
                      setState(() {
                        hinhThuc = v!;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text("Hủy"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                ),
                onPressed: () async {
                  if (editBan.text.isEmpty ||
                      editSdt.text.isEmpty ||
                      editNv.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Điền đầy đủ thông tin")),
                    );
                    return;
                  }

                  try {
                    // 🔥 LƯU Ý: Kiểm tra lại tên Collection cho khớp với code hiển thị
                    // Nếu bên hiển thị bạn dùng "DonHang" thì ở đây cũng phải là "DonHang"
                    final docRef = await FirebaseFirestore.instance
                        .collection("DonHang") // Khuyên dùng không dấu
                        .doc("GioHang")
                        .collection("SanPham") // Khuyên dùng không dấu
                        .add({
                      "tenBan": editBan.text,
                      "soDienThoai": editSdt.text,
                      "tenNhanVien": editNv.text,
                      "hinhThuc": hinhThuc, // Giá trị này giờ sẽ đúng
                      "tenSanPham": widget.ten, // Đảm bảo widget.ten có dữ liệu
                      "soLuong": soLuong,       // Đảm bảo biến soLuong có dữ liệu
                      "size": isExtraProduct ? "" :selectedSize,     // Đảm bảo biến selectedSize có dữ liệu
                      "mucDa":isExtraProduct ? "" : selectedIce,     // Đảm bảo biến selectedIce có dữ liệu
                      "gia": giaSanPham,        // Đảm bảo biến giaSanPham có dữ liệu
                      "tongTien": tongTien,     // Đảm bảo biến tongTien có dữ liệu
                      "hinhAnh": widget.hinhAnh,
                      "trangThaiThanhToan": "Chưa thanh toán",
                      "trangThai": "Đang chờ",
                      "thoiGian": Timestamp.now(),
                    });

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Thêm vào giỏ thành công!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                      // Đóng màn hình chi tiết sản phẩm sau khi thêm xong (nếu cần)
                      Future.delayed(const Duration(milliseconds: 500), () {
                         if(mounted) Navigator.pop(context);
                      });
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Lỗi: $e")),
                    );
                  }
                },
                child: const Text(
                  "Thêm",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
