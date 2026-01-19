import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PickImageScreen extends StatefulWidget {
  const PickImageScreen({super.key});

  @override
  State<PickImageScreen> createState() => _PickImageScreenState();
}

class _PickImageScreenState extends State<PickImageScreen> {
  final supabase = Supabase.instance.client;
  File? pickedFile;

  Future<void> uploadImage() async {
    String filename = DateTime.now().microsecondsSinceEpoch.toString();
    final ext = pickedFile?.path.split('.').last;
    try {
      final result = supabase.storage
          .from('Bucket 1')
          .upload('$filename.$ext', pickedFile!);
      print("Result: $result");
      String url = supabase.storage
          .from('Bucket 1')
          .getPublicUrl('$filename.$ext');
      print("Url: $url");
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> getImages() async {
    final listOfImages = await supabase.storage.from("Bucket 1").list();
    for (var image in listOfImages) {
      print('Image $image');
    }
  }

  @override
  void initState() {
    getImages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Pick Image"))),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            pickedFile == null ? SizedBox() : Image.file(pickedFile!),
            ElevatedButton(
              onPressed: () async {
                final result = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                );
                if (result != null) {
                  setState(() {
                    pickedFile = File(result.path);
                  });
                }
              },
              child: Center(child: Text("Pick image from gallery")),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                uploadImage();
              },
              child: Center(child: Text("Upload image")),
            ),
          ],
        ),
      ),
    );
  }
}
