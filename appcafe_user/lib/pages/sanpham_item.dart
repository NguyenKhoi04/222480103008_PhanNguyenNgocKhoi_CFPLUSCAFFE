import 'package:flutter/material.dart';
import 'model_sanpham.dart';

class SanPhamItem extends StatelessWidget {
  final SanPham sanPham;

  const SanPhamItem({super.key, required this.sanPham});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Image.network(
          sanPham.hinh,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.image_not_supported),
        ),
        title: Text(sanPham.ten),
        subtitle: Text('${sanPham.gia} đ'),
      ),
    );
  }
}
