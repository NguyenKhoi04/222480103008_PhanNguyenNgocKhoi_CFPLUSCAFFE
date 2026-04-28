import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'chitiet_phanhoi.dart';
import 'them_danhgia.dart';

class DanhGiaPage extends StatelessWidget {
  const DanhGiaPage({super.key});

  static String _formatDateTime(dynamic value) {
    if (value == null) return '';

    try {
      final date =
          DateTime.parse(value.toString())
              .toLocal();

      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Đánh giá & Phản hồi',
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const ThemDanhGiaPage(),
            ),
          );
        },
        icon: const Icon(
          Icons.rate_review,
        ),
        label: const Text(
          'Viết đánh giá',
        ),
        backgroundColor: Colors.orange,
      ),

      body: StreamBuilder<
          List<Map<String, dynamic>>>(
        stream: client
            .from('reviews')
            .stream(primaryKey: ['id'])
            .order(
              'customer_reply_at',
              ascending: false,
            ),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Lỗi tải dữ liệu: ${snapshot.error}',
              ),
            );
          }

          final docs =
              snapshot.data ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: const [
                  Icon(
                    Icons.star_border,
                    size: 60,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Chưa có đánh giá nào.\nHãy là người đầu tiên!',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      color:
                          Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(
                    12),
            itemCount: docs.length,
            itemBuilder:
                (context, index) {
              final data =
                  docs[index];

              final id =
                  data['id']
                      .toString();

              final hoTenKhach =
                  data['customer_name']
                          as String? ??
                      'Khách ẩn danh';

              final soSao =
                  data['rating'];

              final int soSaoInt =
                  soSao is num
                      ? soSao.toInt()
                      : int.tryParse(
                              soSao
                                      ?.toString() ??
                                  '0') ??
                          0;

              final khachPhanHoi =
                  data['customer_comment']
                          as String? ??
                      '';

              final nhanVienPhanHoi =
                  data['manager_reply']
                          as String? ??
                      '';

              final thoiGianKhach =
                  data[
                      'customer_reply_at'];

              return Card(
                margin:
                    const EdgeInsets.only(
                  bottom: 12,
                ),
                elevation: 1,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                          12),
                ),
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(
                          12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ChiTietPhanHoiPage(
                          id: id,
                          data: data,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets
                            .all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  Colors.grey[
                                      200],
                              child: Text(
                                hoTenKhach
                                        .isNotEmpty
                                    ? hoTenKhach[
                                            0]
                                        .toUpperCase()
                                    : '?',
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            const SizedBox(
                                width:
                                    12),
                            Expanded(
                              child:
                                  Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hoTenKhach,
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize:
                                          16,
                                    ),
                                  ),
                                  Text(
                                    _formatDateTime(
                                      thoiGianKhach,
                                    ),
                                    style:
                                        TextStyle(
                                      fontSize:
                                          12,
                                      color: Colors.grey[
                                          600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                            height:
                                12),

                        Row(
                          children:
                              List.generate(
                            5,
                            (star) =>
                                Icon(
                              star <
                                      soSaoInt
                                  ? Icons
                                      .star
                                  : Icons
                                      .star_border,
                              color: Colors
                                  .amber,
                              size: 20,
                            ),
                          ),
                        ),

                        const SizedBox(
                            height:
                                8),

                        if (khachPhanHoi
                            .isNotEmpty)
                          Text(
                            khachPhanHoi,
                            style:
                                const TextStyle(
                              fontSize:
                                  15,
                              height:
                                  1.4,
                            ),
                          ),

                        if (nhanVienPhanHoi
                            .isNotEmpty) ...[
                          const SizedBox(
                              height:
                                  16),
                          Container(
                            width: double
                                .infinity,
                            padding:
                                const EdgeInsets.all(
                                    12),
                            decoration:
                                BoxDecoration(
                              color: Colors
                                  .grey[100],
                              borderRadius:
                                  BorderRadius.circular(
                                      8),
                              border:
                                  Border(
                                left:
                                    BorderSide(
                                  color: Colors
                                      .blue
                                      .shade400,
                                  width:
                                      4,
                                ),
                              ),
                            ),
                            child:
                                Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Phản hồi từ Cửa hàng:',
                                  style:
                                      TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize:
                                        13,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(
                                    height:
                                        4),
                                Text(
                                  nhanVienPhanHoi,
                                  style:
                                      TextStyle(
                                    fontSize:
                                        14,
                                    color: Colors.grey[
                                        800],
                                    fontStyle:
                                        FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'chitiet_phanhoi.dart';
// import 'them_danhgia.dart'; // Bạn cần tạo file này để khách viết đánh giá

// class DanhGiaPage extends StatelessWidget {
//   const DanhGiaPage({super.key});

//   static const String _collectionPath = 'DanhGia';

//   // Hàm format ngày tháng thân thiện với người dùng
//   static String _formatDateTime(Timestamp? timestamp) {
//     if (timestamp == null) return '';
//     final date = timestamp.toDate();
//     return '${date.day}/${date.month}/${date.year}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Đánh giá & Phản hồi'),
//         centerTitle: true,
//         backgroundColor: Colors.blue, // Màu chủ đạo tùy chọn
//         foregroundColor: Colors.white,
//       ),
//       // Nút để khách hàng viết đánh giá mới
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               // Chuyển đến trang Thêm Đánh Giá thay vì Sửa
//               builder: (context) => const ThemDanhGiaPage(),
//             ),
//           );
//         },
//         icon: const Icon(Icons.rate_review),
//         label: const Text('Viết đánh giá'),
//         backgroundColor: Colors.orange,
//       ),
//       body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//         // Sắp xếp theo thời gian mới nhất lên đầu
//         stream: FirebaseFirestore.instance
//             .collection(_collectionPath)
//             .orderBy('ThoiGianKhachPhanHoi', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
//           }

//           final docs = snapshot.data?.docs ?? [];
//           if (docs.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: const [
//                   Icon(Icons.star_border, size: 60, color: Colors.grey),
//                   SizedBox(height: 10),
//                   Text(
//                     'Chưa có đánh giá nào.\nHãy là người đầu tiên!',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ],
//               ),
//             );
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.all(12),
//             itemCount: docs.length,
//             itemBuilder: (context, index) {
//               final doc = docs[index];
//               final data = doc.data();

//               // Lấy dữ liệu an toàn
//               final hoTenKhach =
//                   data['HoTenKhachPhanHoi'] as String? ?? 'Khách ẩn danh';
//               final soSao = data['SoSao'];
//               final int soSaoInt = (soSao is num)
//                   ? soSao.toInt()
//                   : (int.tryParse(soSao?.toString() ?? '0') ?? 0);
//               final khachPhanHoi = data['KhachPhanAnh'] as String? ?? '';
//               final nhanVienPhanHoi = data['NhânVienPhanHoi'] as String? ?? '';
//               final thoiGianKhach = data['ThoiGianKhachPhanHoi'] as Timestamp?;

//               return Card(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 elevation: 1, // Giảm độ bóng để nhìn hiện đại hơn
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: InkWell(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ChiTietPhanHoiPage(
//                           id: doc.id,
//                           data: data,
//                         ),
//                       ),
//                     );
//                   },
//                   borderRadius: BorderRadius.circular(12),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Header: Avatar + Tên + Ngày
//                         Row(
//                           children: [
//                             CircleAvatar(
//                               backgroundColor: Colors.grey[200],
//                               child: Text(
//                                 hoTenKhach.isNotEmpty
//                                     ? hoTenKhach[0].toUpperCase()
//                                     : '?',
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.blue),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     hoTenKhach,
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                   Text(
//                                     _formatDateTime(thoiGianKhach),
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.grey[600],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 12),

//                         // Số sao đánh giá
//                         Row(
//                           children: List.generate(5, (index) {
//                             return Icon(
//                               index < soSaoInt ? Icons.star : Icons.star_border,
//                               color: Colors.amber,
//                               size: 20,
//                             );
//                           }),
//                         ),

//                         const SizedBox(height: 8),

//                         // Nội dung khách phản hồi
//                         if (khachPhanHoi.isNotEmpty)
//                           Text(
//                             khachPhanHoi,
//                             style: const TextStyle(fontSize: 15, height: 1.4),
//                           ),

//                         // Phần Admin/Nhân viên trả lời (chỉ hiện nếu có trả lời)
//                         if (nhanVienPhanHoi.isNotEmpty) ...[
//                           const SizedBox(height: 16),
//                           Container(
//                             width: double.infinity,
//                             padding: const EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: Colors.grey[100],
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border(
//                                 left: BorderSide(
//                                     color: Colors.blue.shade400, width: 4),
//                               ),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   'Phản hồi từ Cửa hàng:',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 13,
//                                     color: Colors.blue,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   nhanVienPhanHoi,
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.grey[800],
//                                     fontStyle: FontStyle.italic,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
