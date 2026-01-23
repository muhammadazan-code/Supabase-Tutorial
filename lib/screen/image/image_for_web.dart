import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageForWebScreen extends StatefulWidget {
  const ImageForWebScreen({super.key});

  @override
  State<ImageForWebScreen> createState() => _ImageForWebScreenState();
}

class _ImageForWebScreenState extends State<ImageForWebScreen> {
  List<Uint8List> listOfImage = <Uint8List>[];
  final supabase = Supabase.instance.client;
  final ImagePicker imagePicker = ImagePicker();
  Future<void> getImageLocally() async {
    try {
      final List<XFile> images = await imagePicker.pickMultiImage();

      if (images.isNotEmpty) {
        for (var i = 0; i < images.length; i++) {
          final bytes = await images[i].readAsBytes();
          setState(() {
            listOfImage.add(bytes);
          });
        }
      }
    } catch (e) {
      print("Eror $e");
    }
  }

  Future<void> uploadImage() async {
    try {
      for (var element in listOfImage) {
        List<dynamic> listofImagesInDB = await supabase
            .from('images')
            .select()
            .eq('auth_id', supabase.auth.currentUser!.id);
        if (kDebugMode) {
          print("Length of Images in Data base: ${listofImagesInDB.length}");
        }

        final path =
            'images/${supabase.auth.currentUser!.id}_${listofImagesInDB.length + 1}';
        final result = await supabase.storage
            .from('Bucket 1')
            .uploadBinary(
              path,
              element,
              fileOptions: FileOptions(contentType: 'image/png'),
            )
            .then((value) async {
              final url = supabase.storage.from('Bucket 1').getPublicUrl(path);
              await supabase.from('images').insert({
                'image_url': url,
                'auth_id': supabase.auth.currentUser?.id,
              });
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Images are uploading")));
            });
      }
      listOfImage.clear();
    } catch (e) {
      if (kDebugMode) {
        print("Error $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Image Picker for Web"))),
      body: Padding(
        padding: EdgeInsetsGeometry.all(15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => getImageLocally(),
                    child: Center(child: Text("Pick image")),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => uploadImage(),
                    child: Center(child: Text("Upload Image")),
                  ),
                ],
              ),
              SizedBox(height: 50),
              if (listOfImage.isNotEmpty)
                Wrap(
                  alignment: WrapAlignment.start,
                  runSpacing: 20,
                  spacing: 30,
                  children: listOfImage
                      .map(
                        (e) => Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            border: Border.all(width: 1.5),
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(image: MemoryImage(e)),
                          ),
                        ),
                      )
                      .toList(),
                ),
              SizedBox(height: 50),
              Text(
                "Images uploaded",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
              SizedBox(height: 30),
              StreamBuilder(
                stream: supabase
                    .from('images')
                    .stream(primaryKey: ['auth_id'])
                    .eq('auth_id', supabase.auth.currentUser!.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.none) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.blueAccent,
                      ),
                    );
                  } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                    return Center(child: Text("Images are not uploaded yet!"));
                  }
                  List<Map<String, dynamic>> data = snapshot.data ?? [];
                  return Wrap(
                    alignment: WrapAlignment.start,
                    runSpacing: 10,
                    spacing: 20,
                    children: data
                        .map(
                          (url) => Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              border: Border.all(width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image: NetworkImage(url['image_url']),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
