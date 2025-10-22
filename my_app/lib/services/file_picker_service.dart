import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class FilePickerService {
  static final ImagePicker _picker = ImagePicker();

  // Проверка платформы
  static bool get isWeb => kIsWeb;

  // Выбор изображения из галереи
  static Future<XFile?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
      return null;
    }
  }

  // Сделать фото с камеры
  static Future<XFile?> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return photo;
    } catch (e) {
      if (kDebugMode) {
        print('Error taking photo: $e');
      }
      return null;
    }
  }

  // Конвертация XFile в File
  static Future<File?> convertToFile(XFile? xFile) async {
    if (xFile == null) return null;
    return File(xFile.path);
  }

  // Чтение файла как bytes
  static Future<Uint8List?> readFileAsBytes(XFile? file) async {
    if (file == null) return null;
    return await file.readAsBytes();
  }
}