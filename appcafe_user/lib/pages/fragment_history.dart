import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'DonHang.dart';
import 'sua_donhang.dart';

class FragmentHistory extends StatefulWidget {
  final VoidCallback onThemHang;

  const FragmentHistory({super.key, required this.onThemHang});

  @override
  State<FragmentHistory> createState() => _FragmentHistoryState();
}

class _FragmentHistoryState extends State<FragmentHistory> {
  List<DonHang> listDonHang = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDonHang();
  }

  Future<void> loadDonHang() async {
    setState(() => isLoading = true);

    final snapshot = await FirebaseFirestore.instance
        .collection("DonHang")
        .doc("GioHang")
        .collection("SanPham")
        .get();

    listDonHang = snapshot.docs
        .map((doc) => DonHang.fromFirestore(doc.id, doc.data()))
        .toList();

    setState(() => isLoading = false);
  }

  Future<void> deleteDonHang(String id) async {
    await FirebaseFirestore.instance
        .collection("DonHang")
        .doc("GioHang")
        .collection("SanPham")
        .doc(id)
        .delete();

    loadDonHang();
  }

  Color getTrangThaiColor(String s) =>
      s.contains("Đã") ? Colors.green : Colors.red;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: listDonHang.length,
              itemBuilder: (context, index) {
                final donHang = listDonHang[index];

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: Image.network(
                      donHang.hinhAnh,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      donHang.tenSanPham,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Bàn: ${donHang.tenBan}"),
                        Text("Size: ${donHang.size} | Đá: ${donHang.mucDa}"),
                        Text("SL: ${donHang.soLuong}"),
                        Text("Tổng: ${donHang.tongTien} đ"),
                        const SizedBox(height: 4),
                        Chip(
                          label: Text(
                            donHang.trangThai,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: getTrangThaiColor(donHang.trangThai),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SuaDonHang(donHang: donHang),
                            ),
                          );
                          // Reload nếu cập nhật thành công
                          if (result == true) {
                            loadDonHang();
                          }
                        }
                        if (value == 'delete') {
                          deleteDonHang(donHang.id);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text("Sửa")),
                        PopupMenuItem(value: 'delete', child: Text("Xóa")),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
