import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final supabase = Supabase.instance.client;
  RealtimeChannel? channel;
  final messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  void listenBroadCast() {
    channel = supabase.channel(
      'room1',
      opts: RealtimeChannelConfig(self: true),
    );
    channel?.onBroadcast(
      event: 'event1',
      callback: (payload) {
        print('Payload: $payload');
        setState(() {
          messages.add(payload);
        });
      },
    );
    channel?.onPresenceSync((payload) {
      print("Payload: $payload");
    });
    channel?.subscribe();
  }

  Future<void> sendMessage() async {
    String text = messageController.text;
    messageController.clear();
    ChannelResponse? channelResponse = await channel?.sendBroadcastMessage(
      event: 'event1',
      payload: {'text': text, 'user_id': supabase.auth.currentUser?.id},
    );
    print("Message status: ${channelResponse?.name}");
  }

  @override
  void initState() {
    listenBroadCast();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  for (var message in messages)
                    Align(
                      alignment:
                          message['user_id'] == supabase.auth.currentUser?.id
                          ? AlignmentGeometry.centerRight
                          : AlignmentGeometry.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 200),
                        padding: EdgeInsets.all(15),
                        margin: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color:
                              message['user_id'] ==
                                  supabase.auth.currentUser?.id
                              ? Colors.black
                              : Colors.green,
                        ),
                        child: Text(
                          message['text'],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(hintText: "Type your message"),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    sendMessage();
                  },
                  icon: Center(child: Icon(Icons.send, color: Colors.green)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
