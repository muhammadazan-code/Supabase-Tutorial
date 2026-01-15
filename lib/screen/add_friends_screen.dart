import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddFriendsScreen extends StatefulWidget {
  const AddFriendsScreen({super.key});

  @override
  State<AddFriendsScreen> createState() => _AddFriendsScreenState();
}

class _AddFriendsScreenState extends State<AddFriendsScreen> {
  final supabase = Supabase.instance.client;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Add Friends"))),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: StreamBuilder(
          stream: supabase.from('users').stream(primaryKey: ['id']),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: Colors.lightBlue),
              );
            }
            List<Map<String, dynamic>> users = snapshot.data ?? [];
            return ListView(
              children: [
                for (var user in users)
                  Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(20),
                    constraints: BoxConstraints(
                      maxHeight: 300,
                      maxWidth: 300,
                      minHeight: 100,
                      minWidth: 100,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1.5, color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white54,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${user['First Name']} ${user['Last Name']}",
                              style: TextStyle(fontSize: 25),
                            ),
                            Text(
                              "${user['email']}",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black38,
                              ),
                            ),
                            Text(
                              "${user['created_at']}",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black38,
                              ),
                            ),
                            Text(
                              "${user['user_id']}",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black38,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {},
                          child: Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              color: Colors.lightBlueAccent,
                            ),
                            child: Center(
                              child: Text(
                                "Sent Request",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
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
