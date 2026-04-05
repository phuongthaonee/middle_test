import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../services/storage_service.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});
  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _idCtrl = TextEditingController(text: widget.product?.idsanpham);
  late final _tenCtrl = TextEditingController(text: widget.product?.tensp);
  late final _loaiCtrl = TextEditingController(text: widget.product?.loaisp);
  late final _giaCtrl = TextEditingController(
    text: widget.product?.gia.toString(),
  );
  File? _imageFile;
  bool _loading = false;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    _existingImageUrl = widget.product?.hinhanh;
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _tenCtrl.dispose();
    _loaiCtrl.dispose();
    _giaCtrl.dispose();
    super.dispose();
  }

  // Chọn ảnh từ thư viện điện thoại
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      String? imageUrl = _existingImageUrl;
      // Nếu người dùng chọn ảnh mới → upload lên Storage
      if (_imageFile != null) {
        imageUrl = await StorageService().imageToBase64(_imageFile!);
      }
      final product = Product(
        docId: widget.product?.docId,
        idsanpham: _idCtrl.text.trim(),
        tensp: _tenCtrl.text.trim(),
        loaisp: _loaiCtrl.text.trim(),
        gia: double.parse(_giaCtrl.text.trim()),
        hinhanh: imageUrl,
      );
      if (widget.product == null) {
        await ProductService().addProduct(product);
      } else {
        await ProductService().updateProduct(product);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Sửa sản phẩm' : 'Thêm sản phẩm')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Khu vực chọn ảnh
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      : _existingImageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _existingImageUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Nhấn để chọn ảnh',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _idCtrl,
                decoration: const InputDecoration(
                  labelText: 'Mã sản phẩm (VD: SP001)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v!.isEmpty ? 'Vui lòng nhập mã sản phẩm' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tenCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tên sản phẩm',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _loaiCtrl,
                decoration: const InputDecoration(
                  labelText: 'Loại sản phẩm',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập loại' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _giaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Giá (VNĐ)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return 'Vui lòng nhập giá';
                  if (double.tryParse(v) == null) return 'Giá phải là số';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: _loading
                    ? const CircularProgressIndicator()
                    : Text(isEdit ? 'Cập nhật' : 'Thêm sản phẩm'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
