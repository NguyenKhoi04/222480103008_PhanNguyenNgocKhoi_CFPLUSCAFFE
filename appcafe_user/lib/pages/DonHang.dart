class DonHang {
  String tenBan;
  String tenSanPham;
  String size;
  String mucDa;
  String hinhThuc;
  String trangThai;
  String hinhAnh;
  int soLuong;
  int tongTien;

  DonHang({
    required this.tenBan,
    required this.tenSanPham,
    required this.size,
    required this.mucDa,
    required this.soLuong,
    required this.tongTien,
    required this.hinhThuc,
    required this.trangThai,
    required this.hinhAnh,
  });

  factory DonHang.fromJson(Map<String, dynamic> json) {
    return DonHang(
      tenBan: json['Tên bàn'],
      tenSanPham: json['Tên sản phẩm'],
      size: json['Size'],
      mucDa: json['Mức đá'],
      soLuong: json['Số lượng'],
      tongTien: json['Tổng tiền'],
      hinhThuc: json['Hình thức'],
      trangThai: json['trangthaithanhtoan'],
      hinhAnh: json['Hình ảnh'],
    );
  }
}
