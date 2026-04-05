import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_form_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  // Tái sử dụng logic hiển thị ảnh Base64
  Widget _buildImage(String? hinhanh) {
    if (hinhanh == null || hinhanh.isEmpty) {
      return Container(
        height: 250,
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.inventory_2, size: 80, color: Colors.grey)),
      );
    }
    if (hinhanh.startsWith('data:image')) {
      return Image.memory(
        base64Decode(hinhanh.split(',').last),
        height: 250, width: double.infinity, fit: BoxFit.cover,
      );
    }
    return Image.network(hinhanh, height: 250, width: double.infinity, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProductFormScreen(product: product)),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(product.hinhanh),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.tensp,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Chip(
                  label: Text(product.loaisp),
                  backgroundColor: Colors.teal.withOpacity(0.1),
                  labelStyle: const TextStyle(color: Colors.teal),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Giá: ', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    Text(
                      '${product.gia.toStringAsFixed(0)} đ',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}