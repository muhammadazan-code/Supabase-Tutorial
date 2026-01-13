import 'package:flutter/foundation.dart';
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
  List<Map<String, dynamic>> notes = [];
  bool loading = false;

  Future<void> fetchDataFromSupabase() async {
    setState(() {
      loading = true;
    });
    try {
      final result = await supabase.from('Notes').select();
      setState(() {
        notes = result;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error:$e");
      }
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    fetchDataFromSupabase();
    super.initState();
  }

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
      body: loading
          ? Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : Padding(
              padding: EdgeInsets.all(20),
              child: ListView(
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
                          await supabase
                              .from("Notes")
                              .delete()
                              .eq('id', data['id']);
                        },
                        icon: Icon(Icons.delete, color: Colors.red),
                      ),
                    ),
                ],
              ),
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
