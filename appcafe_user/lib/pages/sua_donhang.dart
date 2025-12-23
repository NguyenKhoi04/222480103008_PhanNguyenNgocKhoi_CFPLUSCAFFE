import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'DonHang.dart';

class SuaDonHang extends StatefulWidget {
  final DonHang donHang;

  const SuaDonHang({super.key, required this.donHang});

  @override
  State<SuaDonHang> createState() => _SuaDonHangState();
}

class _SuaDonHangState extends State<SuaDonHang> {
  late TextEditingController soLuongCtrl;
  late String trangThai;
  late int tongTienMoi;

  @override
  void initState() {
    super.initState();
    soLuongCtrl =
        TextEditingController(text: widget.donHang.soLuong.toString());
    trangThai = widget.donHang.trangThai;
    tongTienMoi = widget.donHang.tongTien;

    // Tính lại tổng tiền khi số lượng thay đổi
    soLuongCtrl.addListener(() {
      final soLuongMoi =
          int.tryParse(soLuongCtrl.text) ?? widget.donHang.soLuong;
      setState(() {
        tongTienMoi = soLuongMoi * widget.donHang.giaDonVi;
      });
    });
  }

  Future<void> updateDonHang() async {
    try {
      await FirebaseFirestore.instance
          .collection("DonHang")
          .doc("GioHang")
          .collection("SanPham")
          .doc(widget.donHang.id)
          .update({
        'soLuong': int.parse(soLuongCtrl.text),
        'tongTien': tongTienMoi,
        'trangthaiThanhToan': trangThai,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật thành công!")),
        );
        Navigator.pop(context, true); // Trả về true để báo hiệu cần reload
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sửa đơn hàng")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Sản phẩm: ${widget.donHang.tenSanPham}"),
            TextField(
              controller: soLuongCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Số lượng"),
            ),
            const SizedBox(height: 12),
            Text(
              "Giá đơn vị: ${widget.donHang.giaDonVi} đ",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              "Tổng tiền: $tongTienMoi đ",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: trangThai,
              items: const [
                DropdownMenuItem(
                    value: "Chưa thanh toán", child: Text("Chưa thanh toán")),
                DropdownMenuItem(
                    value: "Đã thanh toán", child: Text("Đã thanh toán")),
              ],
              onChanged: (v) => setState(() => trangThai = v!),
              decoration:
                  const InputDecoration(labelText: "Trạng thái thanh toán"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateDonHang,
              child: const Text("LƯU"),
            ),
          ],
        ),
      ),
    );
  }
}
