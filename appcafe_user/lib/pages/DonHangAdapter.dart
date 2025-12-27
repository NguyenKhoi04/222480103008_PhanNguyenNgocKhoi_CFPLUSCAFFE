import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'DonHang.dart';
import 'sua_donhang.dart'; // Import màn hình sửa chi tiết

class DonHangWidget extends StatefulWidget {
  final List<DonHang> list;
  final VoidCallback? onRefresh; // Hàm callback để reload dữ liệu từ cha

  const DonHangWidget({super.key, required this.list, this.onRefresh});

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
                  width: double.infinity,
                  child: Image.network(
                    donHang.hinhAnh,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.broken_image,
                            size: 50, color: Colors.grey)),
                  ),
                ),

                const SizedBox(height: 10),

                Text("Tên bàn: ${donHang.tenBan}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Tên sản phẩm: ${donHang.tenSanPham}"),
                Text("Size: ${donHang.size} | Đá: ${donHang.mucDa}"),
                Text("Số lượng: ${donHang.soLuong}"),
                Text("Tổng tiền: ${donHang.tongTien} đ",
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
                Text("Hình thức: ${donHang.hinhThuc}"),

                // Trạng thái có màu sắc
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: donHang.trangThai == "Đã thanh toán"
                          ? Colors.green[50]
                          : Colors.red[50],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: donHang.trangThai == "Đã thanh toán"
                            ? Colors.green
                            : Colors.red,
                      )),
                  child: Text(
                    "Trạng thái: ${donHang.trangThai}",
                    style: TextStyle(
                        color: donHang.trangThai == "Đã thanh toán"
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Nút SỬA -> Chuyển sang màn hình SuaDonHang
                    TextButton.icon(
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text("Sửa"),
                      onPressed: () async {
                        // Chuyển sang màn hình Sửa
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SuaDonHang(donHang: donHang),
                          ),
                        );

                        // Nếu bên kia trả về true (đã sửa), thì reload lại list
                        if (result == true && widget.onRefresh != null) {
                          widget.onRefresh!();
                        }
                      },
                    ),

                    // Nút XÓA
                    TextButton.icon(
                      icon:
                          const Icon(Icons.delete, size: 18, color: Colors.red),
                      label: const Text("Xóa",
                          style: TextStyle(color: Colors.red)),
                      onPressed: () => _confirmDelete(donHang, index),
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
  //     HỘP THOẠI XÁC NHẬN XÓA
  // =============================
  void _confirmDelete(DonHang donHang, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận"),
        content: Text("Bạn có chắc muốn xóa '${donHang.tenSanPham}' không?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Đóng dialog
              _deleteDonHang(donHang, index); // Thực hiện xóa
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }

  // =============================
  //     LOGIC XÓA (FIX LỖI ID)
  // =============================
  void _deleteDonHang(DonHang donHang, int index) async {
    final fs = FirebaseFirestore.instance;

    try {
      // 🔥 SỬA QUAN TRỌNG: Dùng doc(id).delete() thay vì .where()
      // Đảm bảo tên Collection đúng: Đơn hàng -> Giỏ hàng -> Sản phẩm
      await fs
          .collection("Đơn hàng")
          .doc("Giỏ hàng")
          .collection("Sản phẩm")
          .doc(donHang.id) // Xóa đúng ID document
          .delete();

      // Cập nhật giao diện ngay lập tức (Xóa khỏi list local)
      setState(() {
        widget.list.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã xóa đơn hàng")),
      );
    } catch (e) {
      print("Lỗi khi xóa: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi xóa: $e")),
      );
    }
  }
}
