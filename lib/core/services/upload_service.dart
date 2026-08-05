import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'supabase_service.dart';
import 'logger_service.dart';
import '../config/supabase_config.dart';

class UploadService {
  UploadService._();

  static final _uuid = const Uuid();

  /// Picks an image from gallery using image_picker
  static Future<XFile?> pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      return await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    } catch (e, st) {
      LoggerService.error('pickImageFromGallery failed', error: e, stackTrace: st);
      return null;
    }
  }

  /// Picks an image from camera using image_picker
  static Future<XFile?> pickImageFromCamera() async {
    try {
      final picker = ImagePicker();
      return await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    } catch (e, st) {
      LoggerService.error('pickImageFromCamera failed', error: e, stackTrace: st);
      return null;
    }
  }

  /// Picks any file using file_picker
  static Future<File?> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: false);
      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e, st) {
      LoggerService.error('pickFile failed', error: e, stackTrace: st);
      return null;
    }
  }

  /// Uploads a file to Supabase Storage
  /// Returns the public URL if successful, otherwise null.
  static Future<String?> uploadFile({
    required File file,
    required String folderName, // e.g., 'products', 'avatars'
  }) async {
    try {
      final fileExt = file.path.split('.').last;
      final fileName = '${_uuid.v4()}.$fileExt';
      final filePath = '$folderName/$fileName';

      await SupabaseService.storage
          .from(SupabaseConfig.storageBucket)
          .upload(filePath, file);

      final publicUrl = SupabaseService.storage
          .from(SupabaseConfig.storageBucket)
          .getPublicUrl(filePath);

      LoggerService.info('File uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e, st) {
      LoggerService.error('uploadFile failed', error: e, stackTrace: st);
      return null;
    }
  }

  /// Deletes a file from Supabase Storage using its path
  static Future<bool> deleteFile({required String folderName, required String fileName}) async {
    try {
      final filePath = '$folderName/$fileName';
      await SupabaseService.storage
          .from(SupabaseConfig.storageBucket)
          .remove([filePath]);
      
      LoggerService.info('File deleted successfully: $filePath');
      return true;
    } catch (e, st) {
      LoggerService.error('deleteFile failed', error: e, stackTrace: st);
      return false;
    }
  }
}