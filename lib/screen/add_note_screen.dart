import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_tutorial/screen/home_screen.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool loading = false;
  Future<void> addNote() async {
    setState(() {
      loading = true;
    });
    try {
      await supabase
          .from('notes')
          .insert({
            'title': titleController.text,
            'description': descriptionController.text,
            'user_id': supabase.auth.currentUser!.id,
          })
          .then((value) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Add Note"))),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter title",
                labelText: "Title",
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter discription",
                labelText: "Description",
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                addNote();
              },
              child: Center(
                child: loading
                    ? CircularProgressIndicator(color: Colors.blueAccent)
                    : Text("Add Note"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
