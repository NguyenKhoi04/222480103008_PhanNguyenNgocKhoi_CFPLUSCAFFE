import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class ThemDanhGiaPage extends StatefulWidget {
  const ThemDanhGiaPage({super.key});

  static const String _collectionPath = 'DanhGia';

  @override
  State<ThemDanhGiaPage> createState() => _ThemDanhGiaPageState();
}

class _ThemDanhGiaPageState extends State<ThemDanhGiaPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _hoTenKhachController;
  late TextEditingController _khachPhanHoiController;
  late TextEditingController _hinhAnhController;

  // Biến trạng thái
  int _selectedStar = 5; // Mặc định 5 sao
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller rỗng
    _hoTenKhachController = TextEditingController();
    _khachPhanHoiController = TextEditingController();
    _hinhAnhController = TextEditingController();
  }

  @override
  void dispose() {
    _hoTenKhachController.dispose();
    _khachPhanHoiController.dispose();
    _hinhAnhController.dispose();
    super.dispose();
  }

  Future<void> _submitDanhGia() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      // 1. Tạo ID tự động (dựa trên timestamp để đảm bảo tính duy nhất và là số)
      final generatedId = DateTime.now().millisecondsSinceEpoch;

      // 2. Chuẩn bị dữ liệu
      final data = <String, dynamic>{
        'id': generatedId, // ID số
        'HoTenKhachPhanHoi': _hoTenKhachController.text.trim(),
        'SoSao': _selectedStar,
        'KhachPhanAnh': _khachPhanHoiController.text.trim(),
        'HinhAnh': _hinhAnhController.text.trim(),
        
        // Tự động set thời gian hiện tại
        'ThoiGianKhachPhanHoi': Timestamp.now(),
        
        // Các trường của nhân viên để trống hoặc null
        'NhânVienPhanHoi': '',
        'ThoiGianNhanVienPhanHoi': null,
      };

      try {
        await FirebaseFirestore.instance
            .collection(ThemDanhGiaPage._collectionPath)
            .doc(generatedId.toString())
            .set(data);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cảm ơn bạn đã gửi đánh giá!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Quay về danh sách sau khi gửi xong
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi gửi đánh giá: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  // Widget hiển thị chọn sao
  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return IconButton(
          iconSize: 40,
          onPressed: () {
            setState(() {
              _selectedStar = starValue;
            });
          },
          icon: Icon(
            starValue <= _selectedStar ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viết đánh giá'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Bạn cảm thấy dịch vụ thế nào?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              
              // Chọn sao
              _buildStarRating(),
              
              Center(
                child: Text(
                  _selectedStar == 5 ? 'Tuyệt vời!' : 
                  _selectedStar == 4 ? 'Rất tốt' :
                  _selectedStar == 3 ? 'Bình thường' :
                  _selectedStar == 2 ? 'Tệ' : 'Rất tệ',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Nhập tên
              TextFormField(
                controller: _hoTenKhachController,
                decoration: const InputDecoration(
                  labelText: 'Tên của bạn',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                  hintText: 'Nhập tên hiển thị',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên của bạn';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Nhập nội dung
              TextFormField(
                controller: _khachPhanHoiController,
                decoration: const InputDecoration(
                  labelText: 'Chia sẻ cảm nhận của bạn',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập nội dung đánh giá';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Nhập URL hình ảnh (Nếu có file Cloudinary upload, bạn sẽ thay thế chỗ này bằng nút Upload)
              TextFormField(
                controller: _hinhAnhController,
                decoration: const InputDecoration(
                  labelText: 'Link hình ảnh (Tùy chọn)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                  helperText: 'Dán đường dẫn ảnh nếu có',
                ),
              ),
              
              const SizedBox(height: 32),

              // Nút Submit
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitDanhGia,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Gửi đánh giá',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}