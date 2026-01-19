import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_tutorial/screen/login_screen.dart';
import 'package:supabase_tutorial/screen/profile_screen.dart';

class EditScreen extends StatefulWidget {
  final Map<String, dynamic> notes;
  const EditScreen({super.key, required this.notes});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final supabase = Supabase.instance.client;
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  bool isLoading = false;
  bool isEdit = false;
  File? pickedFile;
  String url = "";
  Future<void> updateRecord() async {
    setState(() {
      isLoading = true;
    });
    try {
      await supabase.storage
          .from('Bucket 1')
          .upload(
            'users/${supabase.auth.currentUser!.id}',
            pickedFile!,
            fileOptions: FileOptions(upsert: true),
          );
      final url1 = supabase.storage
          .from("Bucket 1")
          .getPublicUrl('users/${supabase.auth.currentUser!.id}');

      await supabase
          .from('users')
          .update({
            'First Name': firstName.text,
            'Last Name': lastName.text,
            'profile_picture': url1,
          })
          .eq('user_id', supabase.auth.currentUser!.id);
      print("Updated");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    email.text = widget.notes['email'] ?? "";
    firstName.text = widget.notes['First Name'] ?? "";
    lastName.text = widget.notes['Last Name'] ?? "";
    url = widget.notes['profile_picture'] ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Edit"))),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          spacing: 20,
          children: [
            Stack(
              children: [
                Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent.shade200,
                    borderRadius: BorderRadius.circular(90),
                    border: Border.all(width: 1.5, color: Colors.black54),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: isEdit
                          ? FileImage(pickedFile!)
                          : NetworkImage(url),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 5,
                  left: 125,
                  child: InkWell(
                    onTap: () async {
                      final result = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                      );
                      if (result != null) {
                        setState(() {
                          pickedFile = File(result.path);
                          isEdit = true;
                        });
                      }
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        border: Border.all(width: 1.5),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(child: Icon(Icons.edit)),
                    ),
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: firstName,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter your first name",
                labelText: "First Name",
              ),
            ),
            TextFormField(
              controller: lastName,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter your last name",
                labelText: "Last Name",
              ),
            ),
            TextFormField(
              enabled: false,
              controller: email,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter your first name",
                labelText: "First Name",
              ),
            ),
            ElevatedButton(
              onPressed: () {
                updateRecord();
              },
              child: Center(
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.blueAccent)
                    : Text("Update"),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  // await supabase.functions.invoke('delete-account');
                  await supabase
                      .from('users')
                      .delete()
                      .eq('user_id', widget.notes['user_id']);
                  Timer(Duration(seconds: 5), () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                      (context) => false,
                    );
                  });
                } catch (e) {
                  print("Error : $e");
                }
              },
              child: Center(child: Text("Delete my account")),
            ),
          ],
        ),
      ),
    );
  }
}
