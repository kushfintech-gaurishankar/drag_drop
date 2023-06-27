import 'package:drag_drop/GridViewDrag/home.dart';
import 'package:drag_drop/MemoryImage/memory_image.dart';
import 'package:drag_drop/VideoPlayer/videos.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  runApp(const DragDrop());
}

class DragDrop extends StatefulWidget {
  const DragDrop({super.key});

  @override
  State<DragDrop> createState() => _DragDropState();
}

class _DragDropState extends State<DragDrop> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VideoList(),
    );
  }
}
