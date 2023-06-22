import 'dart:typed_data';

import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class ImageData {
  @HiveField(0)
  String name;

  @HiveField(0)
  Uint8List image;

  ImageData({
    required this.name,
    required this.image,
  });
}
