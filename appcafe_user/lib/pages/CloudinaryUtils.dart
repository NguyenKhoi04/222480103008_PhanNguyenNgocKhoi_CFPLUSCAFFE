import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryUtils {
  static CloudinaryPublic? _cloudinary;

  /// Khởi tạo Cloudinary (Singleton)
  static CloudinaryPublic getCloudinary() {
    _cloudinary ??= CloudinaryPublic(
      'dyotufpoy', // cloud_name
      'flutter_unsigned', // ⚠️ upload preset (Unsigned)
      cache: false,
    );
    return _cloudinary!;
  }

  /// Upload ảnh lên Cloudinary
  static Future<String?> uploadImage(File imageFile) async {
    try {
      final cloudinary = getCloudinary();

      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      return response.secureUrl;
    } on CloudinaryException catch (e) {
      print('Cloudinary Error: ${e.message}');
      return null;
    }
  }
}
