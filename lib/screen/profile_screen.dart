import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_tutorial/screen/change_password_screen.dart';
import 'package:supabase_tutorial/screen/edit_screen.dart';
import 'package:supabase_tutorial/screen/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic> userData = {};

  Future<Map<String, dynamic>> fetchDataFromDatabase() async {
    try {
      final result = await supabase
          .from("users")
          .select()
          .eq('user_id', supabase.auth.currentUser!.id)
          .single();
      setState(() {
        userData = result;
      });
      return result;
    } catch (e) {
      print("Error");
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Profile")),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditScreen(notes: userData),
                ),
              );
            },
            child: Center(child: Text("edit")),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: fetchDataFromDatabase(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.none ||
                snapshot.data == null) {
              return Center(
                child: CircularProgressIndicator(color: Colors.blue),
              );
            }
            final Map<String, dynamic> user = snapshot.data ?? {};
            final String firstName = user['First Name'] ?? '';
            final String lastName = user['Last Name'] ?? '';
            final String profilePicture = user['profile_picture'];

            return Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue.shade200,
                  backgroundImage: NetworkImage(profilePicture),
                ),
                ListTile(
                  title: Text("Name"),
                  trailing: Text("$firstName $lastName"),
                ),
                ListTile(
                  title: Text("Email"),
                  trailing: Text("${user['email'] ?? ""}"),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (contex) => ChangePasswordScreen(),
                    ),
                  ),
                  child: Container(
                    height: 50,
                    width: 200,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "Change Password",
                        style: GoogleFonts.sacramento(fontSize: 30),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    try {
                      await supabase.auth.signOut();
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    } catch (e) {
                      print('Error: $e');
                    }
                  },
                  child: Container(
                    height: 50,
                    width: 200,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "Logout",
                        style: GoogleFonts.sacramento(fontSize: 30),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
