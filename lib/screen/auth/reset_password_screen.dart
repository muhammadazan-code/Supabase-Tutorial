import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_tutorial/screen/auth/login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  Future<void> updatePassword() async {
    try {
      if (_formKey.currentState!.validate()) {
        await supabase.auth.updateUser(
          UserAttributes(password: newPasswordController.text),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text("Reset Password")),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 20,
              children: [
                TextFormField(
                  controller: newPasswordController,
                  decoration: InputDecoration(
                    hintText: "Enter your new password",
                    labelText: "New Password",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter new password";
                    } else if (value.length <= 7) {
                      return "Password must contains 8 characters";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    hintText: "Enter confirm password",
                    labelText: "Confirm Password",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      if (!value!.contains(newPasswordController.text)) {
                        return "Password must be same";
                      }
                      return "Please enter new password";
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: () => updatePassword(),
                  child: Center(child: Text("Reset password")),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
