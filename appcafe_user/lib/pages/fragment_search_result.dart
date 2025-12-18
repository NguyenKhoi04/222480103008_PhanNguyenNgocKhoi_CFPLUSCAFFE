import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'model_sanpham.dart';
import 'sanpham_item.dart';

class SearchResultPage extends StatefulWidget {
  const SearchResultPage({super.key});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final TextEditingController searchController = TextEditingController();

  List<SanPham> sanPhamList = [];
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả tìm kiếm'),
      ),
      body: Column(
        children: [
          // ===== TextField tìm kiếm =====
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                timKiemSanPham(value);
              },
              decoration: const InputDecoration(
                hintText: 'Nhập tên sản phẩm...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // ===== ListView =====
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: sanPhamList.length,
                    itemBuilder: (context, index) {
                      return SanPhamItem(
                        sanPham: sanPhamList[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// ===============================
  /// TÌM KIẾM GIỐNG HỆT JAVA
  /// ===============================
  Future<void> timKiemSanPham(String keyword) async {
    if (keyword.trim().isEmpty) {
      setState(() => sanPhamList.clear());
      return;
    }

    setState(() => isLoading = true);

    try {
      sanPhamList.clear();

      // Lấy root collection "SanPham"
      final rootCats = await db.collection('SanPham').get();

      List<Future<QuerySnapshot>> tasks = [];

      for (var catDoc in rootCats.docs) {
        final catId = catDoc.id; // CaFe, Matcha...
        tasks.add(
          db
              .collection('SanPham')
              .doc(catId)
              .collection(catId)
              .get(),
        );
      }

      // Chờ tất cả sub-collection load xong
      final results = await Future.wait(tasks);

      for (var qs in results) {
        for (var doc in qs.docs) {
          final ten = doc['Ten'];

          if (ten != null &&
              ten
                  .toString()
                  .toLowerCase()
                  .contains(keyword.toLowerCase())) {
            sanPhamList.add(
              SanPham(
                ten: ten,
                gia: doc['Gia'] ?? '',
                hinh: doc['hinhAnh'] ?? '',
              ),
            );
          }
        }
      }

      debugPrint('Found ${sanPhamList.length} items');
    } catch (e) {
      debugPrint('Search error: $e');
    }

    setState(() => isLoading = false);
  }
}
