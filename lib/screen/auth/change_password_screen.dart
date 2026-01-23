import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final supabase = Supabase.instance.client;
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> getToken() async {
    try {
      if (_formKey.currentState!.validate()) {
        final user = supabase.auth.currentUser;
        final currentEmail = user?.email;

        final result = await supabase.auth.signInWithPassword(
          email: currentEmail,
          password: currentPasswordController.text,
        );
        if (result.user != null) {
          await supabase.auth.updateUser(
            UserAttributes(password: newPassword.text),
          );
          Navigator.pop(context);
        }
      }
    } on AuthApiException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a correct password.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        title: Center(
          child: Text(
            "Change Password",
            style: GoogleFonts.sacramento(color: Colors.white),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 20,
              children: [
                TextFormField(
                  controller: currentPasswordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter current password';
                    } else if (value.length < 7) {
                      return 'Password contains at least 8 characters.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter your old password",
                    labelText: 'Old Password',
                    hintStyle: GoogleFonts.sacramento(),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: newPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter new password';
                    } else if (value.length < 7) {
                      return 'Password contains at lease 8 characters.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter your new password",
                    labelText: 'New Password',
                    hintStyle: GoogleFonts.sacramento(),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: confirmPassword,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Confirm password",
                    labelText: 'Confirm Password',
                    hintStyle: GoogleFonts.sacramento(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter confirm password";
                    } else if (newPassword.text.isNotEmpty) {
                      if (!value.contains(newPassword.text)) {
                        return "Password is not same.";
                      }
                    }
                    return null;
                  },
                ),
                SizedBox(height: 50),
                GestureDetector(
                  onTap: () => getToken(),
                  child: Container(
                    height: 50,
                    width: 200,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        "Password changes",
                        style: GoogleFonts.sacramento(fontSize: 30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
