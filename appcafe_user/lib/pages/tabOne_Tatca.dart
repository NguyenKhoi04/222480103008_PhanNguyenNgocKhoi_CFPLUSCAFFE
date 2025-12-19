import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TabOneTatCa extends StatefulWidget {
  const TabOneTatCa({super.key});

  @override
  State<TabOneTatCa> createState() => _TabOneTatCaState();
}

class _TabOneTatCaState extends State<TabOneTatCa> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleText("CAFE"),
              buildCategory("SanPham", "CaFe", "Cafe"),

              titleText("TRÀ SỮA"),
              buildCategory("SanPham", "Trà sữa", "trasua"),

              titleText("MATCHA"),
              buildCategory("SanPham", "Matcha", "matcha"),

              titleText("TOPPING"),
              buildCategory("SanPham", "Topping", "topping"),
            ],
          ),
        ),
      ),
    );
  }

  // Tiêu đề danh mục
  Widget titleText(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.brown,
        ),
      ),
    );
  }

  // Load danh mục sản phẩm
  Widget buildCategory(String root, String docName, String collectionName) {
    return SizedBox(
      height: 220,
      child: FutureBuilder(
        future: db
            .collection(root)
            .doc(docName)
            .collection(collectionName)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
         }

          final data = snapshot.data!.docs;

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: data.length,
            itemBuilder: (context, i) {
              final item = data[i];
              final ten = item['Ten'];
              final gia = item['Gia'];
              final hinh = item['hinhAnh'];

              return productCard(
                ten: ten,
                gia: gia,
                hinh: hinh,
              );
            },
          );
        },
      ),
    );
  }

  // Card sản phẩm
  Widget productCard({required String ten, required String gia, required String hinh}) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/chitiet_sanpham',
          arguments: {
            'ten': ten,
            'gia': gia,
            'hinhAnh': hinh,
          },
        );
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                hinh,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              ten,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text("$gia đ",
                style: const TextStyle(fontSize: 15, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
