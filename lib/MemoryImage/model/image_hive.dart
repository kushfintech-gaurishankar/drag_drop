import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'image_hive.g.dart';

@HiveType(typeId: 0)
class ImageData extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  Uint8List image;

  ImageData({
    required this.name,
    required this.image,
  });
}
