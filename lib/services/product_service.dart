import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  // Trỏ đến collection "sanpham" trong Firestore
  final _col = FirebaseFirestore.instance.collection('sanpham');

  // Lấy danh sách realtime
  Stream<List<Product>> getProducts() {
    return _col.snapshots().map((snap) =>
        snap.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  // Thêm sản phẩm mới
  Future<void> addProduct(Product p) => _col.add(p.toMap());

  // Sửa sản phẩm (dùng merge:true để chỉ cập nhật các trường thay đổi)
  Future<void> updateProduct(Product p) =>
      _col.doc(p.idsanpham).set(p.toMap(), SetOptions(merge: true));

  // Xóa sản phẩm theo ID
  Future<void> deleteProduct(String id) => _col.doc(id).delete();
}