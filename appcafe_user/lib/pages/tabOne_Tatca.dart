import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TabOneTatCa extends StatefulWidget {
  const TabOneTatCa({super.key});

  @override
  State<TabOneTatCa> createState() => _TabOneTatCaState();
}

class _TabOneTatCaState extends State<TabOneTatCa> {
  final supabase = Supabase.instance.client;

  late Future<List<Map<String, dynamic>>> futureCategories;

  @override
  void initState() {
    super.initState();
    futureCategories = loadCategories();
  }

  Future<List<Map<String, dynamic>>> loadCategories() async {
    final data = await supabase
        .from('categories')
        .select()
        .order('id', ascending: true);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> loadProductsByCategory(
      int categoryId) async {
    final data = await supabase
        .from('products')
        .select()
        .eq('category_id', categoryId)
        .order('id', ascending: true);

    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: futureCategories,
        builder: (context, catSnapshot) {
          if (!catSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final categories = catSnapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: categories.map((cat) {
                final int categoryId = cat['id'];
                final String categoryName =
                    cat['name'] ?? '';

                return Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    titleText(categoryName),

                    buildCategory(categoryId),

                    const SizedBox(height: 10),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget titleText(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.brown,
        ),
      ),
    );
  }

  Widget buildCategory(int categoryId) {
    return SizedBox(
      height: 220,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: loadProductsByCategory(categoryId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final data = snapshot.data!;

          if (data.isEmpty) {
            return const Center(
              child: Text("Chưa có sản phẩm"),
            );
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: data.length,
            itemBuilder: (context, i) {
              final item = data[i];

              final int id = item['id'];
              final String ten =
                  item['name'] ?? '';
              final String hinh =
                  item['image_url'] ?? '';

              final double gia =
                  (item['final_price'] ??
                          item['base_price'] ??
                          0)
                      .toDouble();

              return productCard(
                id: id,
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

  Widget productCard({
    required int id,
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
            'id': id,
            'ten': ten,
            'gia': gia,
            'hinhAnh': hinh,
          },
        );
      },
      child: Container(
        width: 150,
        margin:
            const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(12),
              child: Image.network(
                hinh,
                width: 150,
                height: 130,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) =>
                        Container(
                  width: 150,
                  height: 130,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.image,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              ten,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            Text(
              "${gia.toStringAsFixed(0)} đ",
              style: const TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class TabOneTatCa extends StatefulWidget {
//   const TabOneTatCa({super.key});

//   @override
//   State<TabOneTatCa> createState() => _TabOneTatCaState();
// }

// class _TabOneTatCaState extends State<TabOneTatCa> {
//   final FirebaseFirestore db = FirebaseFirestore.instance;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(8),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               titleText("CAFE"),
//               buildCategory("SanPham", "CaFe", "Cafe"),

//               titleText("TRÀ SỮA"),
//               buildCategory("SanPham", "Trà sữa", "trasua"),

//               titleText("MATCHA"),
//               buildCategory("SanPham", "Matcha", "matcha"),

//               titleText("TOPPING"),
//               buildCategory("SanPham", "Topping", "topping"),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Tiêu đề danh mục
//   Widget titleText(String text) {
//     return Padding(
//       padding: const EdgeInsets.all(8),
//       child: Text(
//         text,
//         style: const TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//           color: Colors.brown,
//         ),
//       ),
//     );
//   }

//   // Load danh mục sản phẩm
//   Widget buildCategory(String root, String docName, String collectionName) {
//   return SizedBox(
//     height: 220,
//     child: FutureBuilder<QuerySnapshot>(
//       future: db
//           .collection(root)
//           .doc(docName)
//           .collection(collectionName)
//           .get(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final data = snapshot.data!.docs;

//         return ListView.builder(
//           scrollDirection: Axis.horizontal,
//           itemCount: data.length,
//           itemBuilder: (context, i) {
//             final item = data[i];

//             final String ten = item['Ten'] as String;
//             final String hinh = item['hinhAnh'] as String;

//             final rawGia = item['Gia'];
//             final double gia = rawGia is num
//                 ? rawGia.toDouble()
//                 : double.tryParse(
//                         rawGia.toString().replaceAll(RegExp(r'[^0-9]'), '')) ??
//                     0;

//             return productCard(
//               ten: ten,
//               gia: gia,
//               hinh: hinh,
//             );
//           },
//         );
//       },
//     ),
//   );
// }



//   // Card sản phẩm
//   Widget productCard({required String ten, required double gia, required String hinh}) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.pushNamed(
//           context,
//           '/chitiet_sanpham',
//           arguments: {
//             'ten': ten,
//             'gia': gia,
//             'hinhAnh': hinh,
//           },
//         );
//       },
//       child: Container(
//         width: 150,
//         margin: const EdgeInsets.only(right: 12),
//         child: Column(
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Image.network(
//                 hinh,
//                 width: 150,
//                 height: 130,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               ten,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             Text("$gia đ",
//                 style: const TextStyle(fontSize: 15, color: Colors.grey)),
//           ],
//         ),
//       ),
//     );
//   }
// }
