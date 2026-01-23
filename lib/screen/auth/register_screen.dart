import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_tutorial/screen/auth/login_screen.dart';

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
  // XFile? pickFile;
  Uint8List? image;

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
        final path = 'users/${supabase.auth.currentUser?.id}';
        await supabase.storage
            .from('Bucket 1')
            .uploadBinary(
              path,
              image!,
              fileOptions: FileOptions(contentType: 'image/png'),
            );
        final url = supabase.storage.from("Bucket 1").getPublicUrl(path);
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
          MaterialPageRoute(builder: (context) => LoginScreen()),
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

  Future<void> storeFilesForWeb() async {
    try {} catch (e) {
      print("Error: $e");
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
                  print("Result: $result");
                  if (result != null) {
                    final bytes = await result.readAsBytes();
                    setState(() {
                      image = bytes;
                    });
                  }
                },
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1.2),
                    borderRadius: BorderRadius.circular(50),
                    // color: const Color.fromARGB(255, 126, 135, 140),
                  ),
                  child: Center(
                    child: image != null
                        ? Image(image: MemoryImage(image!))
                        : Icon(Icons.person),
                  ),
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
