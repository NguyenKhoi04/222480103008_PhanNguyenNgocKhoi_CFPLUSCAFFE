import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:appcafe_user/pages/tabOne_Tatca.dart';
import 'package:appcafe_user/pages/tabTwo_BestSeller.dart';
import 'package:appcafe_user/pages/tabThree_Monngon.dart';
import 'chitiet_tintuc.dart';

class FragmentHome extends StatefulWidget {
  final VoidCallback onThemHang;

  const FragmentHome({super.key, required this.onThemHang});

  @override
  State<FragmentHome> createState() => _FragmentHomeState();
}

class _FragmentHomeState extends State<FragmentHome>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  late TabController tabController;
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> searchList = [];

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 3, vsync: this);

    searchController.addListener(() {
      final keyword = searchController.text.trim();

      if (keyword.isEmpty) {
        setState(() => searchList.clear());
      } else {
        doSearch(keyword);
      }
    });
  }

  bool isValidKeyword(String keyword) {
    final regex = RegExp(r'^[\p{L}\p{N} ]{1,50}$', unicode: true);
    return regex.hasMatch(keyword);
  }

  String removeAccent(String str) {
    const withDia =
        "àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩ"
        "òóọỏõôồốộổỗơờớợởỡ"
        "ùúụủũưừứựửữỳýỵỷỹđ";

    const withoutDia =
        "aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd";

    str = str.toLowerCase();

    for (int i = 0; i < withDia.length; i++) {
      str = str.replaceAll(withDia[i], withoutDia[i]);
    }

    return str;
  }

  Future<void> doSearch(String keyword) async {
    if (!isValidKeyword(keyword)) {
      setState(() => searchList.clear());
      return;
    }

    final data = await supabase
        .from('products')
        .select('id,name,base_price,image_url');

    final results = data.where((item) {
      final ten = item['name'].toString();
      return removeAccent(ten).contains(removeAccent(keyword));
    }).toList();

    setState(() {
      searchList = List<Map<String, dynamic>>.from(results);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSearching =
        searchController.text.trim().isNotEmpty &&
            searchList.isNotEmpty;

    return Column(
      children: [
        Container(
          margin:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
              )
            ],
          ),
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: "Tìm kiếm sản phẩm...",
              border: InputBorder.none,
              icon: Icon(Icons.search),
            ),
          ),
        ),

        if (!isSearching)
          TabBar(
            controller: tabController,
            labelColor: Colors.brown,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: "Tất cả"),
              Tab(text: "Best Seller"),
              Tab(text: "Món ngon"),
            ],
          ),

        Expanded(
          child: isSearching
              ? buildSearchList()
              : TabBarView(
                  controller: tabController,
                  children: const [
                    TabOneTatCa(),
                    TabTwoBestSeller(),
                    TabThreeMonngon(),
                  ],
                ),
        ),

        if (!isSearching) buildNewsSection(),
      ],
    );
  }

  Widget buildNewsSection() {
    return Container(
      height: 160,
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Text(
              "Tin Tức - Sự Kiện",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.brown,
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase
                  .from('news')
                  .stream(primaryKey: ['id'])
                  .order('id', ascending: false),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data = snapshot.data!;

                if (data.isEmpty) {
                  return const Center(
                    child: Text("Chưa có tin tức mới"),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final tin = data[index];

                    final title =
                        tin['title'] ?? 'Không có tựa đề';
                    final image =
                        tin['image_url'] ?? '';
                    final content =
                        tin['content'] ?? '';
                    final summary =
                        tin['summary'] ?? content;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChitietTinTuc(
                              hinhAnh: image,
                              tuaDe: title,
                              tomTat: summary,
                              noiDung: content,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 200,
                        margin:
                            const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey
                                  .withOpacity(0.3),
                              blurRadius: 3,
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius:
                                  const BorderRadius.vertical(
                                top: Radius.circular(10),
                              ),
                              child: image.isNotEmpty
                                  ? Image.network(
                                      image,
                                      height: 70,
                                      width:
                                          double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      height: 70,
                                      color:
                                          Colors.grey[300],
                                      child: const Icon(
                                        Icons.newspaper,
                                      ),
                                    ),
                            ),

                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(8),
                                child: Text(
                                  title,
                                  maxLines: 2,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style:
                                      const TextStyle(
                                    fontSize: 12,
                                    fontWeight:
                                        FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
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
      ),
    );
  }

  Widget buildSearchList() {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: searchList.length,
      itemBuilder: (context, index) {
        final sp = searchList[index];

        final ten = sp['name'] ?? '';
        final hinh = sp['image_url'] ?? '';
        final gia =
            (sp['base_price'] ?? 0).toDouble();

        return InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              "/chitiet_sanpham",
              arguments: {
                "id": sp['id'],
                "ten": ten,
                "gia": gia,
                "hinhAnh": hinh,
              },
            );
          },
          child: Card(
            margin:
                const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Image.network(
                hinh,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) =>
                        const Icon(Icons.error),
              ),
              title: Text(ten),
              subtitle: Text(
                "Giá: ${gia.toStringAsFixed(0)} đ",
              ),
            ),
          ),
        );
      },
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:appcafe_user/pages/tabOne_Tatca.dart';
// import 'package:appcafe_user/pages/tabTwo_BestSeller.dart';
// import 'package:appcafe_user/pages/tabThree_Monngon.dart';
// import 'chitiet_tintuc.dart';

// class FragmentHome extends StatefulWidget {
//   final VoidCallback onThemHang;
//   const FragmentHome({super.key, required this.onThemHang});

//   @override
//   State<FragmentHome> createState() => _FragmentHomeState();
// }

// class _FragmentHomeState extends State<FragmentHome>
//     with SingleTickerProviderStateMixin {
//   late TabController tabController;
//   final TextEditingController searchController = TextEditingController();

//   List<Map<String, dynamic>> searchList = [];

//   @override
//   void initState() {
//     super.initState();
//     tabController = TabController(length: 3, vsync: this);

//     searchController.addListener(() {
//       final keyword = searchController.text.trim();
//       if (keyword.isEmpty) {
//         setState(() => searchList.clear());
//       } else {
//         doSearch(keyword);
//       }
//     });
//   }

//   // ... (Giữ nguyên các hàm isValidKeyword, removeAccent, doSearch như cũ) ...
//   bool isValidKeyword(String keyword) {
//     final regex = RegExp(r'^[\p{L}\p{N} ]{1,50}$', unicode: true);
//     return regex.hasMatch(keyword);
//   }

//   String removeAccent(String str) {
//     const withDia = "àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩ"
//         "òóọỏõôồốộổỗơờớợởỡ"
//         "ùúụủũưừứựửữỳýỵỷỹđ";
//     const withoutDia =
//         "aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd";
//     str = str.toLowerCase();
//     for (int i = 0; i < withDia.length; i++) {
//       str = str.replaceAll(withDia[i], withoutDia[i]);
//     }
//     return str;
//   }

//   Future<void> doSearch(String keyword) async {
//     if (!isValidKeyword(keyword)) {
//       setState(() => searchList.clear());
//       return;
//     }
//     final snapshot =
//         await FirebaseFirestore.instance.collection("Tìm kiếm").get();
//     final results = snapshot.docs
//         .where((doc) {
//           final data = doc.data();
//           if (!data.containsKey("Ten")) return false;
//           final ten = data["Ten"].toString();
//           return removeAccent(ten).contains(removeAccent(keyword));
//         })
//         .map((doc) => doc.data())
//         .toList();
//     setState(() {
//       searchList = List<Map<String, dynamic>>.from(results);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool isSearching =
//         searchController.text.trim().isNotEmpty && searchList.isNotEmpty;

//     return Column(
//       children: [
//         // ---------------- SEARCH ----------------
//         Container(
//           margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//           padding: const EdgeInsets.symmetric(horizontal: 10),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(15),
//             boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
//           ),
//           child: TextField(
//             controller: searchController,
//             decoration: const InputDecoration(
//               hintText: "Tìm kiếm sản phẩm...",
//               border: InputBorder.none,
//               icon: Icon(Icons.search),
//             ),
//           ),
//         ),

//         // ---------------- TAB ----------------
//         if (!isSearching)
//           TabBar(
//             controller: tabController,
//             labelColor: Colors.brown,
//             unselectedLabelColor: Colors.grey,
//             tabs: const [
//               Tab(text: "Tất cả"),
//               Tab(text: "Best Seller"),
//               Tab(text: "Món ngon"),
//             ],
//           ),

//         // ---------------- BODY (TabView hoặc Search) ----------------
//         Expanded(
//           child: isSearching
//               ? buildSearchList()
//               : TabBarView(
//                   controller: tabController,
//                   children: const [
//                     TabOneTatCa(),
//                     TabTwoBestSeller(),
//                     TabThreeMonngon(),
//                   ],
//                 ),
//         ),

//         // ---------------- TIN TỨC - SỰ KIỆN (MỚI THÊM) ----------------
//         // Chỉ hiện khi không tìm kiếm để đỡ rối mắt
//         if (!isSearching) buildNewsSection(),
//       ],
//     );
//   }

//   // ----------------- WIDGET TIN TỨC -----------------
//   // ----------------- WIDGET TIN TỨC -----------------
//   Widget buildNewsSection() {
//     return Container(
//       height: 160, // Tăng chiều cao lên 1 chút để không bị overflow
//       color: Colors.grey[100],
//       padding: const EdgeInsets.symmetric(vertical: 5),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//             child: Text(
//               "Tin Tức - Sự Kiện",
//               style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                   color: Colors.brown),
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream:
//                   FirebaseFirestore.instance.collection('TinTuc').snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasError) return const Text("Lỗi tải tin");
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 final data = snapshot.data!.docs;

//                 if (data.isEmpty) {
//                   return const Center(child: Text("Chưa có tin tức mới"));
//                 }

//                 return ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   itemCount: data.length,
//                   itemBuilder: (context, index) {
//                     var tin = data[index].data() as Map<String, dynamic>;

//                     // Lấy dữ liệu an toàn từ Firestore
//                     String title = tin['TuaDe'] ?? 'Không có tựa đề';
//                     String image = tin['hinhAnh'] ?? '';
//                     String content = tin['NoiDung'] ?? '';
//                     // Nếu không có tóm tắt thì lấy tạm nội dung làm tóm tắt
//                     String summary = tin['TomTat'] ?? content; 

//                     return GestureDetector(
//                       onTap: () {
//                         // SỬA LẠI: Dùng Navigator.push để truyền tham số trực tiếp
//                         // vào Constructor của ChitietTinTuc
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ChitietTinTuc(
//                               hinhAnh: image,
//                               tuaDe: title,
//                               tomTat: summary,
//                               noiDung: content,
//                             ),
//                           ),
//                         );
//                       },
//                       child: Container(
//                         width: 200,
//                         margin: const EdgeInsets.only(right: 10),
//                         decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(10),
//                             boxShadow: [
//                               BoxShadow(
//                                   color: Colors.grey.withOpacity(0.3),
//                                   blurRadius: 3)
//                             ]),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // 1. Hình ảnh
//                             ClipRRect(
//                               borderRadius: const BorderRadius.vertical(
//                                   top: Radius.circular(10)),
//                               child: image.isNotEmpty
//                                   ? Image.network(image,
//                                       height: 70,
//                                       width: double.infinity,
//                                       fit: BoxFit.cover)
//                                   : Container(
//                                       height: 70,
//                                       color: Colors.grey[300],
//                                       child: const Icon(Icons.newspaper)),
//                             ),

//                             // 2. Tiêu đề (Dùng Expanded để tránh lỗi Overflow)
//                             Expanded(
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 8.0, vertical: 4.0),
//                                 child: Align(
//                                   alignment: Alignment.topLeft,
//                                   child: Text(
//                                     title,
//                                     maxLines: 2,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: const TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.w500),
//                                   ),
//                                 ),
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ----------------- LIST KẾT QUẢ TÌM KIẾM (Giữ nguyên) -----------------
//   Widget buildSearchList() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(10),
//       itemCount: searchList.length,
//       itemBuilder: (context, index) {
//         final sp = searchList[index];
//         final String ten = sp.containsKey("Ten") ? sp["Ten"].toString() : "";
//         final String hinh = sp["hinhAnh"] ?? "";
//         final rawGia = sp["Gia"];
//         final double gia = rawGia is num
//             ? rawGia.toDouble()
//             : double.tryParse(rawGia.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

//         return InkWell(
//           onTap: () {
//             Navigator.pushNamed(
//               context,
//               "/chitiet_sanpham",
//               arguments: {
//                 "ten": ten,
//                 "gia": gia,
//                 "hinhAnh": hinh,
//               },
//             );
//           },
//           child: Card(
//             margin: const EdgeInsets.only(bottom: 12),
//             child: ListTile(
//               leading: Image.network(
//                 hinh, width: 60, height: 60, fit: BoxFit.cover,
//                 errorBuilder: (ctx, err, stack) => const Icon(Icons.error),
//               ),
//               title: Text(ten),
//               subtitle: Text("Giá: ${gia.toStringAsFixed(0)} đ"),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }