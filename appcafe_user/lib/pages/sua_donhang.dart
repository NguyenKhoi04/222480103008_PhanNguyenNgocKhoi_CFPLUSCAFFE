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
  late int giaMotLy;

  @override
  void initState() {
    super.initState();
    soLuongCtrl = TextEditingController(text: widget.donHang.soLuong.toString());
    trangThai = widget.donHang.trangThai;
    tongTienMoi = widget.donHang.tongTien;
    giaMotLy = widget.donHang.giaDonVi;

    // Lắng nghe thay đổi số lượng để tính lại tiền
    soLuongCtrl.addListener(() {
      final soLuongInput = int.tryParse(soLuongCtrl.text);
      if (soLuongInput != null) {
        setState(() {
          tongTienMoi = soLuongInput * giaMotLy;
        });
      }
    });
  }

  Future<void> updateDonHang() async {
    try {
      final soLuongMoi = int.parse(soLuongCtrl.text);

      await FirebaseFirestore.instance
          .collection("DonHang") // Đảm bảo tên Collection khớp với Database của bạn
          .doc("GioHang")
          .collection("SanPham")
          .doc(widget.donHang.id)
          .update({
        'soLuong': soLuongMoi,
        'tongTien': tongTienMoi,
        'trangThaiThanhToan': trangThai, // Lưu ý check lại tên field trên Firebase
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật thành công!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
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
      appBar: AppBar(title: const Text("Chi tiết & Sửa đơn hàng")),
      body: SingleChildScrollView( // Thêm cuộn trang để không bị lỗi khi bàn phím hiện lên
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==============================
              // 1. ẢNH SẢN PHẨM & TÊN
              // ==============================
              Center(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.donHang.hinhAnh,
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => 
                            const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.donHang.tenSanPham,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),

              // ==============================
              // 2. CHI TIẾT ORDER (Read-only)
              // ==============================
              const Text("Thông tin Order:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(Icons.table_restaurant, "Bàn:", widget.donHang.tenBan),
                    const Divider(),
                    _buildDetailRow(Icons.delivery_dining, "Hình thức:", widget.donHang.hinhThuc),
                    const Divider(),
                    _buildDetailRow(Icons.local_cafe, "Size:", widget.donHang.size),
                    const Divider(),
                    _buildDetailRow(Icons.ac_unit, "Mức đá:", widget.donHang.mucDa),
                  ],
                ),
              ),

              const SizedBox(height: 25),
              const Divider(thickness: 2),
              const SizedBox(height: 15),

              // ==============================
              // 3. PHẦN CHỈNH SỬA (Editable)
              // ==============================
              const Text("Cập nhật:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 15),

              // Ô nhập số lượng
              TextField(
                controller: soLuongCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Số lượng",
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Giá đơn vị
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Đơn giá: $giaMotLy đ",
                  style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 10),

              // Tổng tiền (Tự động tính)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Tổng tiền mới:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    Text(
                      "$tongTienMoi đ",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Chọn trạng thái
              // DropdownButtonFormField<String>(
              //   value: trangThai,
              //   items: const [
              //     DropdownMenuItem(value: "Đang chờ", child: Text("Đang chờ")), // Nếu database có status này
              //     DropdownMenuItem(value: "Chưa thanh toán", child: Text("Chưa thanh toán")),
              //     DropdownMenuItem(value: "Đã thanh toán", child: Text("Đã thanh toán")),
              //   ],
              //   onChanged: (v) => setState(() => trangThai = v!),
              //   decoration: const InputDecoration(
              //     labelText: "Trạng thái thanh toán",
              //     prefixIcon: Icon(Icons.payment),
              //     border: OutlineInputBorder(),
              //   ),
              // ),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: "Trạng thái thanh toán",
                  prefixIcon: Icon(Icons.payment),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  trangThai,
                  style: const TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 30),

              // Nút Lưu
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: updateDonHang,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                  ),
                  child: const Text("LƯU THAY ĐỔI", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20), // Padding dưới cùng để scroll không bị che
            ],
          ),
        ),
      ),
    );
  }

  // Hàm widget con để vẽ từng dòng thông tin cho gọn code
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: Colors.grey)),
        const Spacer(),
        Text(
          value, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
        ),
      ],
    );
  }
}