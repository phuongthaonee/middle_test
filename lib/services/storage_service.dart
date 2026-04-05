import 'dart:io';
import 'dart:convert';
import 'package:image/image.dart' as img;

class StorageService {
  Future<String> imageToBase64(File imageFile) async {
    // Đọc toàn bộ nội dung file ảnh dưới dạng bytes (mảng số)
    final bytes = await imageFile.readAsBytes();

    // Dùng thư viện 'image' để decode bytes thành đối tượng ảnh mà ta có thể thao tác được (resize, nén...)
    final decoded = img.decodeImage(bytes);

    // Resize về chiều rộng tối đa 400px, giữ tỉ lệ gốc vì Firestore giới hạn mỗi document tối đa 1MB — nếu ảnh gốc 4K thì chuỗi Base64 sẽ vượt giới hạn đó
    final resized = img.copyResize(decoded!, width: 400);

    // Nén thành JPEG với chất lượng 75% — đủ để hiển thị đẹp trong app
    final compressed = img.encodeJpg(resized, quality: 75);

    // Chuyển mảng bytes đã nén thành chuỗi Base64, thêm prefix "data:image/jpeg;base64," để Flutter biết đây là ảnh được mã hóa Base64, không phải URL thông thường
    return 'data:image/jpeg;base64,${base64Encode(compressed)}';
  }
}