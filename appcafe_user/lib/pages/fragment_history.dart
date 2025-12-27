import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'DonHang.dart';
import 'sua_donhang.dart'; // Nhớ import file này

class FragmentHistory extends StatefulWidget {
  final VoidCallback onThemHang;
  const FragmentHistory({super.key, required this.onThemHang});

  @override
  State<FragmentHistory> createState() => _FragmentHistoryState();
}

class _FragmentHistoryState extends State<FragmentHistory> {
  late Stream<QuerySnapshot> donHangStream;

  @override
  void initState() {
    super.initState();
    donHangStream = FirebaseFirestore.instance
        .collection("DonHang")
        .doc("GioHang")
        .collection("SanPham")
        .orderBy("thoiGian", descending: true)
        .snapshots();
  }

  Future<void> deleteDonHang(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection("DonHang")
          .doc("GioHang")
          .collection("SanPham")
          .doc(id)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Xóa đơn hàng thành công!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi xóa: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Giỏ hàng của bạn",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: donHangStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text("Lỗi: ${snapshot.error}"),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    "Giỏ hàng trống",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              final donHangList = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: donHangList.length,
                itemBuilder: (context, index) {
                  final doc = donHangList[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final donHang = DonHang.fromFirestore(doc.id, data);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(donHang.hinhAnh),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: donHang.hinhAnh.isEmpty
                            ? const Icon(Icons.image, color: Colors.grey)
                            : null,
                      ),
                      title: Text(
                        donHang.tenSanPham,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            "${donHang.soLuong} ly - ${donHang.tongTien} đ",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.brown,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            donHang.trangThai,
                            style: TextStyle(
                              fontSize: 12,
                              color: donHang.trangThai == "Đang chờ"
                                  ? Colors.orange
                                  : donHang.trangThai == "Hoàn thành"
                                      ? Colors.green
                                      : Colors.grey,
                            ),
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
                            if (result == true && mounted) {
                              // Stream sẽ tự động update
                            }
                          } else if (value == 'delete') {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Xác nhận xóa"),
                                content: const Text(
                                  "Bạn chắc chắn muốn xóa đơn hàng này?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Hủy"),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    onPressed: () {
                                      deleteDonHang(doc.id);
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      "Xóa",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.blue),
                                SizedBox(width: 8),
                                Text("Sửa"),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  "Xóa",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
