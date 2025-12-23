import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TabTwoBestSeller extends StatefulWidget {
  const TabTwoBestSeller({super.key});

  @override
  State<TabTwoBestSeller> createState() => _TabTwoBestSellerState();
}

class _TabTwoBestSellerState extends State<TabTwoBestSeller> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                "BEST SELLER",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
            ),
            buildBestSellerList(),
          ],
        ),
      ),
    );
  }

  Widget buildBestSellerList() {
    return FutureBuilder<QuerySnapshot>(
      future: db
          .collection("SanPham")
          .doc("BestSeller")
          .collection("BestSeller")
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text("Chưa có sản phẩm Best Seller"));
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;

            final String ten =
                data.containsKey('Ten') ? data['Ten'].toString() : 'Không tên';

            final rawGia = data['Gia'];
            final double gia = rawGia is num
                ? rawGia.toDouble()
                : double.tryParse(
                        rawGia.toString().replaceAll(RegExp(r'[^0-9]'), '')) ??
                    0;

            final String hinh =
                data.containsKey('hinhAnh') ? data['hinhAnh'] : '';

            return productCard(ten: ten, gia: gia, hinh: hinh);
          },
        );
      },
    );
  }

  Widget productCard({
    required String ten,
    required double gia,
    required String hinh,
  }) {
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
      child: Card(
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
                child: Image.network(
                  hinh,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ten,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${gia.toStringAsFixed(0)} đ",
                    style: const TextStyle(
                        fontSize: 13,
                        color: Colors.brown,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
