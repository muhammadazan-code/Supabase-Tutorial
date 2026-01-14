import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_tutorial/screen/add_note_screen.dart';
import 'package:supabase_tutorial/screen/login_screen.dart';
import 'package:supabase_tutorial/screen/update_note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Home")),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () async {
                  await supabase.auth.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (context) => false,
                  );
                },
                child: Center(child: Text("Logout")),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder(
        stream: supabase.from('Notes').stream(primaryKey: ['id']),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.none) {
            return Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            );
          }
          List<Map<String, dynamic>> notes = snapshot.data ?? [];
          return ListView(
            children: [
              for (var data in notes)
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateNoteScreen(note: data),
                      ),
                    );
                  },
                  title: Text(data['title']),
                  subtitle: Text(data['description']),
                  trailing: IconButton(
                    onPressed: () async {
                      print("Delete Method called");
                      await supabase
                          .from("Notes")
                          .delete()
                          .eq('id', data['id'])
                          .then((value) {})
                          .onError((error, stackTrace) {
                            print("Stack Trace $stackTrace");
                            print("Error $error");
                          });
                    },
                    icon: Icon(Icons.delete, color: Colors.red),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => AddNoteScreen()),
            (context) => false,
          );
        },
        child: Center(child: Icon(Icons.add)),
      ),
    );
  }
}
