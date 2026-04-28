import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'model_sanpham.dart';
import 'sanpham_item.dart';

class SearchResultPage extends StatefulWidget {
  const SearchResultPage({super.key});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  final supabase = Supabase.instance.client;
  final TextEditingController searchController = TextEditingController();

  List<SanPham> sanPhamList = [];
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kết quả tìm kiếm"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: searchController,
              onChanged: timKiemSanPham,
              decoration: const InputDecoration(
                hintText: "Nhập tên sản phẩm...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : sanPhamList.isEmpty
                    ? const Center(
                        child: Text("Không có sản phẩm"),
                      )
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

  Future<void> timKiemSanPham(String keyword) async {
    keyword = keyword.trim();

    if (keyword.isEmpty) {
      setState(() {
        sanPhamList.clear();
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final data = await supabase
          .from('products')
          .select('id,name,base_price,image_url')
          .ilike('name', '%$keyword%')
          .order('name');

      sanPhamList = data.map<SanPham>((item) {
        return SanPham(
          ten: item['name'] ?? '',
          gia: (item['base_price'] ?? 0).toDouble(),
          hinh: item['image_url'] ?? '',
        );
      }).toList();
    } catch (e) {
      debugPrint("Search error: $e");
      sanPhamList.clear();
    }

    setState(() {
      isLoading = false;
    });
  }
}


// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'model_sanpham.dart';
// import 'sanpham_item.dart';

// class SearchResultPage extends StatefulWidget {
//   const SearchResultPage({super.key});

//   @override
//   State<SearchResultPage> createState() => _SearchResultPageState();
// }

// class _SearchResultPageState extends State<SearchResultPage> {
//   final FirebaseFirestore db = FirebaseFirestore.instance;
//   final TextEditingController searchController = TextEditingController();

//   List<SanPham> sanPhamList = [];
//   bool isLoading = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Kết quả tìm kiếm'),
//       ),
//       body: Column(
//         children: [
//           // ===== TextField tìm kiếm =====
//           Padding(
//             padding: const EdgeInsets.all(8),
//             child: TextField(
//               controller: searchController,
//               onChanged: timKiemSanPham,
//               decoration: const InputDecoration(
//                 hintText: 'Nhập tên sản phẩm...',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ),

//           // ===== ListView =====
//           Expanded(
//             child: isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : ListView.builder(
//                     padding: const EdgeInsets.all(8),
//                     itemCount: sanPhamList.length,
//                     itemBuilder: (context, index) {
//                       return SanPhamItem(
//                         sanPham: sanPhamList[index],
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ===============================
//   // TÌM KIẾM FIRESTORE (AN TOÀN)
//   // ===============================
//   Future<void> timKiemSanPham(String keyword) async {
//     keyword = keyword.trim();

//     if (keyword.isEmpty) {
//       setState(() => sanPhamList.clear());
//       return;
//     }

//     setState(() => isLoading = true);

//     try {
//       sanPhamList.clear();

//       // Lấy các document gốc trong SanPham (CaFe, Matcha, ...)
//       final rootCats = await db.collection('SanPham').get();

//       for (var catDoc in rootCats.docs) {
//         final catId = catDoc.id;

//         final qs = await db
//             .collection('SanPham')
//             .doc(catId)
//             .collection(catId)
//             .get();

//         for (var doc in qs.docs) {
//           final data = doc.data();

//           // -------- TÊN --------
//           if (!data.containsKey('Ten')) continue;

//           final String ten = data['Ten'].toString();

//           if (!ten.toLowerCase().contains(keyword.toLowerCase())) continue;

//           // -------- GIÁ (AN TOÀN) --------
//           final rawGia = data['Gia'];
//           final double gia = rawGia is num
//               ? rawGia.toDouble()
//               : double.tryParse(
//                       rawGia.toString().replaceAll(RegExp(r'[^0-9]'), '')) ??
//                   0;

//           // -------- HÌNH --------
//           final String hinh =
//               data.containsKey('hinhAnh') ? data['hinhAnh'] : '';

//           sanPhamList.add(
//             SanPham(
//               ten: ten,
//               gia: gia,
//               hinh: hinh,
//             ),
//           );
//         }
//       }

//       debugPrint('Found ${sanPhamList.length} items');
//     } catch (e) {
//       debugPrint('Search error: $e');
//     }

//     setState(() => isLoading = false);
//   }
// }
