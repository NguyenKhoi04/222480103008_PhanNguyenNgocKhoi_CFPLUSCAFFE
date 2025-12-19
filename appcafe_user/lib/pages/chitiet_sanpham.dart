import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChiTietSanPham extends StatefulWidget {
  final String ten;
  final String gia;
  final String hinhAnh;

  const ChiTietSanPham({
    super.key,
    required this.ten,
    required this.gia,
    required this.hinhAnh,
  });

  @override
  State<ChiTietSanPham> createState() => _ChiTietSanPhamState();
}

class _ChiTietSanPhamState extends State<ChiTietSanPham> {
  int soLuong = 1;
  int giaSanPham = 0;

  // Size
  String? selectedSize;

  // Đá
  String? selectedIce;

  @override
  void initState() {
    super.initState();
    giaSanPham = int.tryParse(widget.gia.replaceAll(RegExp(r'[^0-9]'), "")) ?? 0;
  }

  int get tongTien => soLuong * giaSanPham;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text("Chi tiết sản phẩm"),
        backgroundColor: Colors.blue,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // Ảnh sản phẩm
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

            // Tên
            Text(
              widget.ten,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Chọn size
            _buildBlock(
              title: "Chọn Size",
              child: Row(
                children: [
                  _sizeButton("S"),
                  _sizeButton("M"),
                  _sizeButton("L"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Chọn đá
            _buildBlock(
              title: "Chọn mức đá",
              child: Column(
                children: [
                  _iceButton("Đá bình thường"),
                  _iceButton("Ít đá"),
                  _iceButton("Đá riêng"),
                  _iceButton("Không đá"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Số lượng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Số lượng", style: TextStyle(color: Colors.grey)),
                    Text("Tổng tiền: $tongTien đ",
                        style: const TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold)),
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
                    Text("$soLuong",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
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

            // Thêm vào giỏ
            _button(
              text: "Thêm vào giỏ hàng",
              onTap: () {
                if (selectedSize == null || selectedIce == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Vui lòng chọn size và mức đá")),
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

  // Widget Khối hình chữ nhật
  Widget _buildBlock({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  // Button chọn size
  Widget _sizeButton(String s) {
    return Row(
      children: [
        Checkbox(
          value: selectedSize == s,
          onChanged: (_) {
            setState(() => selectedSize = s);
          },
        ),
        Text(s, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // Button chọn đá
  Widget _iceButton(String text) {
    return Row(
      children: [
        Checkbox(
          value: selectedIce == text,
          onChanged: (_) {
            setState(() => selectedIce = text);
          },
        ),
        Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _button({required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
            color: Colors.blue, borderRadius: BorderRadius.circular(10)),
        child: Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }

  // ==============================
  //      DIALOG + FIRESTORE
  // ==============================

  void _showThongTinDialog() {
    final editBan = TextEditingController();
    final editSdt = TextEditingController();
    final editNv = TextEditingController();
    String hinhThuc = "Mang về";

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text("Thông tin đặt"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: editBan, decoration: const InputDecoration(labelText: "Tên bàn")),
              TextField(controller: editSdt, decoration: const InputDecoration(labelText: "Số điện thoại")),
              TextField(controller: editNv, decoration: const InputDecoration(labelText: "Tên nhân viên")),
              const SizedBox(height: 10),
              const Text("Hình thức:"),
              RadioListTile(
                title: const Text("Mang về"),
                value: "Mang về",
                groupValue: hinhThuc,
                onChanged: (v) => setDialogState(() => hinhThuc = v!),
              ),
              RadioListTile(
                title: const Text("Tại chỗ"),
                value: "Tại chỗ",
                groupValue: hinhThuc,
                onChanged: (v) => setDialogState(() => hinhThuc = v!),
              ),
            ],
          ),

          actions: [
            TextButton(
              child: const Text("Hủy"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Thêm"),
              onPressed: () async {
              if (editBan.text.isEmpty ||
                  editSdt.text.isEmpty ||
                  editNv.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Điền đầy đủ thông tin")),
                );
                return;
              }

              await FirebaseFirestore.instance
                  .collection("Đơn hàng")
                  .doc("Giỏ hàng")
                  .collection("Sản phẩm")
                  .add({
                "Tên bàn": editBan.text,
                "Số điện thoại": editSdt.text,
                "Tên nhân viên": editNv.text,
                "Hình thức": hinhThuc,
                "Tên sản phẩm": widget.ten,
                "Số lượng": soLuong,
                "Size": selectedSize,
                "Mức đá": selectedIce,
                "Giá": giaSanPham,
                "Tổng tiền": tongTien,
                "Hình ảnh": widget.hinhAnh,
                "trangthaithanhtoan": "Chưa thanh toán",
              });

              Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Thêm vào giỏ thành công!")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
