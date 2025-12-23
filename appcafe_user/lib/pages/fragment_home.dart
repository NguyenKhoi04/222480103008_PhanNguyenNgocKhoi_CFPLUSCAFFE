import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:appcafe_user/pages/tabOne_Tatca.dart';
import 'package:appcafe_user/pages/tabTwo_BestSeller.dart';
import 'package:appcafe_user/pages/tabThree_Monngon.dart';

class FragmentHome extends StatefulWidget {
  final VoidCallback onThemHang;
  const FragmentHome({super.key, required this.onThemHang});

  @override
  State<FragmentHome> createState() => _FragmentHomeState();
}

class _FragmentHomeState extends State<FragmentHome>
    with SingleTickerProviderStateMixin {
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

  // ----------------- KIỂM TRA TỪ KHÓA -----------------
  bool isValidKeyword(String keyword) {
    final regex = RegExp(r'^[\p{L}\p{N} ]{1,50}$', unicode: true);
    return regex.hasMatch(keyword);
  }

  // ----------------- BỎ DẤU TIẾNG VIỆT -----------------
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

  // ----------------- TÌM KIẾM FIRESTORE -----------------
  Future<void> doSearch(String keyword) async {
    if (!isValidKeyword(keyword)) {
      setState(() => searchList.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Từ khóa không hợp lệ!")),
      );
      return;
    }

    final snapshot =
        await FirebaseFirestore.instance.collection("Tìm kiếm").get();

    final results = snapshot.docs.where((doc) {
      final data = doc.data();

      if (!data.containsKey("Ten")) return false;

      final ten = data["Ten"].toString();
      return removeAccent(ten).contains(removeAccent(keyword));
    }).map((doc) => doc.data()).toList();

    setState(() {
      searchList = List<Map<String, dynamic>>.from(results);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isSearching =
        searchController.text.trim().isNotEmpty && searchList.isNotEmpty;

    return Column(
      children: [
        // ---------------- SEARCH ----------------
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 4)
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

        // ---------------- BUTTON ----------------
        ElevatedButton(
          onPressed: widget.onThemHang,
          child: const Text("Thêm vào giỏ hàng"),
        ),

        // ---------------- TAB ----------------
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
                    TabOneTatCa(),
                    TabTwoBestSeller(),
                    TabThreeMonngon(),
                  ],
                ),
        ),
      ],
    );
  }

  // ----------------- LIST KẾT QUẢ TÌM KIẾM -----------------
  Widget buildSearchList() {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: searchList.length,
      itemBuilder: (context, index) {
        final sp = searchList[index];

        final String ten = sp.containsKey("Ten") ? sp["Ten"].toString() : "";
        final String hinh = sp["hinhAnh"] ?? "";

        final rawGia = sp["Gia"];
        final double gia = rawGia is num
            ? rawGia.toDouble()
            : double.tryParse(
                    rawGia.toString().replaceAll(RegExp(r'[^0-9]'), '')) ??
                0;

        return InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              "/chitiet_sanpham",
              arguments: {
                "ten": ten,
                "gia": gia,
                "hinhAnh": hinh,
              },
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Image.network(
                hinh,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
              title: Text(ten),
              subtitle: Text("Giá: ${gia.toStringAsFixed(0)} đ"),
            ),
          ),
        );
      },
    );
  }
}
