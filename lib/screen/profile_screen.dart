import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Profile"))),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: supabase
              .from("users")
              .select()
              .eq('user_id', supabase.auth.currentUser!.id)
              .single(),
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
                CircleAvatar(
                  child: Image.network(
                    user['profile_picture'],
                    fit: BoxFit.cover,
                  ),
                ),
                ListTile(
                  title: Text("Name"),
                  trailing: Text("${user['First Name']} ${user['Last Name']}"),
                ),
                ListTile(
                  title: Text("Email"),
                  trailing: Text("${user['email']}"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
