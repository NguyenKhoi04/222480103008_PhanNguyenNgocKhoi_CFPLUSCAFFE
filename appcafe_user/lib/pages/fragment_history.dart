import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FragmentHistory extends StatefulWidget {
  final VoidCallback onThemHang;

  const FragmentHistory({super.key, required this.onThemHang});

  @override
  State<FragmentHistory> createState() => _FragmentHistoryState();
}

class _FragmentHistoryState extends State<FragmentHistory> {
  List<Map<String, dynamic>> listDonHang = [];

  @override
  void initState() {
    super.initState();
    loadDonHang();
  }

  // ====== Lấy dữ liệu Firestore giống Java ======
  void loadDonHang() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("Đơn hàng")
        .doc("Giỏ hàng")
        .collection("Sản phẩm")
        .get();

    listDonHang.clear();

    for (var doc in snapshot.docs) {
      listDonHang.add({
        "tenBan": doc["Tên bàn"],
        "tenSanPham": doc["Tên sản phẩm"],
        "size": doc.data().containsKey("Size") ? doc["Size"] : "Không xác định",
        "da": doc["Mức đá"],
        "soLuong": doc["Số lượng"],
        "tongTien": doc["Tổng tiền"],
        "hinhThuc": doc["hình thức"],
        "trangThai": doc["trangthaithanhtoan"],
        "hinhAnh": doc["hinhAnh"],
      });
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ===== Text Header =====
        Container(
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          color: Colors.brown.shade100,
          child: const Text(
            "LỊCH SỬ ĐƠN HÀNG ĐÃ ĐẶT",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              color: Colors.brown,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // ===== Button Thêm Hàng =====
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 12, top: 8),
            child: ElevatedButton.icon(
              onPressed: widget.onThemHang,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text("Thêm hàng"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),

        // ===== LIST VIEW =====
        Expanded(
          child: ListView.builder(
            itemCount: listDonHang.length,
            itemBuilder: (context, index) {
              final item = listDonHang[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                elevation: 2,
                child: ListTile(
                  leading: Image.network(
                    item["hinhAnh"],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                  title: Text(item["tenSanPham"]),
                  subtitle: Text(
                      "Bàn: ${item["tenBan"]}\n"
                      "Size: ${item["size"]} | Đá: ${item["da"]}\n"
                      "Số lượng: ${item["soLuong"]} | Tổng: ${item["tongTien"]} đ\n"
                      "Hình thức: ${item["hinhThuc"]}\n"
                      "Trạng thái: ${item["trangThai"]}"
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
