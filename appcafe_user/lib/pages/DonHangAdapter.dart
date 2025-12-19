import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'DonHang.dart';

class DonHangWidget extends StatefulWidget {
  final List<DonHang> list;

  const DonHangWidget({super.key, required this.list});

  @override
  State<DonHangWidget> createState() => _DonHangWidgetState();
}

class _DonHangWidgetState extends State<DonHangWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.list.length,
      itemBuilder: (context, index) {
        final donHang = widget.list[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hình ảnh
                SizedBox(
                  height: 120,
                  child: Image.network(donHang.hinhAnh, fit: BoxFit.cover),
                ),

                const SizedBox(height: 10),

                Text("Tên bàn: ${donHang.tenBan}"),
                Text("Tên sản phẩm: ${donHang.tenSanPham}"),
                Text("Size: ${donHang.size}"),
                Text("Mức đá: ${donHang.mucDa}"),
                Text("Số lượng: ${donHang.soLuong}"),
                Text("Tổng tiền: ${donHang.tongTien}đ"),
                Text("Hình thức: ${donHang.hinhThuc}"),
                Text(
                  "Trạng thái: ${donHang.trangThai}",
                  style: TextStyle(
                    color: donHang.trangThai == "Đã thanh toán"
                        ? Colors.green
                        : Colors.red,
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Nút sửa
                    TextButton(
                      onPressed: () => _showEditDialog(donHang, index),
                      child: const Text("Sửa"),
                    ),

                    // Nút xóa
                    TextButton(
                      onPressed: () => _deleteDonHang(donHang, index),
                      child: const Text("Xóa", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // =============================
  //     HỘP THOẠI SỬA TRẠNG THÁI
  // =============================
  void _showEditDialog(DonHang donHang, int index) {
    bool checked = donHang.trangThai == "Đã thanh toán";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            title: const Text("Cập nhật trạng thái"),
            content: Row(
              children: [
                Checkbox(
                  value: checked,
                  onChanged: (v) {
                    setDialogState(() => checked = v!);
                  },
                ),
                const Text("Đã thanh toán"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Hủy"),
              ),
              TextButton(
                onPressed: () async {
                final newStatus =
                    checked ? "Đã thanh toán" : "Chưa thanh toán";

                // 🔥 Update Firestore
                final fs = FirebaseFirestore.instance;

                final query = await fs
                    .collection("Đơn hàng")
                    .doc("Giỏ hàng")
                    .collection("Sản phẩm")
                    .where("Tên sản phẩm", isEqualTo: donHang.tenSanPham)
                    .where("Tên bàn", isEqualTo: donHang.tenBan)
                    .get();

                for (var doc in query.docs) {
                  doc.reference.update({"trangthaithanhtoan": newStatus});
                }

                // 🔄 Update UI
                setState(() {
                  widget.list[index].trangThai = newStatus;
                });

                  Navigator.pop(context);
                },
                child: const Text("Lưu"),
              ),
            ],
          ),
        );
      },
    );
  }

  // =============================
  //     XÓA ĐƠN HÀNG
  // =============================
  void _deleteDonHang(DonHang donHang, int index) async {
    final fs = FirebaseFirestore.instance;

    final query = await fs
        .collection("Đơn hàng")
        .doc("Giỏ hàng")
        .collection("Sản phẩm")
        .where("Tên sản phẩm", isEqualTo: donHang.tenSanPham)
        .where("Tên bàn", isEqualTo: donHang.tenBan)
        .get();

    for (var doc in query.docs) {
      await doc.reference.delete();
    }

    setState(() {
      widget.list.removeAt(index);
    });
  }
}
