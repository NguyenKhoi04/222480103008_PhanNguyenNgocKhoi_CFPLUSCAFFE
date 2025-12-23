class DonHang {
  final String id; // documentId
  final String tenBan;
  final String tenSanPham;
  final String size;
  final String mucDa;
  final String hinhThuc;
  final String trangThai;
  final String hinhAnh;
  final int soLuong;
  final int tongTien;
  final int giaDonVi; // Giá đơn vị để tính toán lại tongTien

  DonHang({
    required this.id,
    required this.tenBan,
    required this.tenSanPham,
    required this.size,
    required this.mucDa,
    required this.soLuong,
    required this.tongTien,
    required this.hinhThuc,
    required this.trangThai,
    required this.hinhAnh,
    required this.giaDonVi,
  });

  factory DonHang.fromFirestore(String id, Map<String, dynamic> json) {
    return DonHang(
      id: id,
      tenBan: json['tenBan'] ?? json['Tên bàn'] ?? '',
      tenSanPham: json['tenSanPham'] ?? json['Tên sản phẩm'] ?? '',
      size: json['size'] ?? json['Size'] ?? '',
      mucDa: json['mucDa'] ?? json['Mức đá'] ?? '',
      soLuong: json['soLuong'] ?? json['Số lượng'] ?? 0,
      tongTien: json['tongTien'] ?? json['Tổng tiền'] ?? 0,
      hinhThuc: json['hinhThuc'] ?? json['hình thức'] ?? '',
      trangThai: json['trangthaiThanhToan'] ?? 'Chưa thanh toán',
      hinhAnh: json['hinhAnh'] ?? json['hinhAnh'] ?? '',
      giaDonVi: json['giaDonVi'] ?? json['Giá'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tenBan': tenBan,
      'tenSanPham': tenSanPham,
      'size': size,
      'mucDa': mucDa,
      'soLuong': soLuong,
      'tongTien': tongTien,
      'hinhThuc': hinhThuc,
      'trangthaiThanhToan': trangThai,
      'hinhAnh': hinhAnh,
      'giaDonVi': giaDonVi,
    };
  }
}
