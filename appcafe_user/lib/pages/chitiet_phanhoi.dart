import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChiTietPhanHoiPage extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;

  const ChiTietPhanHoiPage({
    super.key,
    required this.id,
    required this.data,
  });

  static const String _collectionPath = 'DanhGia';

  // Hàm format ngày tháng
  String _formatDateTime(Timestamp? timestamp, {bool showTime = false}) {
    if (timestamp == null) return '---';
    final date = timestamp.toDate();
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;

    if (showTime) {
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$day/$month/$year lúc $hour:$minute';
    }
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đánh giá'),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection(_collectionPath)
            .doc(id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentData = snapshot.data?.data() ?? data;

          // Trích xuất dữ liệu
          final hinhAnhUrl = currentData['HinhAnh'] as String? ?? '';
          final hoTenKhach = currentData['HoTenKhachPhanHoi'] as String? ?? 'Ẩn danh';
          final soSao = currentData['SoSao'];
          final soSaoNum = soSao is num ? soSao.toInt() : (int.tryParse(soSao?.toString() ?? '') ?? 0);
          final khachPhanHoi = currentData['KhachPhanAnh'] as String? ?? '';
          final nhanVienPhanHoi = currentData['NhânVienPhanHoi'] as String? ?? '';
          final thoiGianKhachTs = currentData['ThoiGianKhachPhanHoi'] as Timestamp?;
          final thoiGianNhanVienTs = currentData['ThoiGianNhanVienPhanHoi'] as Timestamp?;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Phần thông tin khách hàng và Đánh giá
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Avatar + Tên + Ngày
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                hoTenKhach.isNotEmpty ? hoTenKhach[0].toUpperCase() : '?',
                                style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hoTenKhach,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    _formatDateTime(thoiGianKhachTs, showTime: true),
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Số sao
                        Row(
                          children: List.generate(5, (index) => Icon(
                            index < soSaoNum ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 28,
                          )),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Nội dung review
                        Text(
                          khachPhanHoi.isNotEmpty ? khachPhanHoi : 'Không có nội dung.',
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),

                        // === PHẦN HIỂN THỊ HÌNH ẢNH TỪ CLOUDINARY ===
                        if (hinhAnhUrl.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Hình ảnh đính kèm:',
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              hinhAnhUrl,
                              // Giới hạn chiều cao để hình không quá lớn (hình nhỏ/preview)
                              height: 200, 
                              width: double.infinity,
                              fit: BoxFit.cover, // Cắt ảnh cho vừa khung
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 200,
                                  color: Colors.grey[200],
                                  child: const Center(child: CircularProgressIndicator()),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 150,
                                  color: Colors.grey[200],
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.broken_image, color: Colors.grey),
                                      Text('Không tải được ảnh', style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 2. Phần Phản hồi của Cửa hàng (Nếu có)
                if (nhanVienPhanHoi.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(left: 20), // Thụt đầu dòng để tạo cảm giác trả lời
                    child: Card(
                      color: Colors.grey[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.blue.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.store, color: Colors.blue.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  'Phản hồi từ Cửa hàng',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              nhanVienPhanHoi,
                              style: const TextStyle(fontSize: 15),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                _formatDateTime(thoiGianNhanVienTs, showTime: true),
                                style: TextStyle(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 30),

                // Nút quay lại
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                      elevation: 0,
                    ),
                    child: const Text('Quay lại danh sách'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}