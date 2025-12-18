import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FragmentHome extends StatefulWidget {
   final VoidCallback onThemHang;
  const FragmentHome({super.key, required this.onThemHang});

  @override
  State<FragmentHome> createState() => _FragmentHomeState();
}

class _FragmentHomeState extends State<FragmentHome>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> searchList = [];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);

    searchController.addListener(() {
      if (searchController.text.trim().isEmpty) {
        setState(() {
          searchList.clear();
        });
      } else {
        doSearch(searchController.text.trim());
      }
    });
  }

  /// --------------------------
  /// KIỂM TRA TỪ KHÓA (Regex)
  /// --------------------------
  bool isValidKeyword(String keyword) {
    final regex = RegExp(r'^[\p{L}\p{N} ]{1,50}$', unicode: true);
    return regex.hasMatch(keyword);
  }

  /// --------------------------
  /// HÀM BỎ DẤU TIẾNG VIỆT
  /// --------------------------
  String removeAccent(String str) {
    const withDia =
        "àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡ"
        "ùúụủũưừứựửữỳýỵỷỹđ";
    const withoutDia =
        "aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd";

    str = str.toLowerCase();
    for (int i = 0; i < withDia.length; i++) {
      str = str.replaceAll(withDia[i], withoutDia[i]);
    }
    return str;
  }

  /// --------------------------
  /// HÀM TÌM KIẾM FIRESTORE
  /// --------------------------
  void doSearch(String keyword) async {
    if (!isValidKeyword(keyword)) {
      setState(() => searchList.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Từ khóa không hợp lệ!")),
      );
      return;
    }

    final snapshots = await FirebaseFirestore.instance
        .collection("Tìm kiếm")
        .get();

    final results = snapshots.docs.where((doc) {
      final ten = doc["Ten"] ?? "";
      return removeAccent(ten)
          .contains(removeAccent(keyword));
    }).map((doc) => doc.data()).toList();

    setState(() {
      searchList = List<Map<String, dynamic>>.from(results);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isSearching = searchList.isNotEmpty ||
        searchController.text.trim().isNotEmpty;

    return Column(
      children: [
        // ---------------- SEARCH ----------------
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
                hintText: "Tìm kiếm sản phẩm...",
                border: InputBorder.none,
                icon: Icon(Icons.search)),
          ),
        ),

        // ---------------- BUTTON THÊM HÀNG ----------------
        ElevatedButton(
          onPressed: widget.onThemHang,
          child: const Text("Thêm vào giỏ hàng"),
        ),

        // ---------------- TAB + PAGEVIEW ----------------
        if (!isSearching)
          TabBar(
            controller: tabController,
            labelColor: Colors.brown,
            tabs: const [
              Tab(text: "Tất cả"),
              Tab(text: "Best Seller"),
              Tab(text: "Món ngon phải thử"),
            ],
          ),

        Expanded(
          child: isSearching
              ? buildSearchList()
              : TabBarView(
                  controller: tabController,
                  children: const [
                    Center(child: Text("Tất cả sản phẩm")),
                    Center(child: Text("Best Seller")),
                    Center(child: Text("Món ngon phải thử")),
                  ],
                ),
        ),
      ],
    );
  }

  /// --------------------------------------
  /// LISTVIEW HIỂN THỊ KẾT QUẢ TÌM KIẾM
  /// --------------------------------------
  Widget buildSearchList() {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: searchList.length,
      itemBuilder: (context, index) {
        final sp = searchList[index];
        return InkWell(
          onTap: () {
            Navigator.pushNamed(context, "/chitiet",
                arguments: {
                  "Ten": sp["Ten"],
                  "Gia": sp["Gia"],
                  "hinhAnh": sp["hinhAnh"]
                });
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Image.network(
                sp["hinhAnh"],
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
              title: Text(sp["Ten"] ?? ""),
              subtitle: Text("Giá: ${sp["Gia"]}"),
            ),
          ),
        );
      },
    );
  }
}
