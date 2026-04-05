import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../models/product.dart';
import '../services/product_service.dart';
import 'product_form_screen.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});
  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String? _selectedLoai;

  Widget _buildProductImage(String? hinhanh) {
    if (hinhanh == null || hinhanh.isEmpty) {
      return const Icon(Icons.inventory_2, size: 40);
    }
    if (hinhanh.startsWith('data:image')) {
      return Image.memory(
        base64Decode(hinhanh.split(',').last),
        width: 56,
        height: 56,
        fit: BoxFit.cover,
      );
    }
    return Image.network(hinhanh, width: 56, height: 56, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Sản Phẩm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: ProductService().getProducts(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final allProducts = snap.data ?? [];

          // Lấy danh sách các loại không trùng nhau để tạo bộ lọc, toSet() loại bỏ trùng lặp, toList() chuyển lại thành danh sách
          final cacLoai = allProducts.map((p) => p.loaisp).toSet().toList();

          final filtered = _selectedLoai == null
              ? allProducts
              : allProducts.where((p) => p.loaisp == _selectedLoai).toList();

          if (allProducts.isEmpty) {
            return const Center(child: Text('Chưa có sản phẩm nào.'));
          }

          return Column(
            children: [
              // Thanh lọc theo loại — chỉ hiện khi có ít nhất 1 sản phẩm
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  children: [
                    // Chip "Tất cả" — nhấn để bỏ filter
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('Tất cả'),
                        selected: _selectedLoai == null,
                        onSelected: (_) => setState(() => _selectedLoai = null),
                      ),
                    ),
                    ...cacLoai.map(
                      (loai) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(loai),
                          selected: _selectedLoai == loai,
                          onSelected: (_) =>
                              setState(() => _selectedLoai = loai),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Danh sách sản phẩm đã được lọc
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text('Không có sản phẩm loại "$_selectedLoai"'),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) {
                          final p = filtered[i];
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              ctx,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(product: p),
                              ),
                            ),
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ListTile(
                                leading: _buildProductImage(p.hinhanh),
                                title: Text(
                                  p.tensp,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  '${p.loaisp} — ${p.gia.toStringAsFixed(0)} đ',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () => Navigator.push(
                                        ctx,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ProductFormScreen(product: p),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        final ok = await showDialog<bool>(
                                          context: ctx,
                                          builder: (_) => AlertDialog(
                                            title: const Text('Xác nhận xóa'),
                                            content: Text(
                                              'Xóa sản phẩm "${p.tensp}"?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, false),
                                                child: const Text('Hủy'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, true),
                                                child: const Text(
                                                  'Xóa',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (ok == true) {
                                          ProductService().deleteProduct(
                                            p.docId!,
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProductFormScreen()),
        ),
      ),
    );
  }
}
