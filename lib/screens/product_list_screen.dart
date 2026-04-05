import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../models/product.dart';
import '../services/product_service.dart';
import 'product_form_screen.dart';

class ProductListScreen extends StatelessWidget {

  // Hàm tiện ích để hiển thị ảnh — đặt ở đầu class hoặc bên ngoài class
  Widget _buildProductImage(String? hinhanh) {
    // Nếu không có ảnh, hiển thị icon mặc định
    if (hinhanh == null || hinhanh.isEmpty) {
      return const Icon(Icons.inventory_2, size: 40);
    }

    // Nếu là chuỗi Base64 (bắt đầu bằng "data:image")
    if (hinhanh.startsWith('data:image')) {
      // Tách lấy phần Base64 thuần túy (bỏ phần prefix "data:image/jpeg;base64,")
      final base64Str = hinhanh.split(',').last;
      // Giải mã Base64 thành bytes rồi hiển thị bằng Image.memory
      return Image.memory(
        base64Decode(base64Str),
        width: 56, height: 56, fit: BoxFit.cover,
      );
    }

  // Nếu là URL thông thường (phòng trường hợp có data cũ)
    return Image.network(hinhanh, width: 56, height: 56, fit: BoxFit.cover);
  }
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Sản Phẩm'),
        actions: [
          // Nút đăng xuất
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      // StreamBuilder tự động refresh danh sách khi Firestore thay đổi
      body: StreamBuilder<List<Product>>(
        stream: ProductService().getProducts(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final products = snap.data ?? [];
          if (products.isEmpty) {
            return const Center(child: Text('Chưa có sản phẩm nào.'));
          }
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (ctx, i) {
              final p = products[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: _buildProductImage(p.hinhanh),
                  title: Text(p.tensp, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${p.loaisp} — ${p.gia.toStringAsFixed(0)} đ'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nút sửa
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => Navigator.push(ctx,
                          MaterialPageRoute(builder: (_) => ProductFormScreen(product: p))),
                      ),
                      // Nút xóa với xác nhận
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: ctx,
                            builder: (_) => AlertDialog(
                              title: const Text('Xác nhận xóa'),
                              content: Text('Xóa sản phẩm "${p.tensp}"?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                          if (ok == true) ProductService().deleteProduct(p.idsanpham!);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const ProductFormScreen())),
      ),
    );
  }
}