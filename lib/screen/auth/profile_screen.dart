import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_tutorial/screen/auth/change_password_screen.dart';
import 'package:supabase_tutorial/screen/notes/edit_screen.dart';
import 'package:supabase_tutorial/screen/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic> userData = {};

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
          // future: fetchDataFromDatabase(),
          future: supabase
              .from("users")
              .select('''
first_name, last_name, email, profile_picture, address:addresses(city, street, postal_code, country)
''')
              .eq('user_id', supabase.auth.currentUser!.id)
              .single(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.none ||
                snapshot.data == null) {
              return Center(
                child: CircularProgressIndicator(color: Colors.blue),
              );
            }
            final user = snapshot.data ?? {};
            print("User: $user");
            return Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue.shade200,
                  backgroundImage: NetworkImage(user['profile_picture']),
                ),
                ListTile(
                  title: Text("Name"),
                  trailing: Text(
                    "${user['first_name'] ?? ''}${user['last_name'] ?? ''}",
                  ),
                ),
                ListTile(
                  title: Text("Email"),
                  trailing: Text("${user['email'] ?? ""}"),
                ),
                ListTile(
                  title: Text("Street"),
                  trailing: Text("${user['address'][0]['street'] ?? ""}"),
                ),
                ListTile(
                  title: Text("City"),
                  trailing: Text("${user['address'][0]['city'] ?? ""}"),
                ),
                ListTile(
                  title: Text("Postal Code"),
                  trailing: Text("${user['address'][0]['postal_code'] ?? ""}"),
                ),
                ListTile(
                  title: Text("Country"),
                  trailing: Text("${user['address'][0]['country'] ?? ""}"),
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
