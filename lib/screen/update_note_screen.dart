import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateNoteScreen extends StatefulWidget {
  final Map<String, dynamic> note;
  const UpdateNoteScreen({super.key, required this.note});

  @override
  State<UpdateNoteScreen> createState() => _UpdateNoteScreenState();
}

class _UpdateNoteScreenState extends State<UpdateNoteScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool loading = false;

  Future<void> updateNote() async {
    setState(() {
      loading = true;
    });
    try {
      await supabase
          .from('Notes')
          .update({
            'title': titleController.text,
            'description': descriptionController.text,
          })
          .eq('id', widget.note['id']);
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
    descriptionController.text = widget.note['description'];
    titleController.text = widget.note['title'];
    super.initState();
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
                updateNote();
              },
              child: Center(
                child: loading
                    ? CircularProgressIndicator(color: Colors.blueAccent)
                    : Text("Update"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
