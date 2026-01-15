import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_tutorial/screen/login_screen.dart';
import 'package:supabase_tutorial/screen/profile_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();

  bool loading = false;
  final supabase = Supabase.instance.client;
  File? pickFile;

  Future<void> registerAccount() async {
    setState(() {
      loading = true;
    });
    try {
      final result = await supabase.auth.signUp(
        password: passwordController.text,
        email: emailController.text,
      );
      if (result.user == null && result.session == null) {
        print("User is null");
      }
      print("Result.user ${result.user}");
      if (result.user != null && result.session != null) {
        await supabase.storage
            .from('Bucket 1')
            .upload('users/${result.user?.id}', pickFile!);
        final url = supabase.storage
            .from("Bucket 1")
            .getPublicUrl('users/${result.user?.id}');
        await supabase.from('users').insert({
          'First Name': firstName.text,
          'Last Name': lastName.text,
          'email': emailController.text,
          'user_id': result.user?.id,
          'profile_picture': url,
        });
        // String url2 = await supabase.storage
        //     .from('Bucket 1')
        //     .createSignedUrl('path', 90);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
          (context) => false,
        );
      }
    } catch (e) {
      print("Register Screen:$e");
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Register"))),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            spacing: 20,
            children: [
              GestureDetector(
                onTap: () async {
                  final result = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (result != null) {
                    setState(() {
                      pickFile = File(result.path);
                    });
                  }
                },
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(width: 1.5, color: Colors.black),
                  ),
                  child: pickFile == null
                      ? Text("")
                      : Image(image: FileImage(pickFile!)),
                ),
              ),

              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: firstName,
                      decoration: InputDecoration(
                        labelText: "First Name",
                        hintText: "Enter your first name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: lastName,
                      decoration: InputDecoration(
                        labelText: "Last Name",
                        hintText: "Enter your last name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Enter your email",
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              TextFormField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  hintText: "Confirm Password",
                  labelText: "Confirm Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  registerAccount();
                },
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: loading
                      ? Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : Center(
                          child: Text(
                            "Create account",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                ),
              ),
              SizedBox(height: 50),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text("Login?"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
