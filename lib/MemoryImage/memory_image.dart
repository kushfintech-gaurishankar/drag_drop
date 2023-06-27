import 'dart:io';
import 'dart:typed_data';

import 'package:drag_drop/MemoryImage/model/image_hive.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';

class TestHome extends StatefulWidget {
  const TestHome({super.key});

  @override
  State<TestHome> createState() => _TestHomeState();
}

class _TestHomeState extends State<TestHome> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  bool downloading = false;

  late final Box<ImageData> imageBox;

  List<ImageData> images = [];

  @override
  void initState() {
    getImages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _urlController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Url is required.";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: "Image Url",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      top: 10,
                      bottom: 20,
                    ),
                    child: TextFormField(
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Name is required.";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: "Image Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!downloading)
              ElevatedButton(
                onPressed: downloadImage,
                child: const Icon(
                  Icons.download_rounded,
                ),
              )
            else
              const CircularProgressIndicator(strokeWidth: 2),
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 20),
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.4,
              children: List.generate(images.length, (index) {
                return Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Image(
                      height: double.maxFinite,
                      fit: BoxFit.cover,
                      image: MemoryImage(images[index].image),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(color: Colors.black12),
                      child: Text(
                        images[index].name,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void getImages() async {
    Hive.registerAdapter(ImageDataAdapter());
    imageBox = await Hive.openBox<ImageData>("Image");
    images = imageBox.values.toList().reversed.toList();

    setState(() {});
  }

  void downloadImage() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      downloading = true;
    });
    try {
      Response response = await get(Uri.parse(_urlController.text));
      if (response.statusCode == 200) {
        Uint8List image = response.bodyBytes;
        ImageData imageModel =
            ImageData(name: _nameController.text, image: image);
        List<ImageData> tempImages = [imageModel];
        tempImages.addAll(images);
        images = tempImages;

        setState(() {});

        imageBox.add(imageModel);
      }
    } on SocketException {
      debugPrint("No Internet");
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      downloading = false;
    }
  }
}
