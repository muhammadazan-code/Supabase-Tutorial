import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_tutorial/screen/edit_screen.dart';

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
            return Column(
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
                      image: NetworkImage(user['profile_picture']),
                    ),
                  ),
                ),
                ListTile(
                  title: Text("Name"),
                  trailing: Text(
                    "${user['First Name'] ?? ""} ${user['Last Name'] ?? ""}",
                  ),
                ),
                ListTile(
                  title: Text("Email"),
                  trailing: Text("${user['email'] ?? ""}"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
