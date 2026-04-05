import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String? idsanpham;
  String tensp;
  String loaisp;
  double gia;
  String? hinhanh;

  Product({
    this.idsanpham,
    required this.tensp,
    required this.loaisp,
    required this.gia,
    this.hinhanh,
  });

  // Tạo Product từ dữ liệu Firestore
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      idsanpham: doc.id,
      tensp: data['tensp'] ?? '',
      loaisp: data['loaisp'] ?? '',
      gia: (data['gia'] ?? 0).toDouble(),
      hinhanh: data['hinhanh'],
    );
  }

  // Chuyển Product thành Map để lưu lên Firestore
  Map<String, dynamic> toMap() => {
    'tensp': tensp,
    'loaisp': loaisp,
    'gia': gia,
    'hinhanh': hinhanh,
  };
}