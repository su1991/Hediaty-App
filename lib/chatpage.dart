import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'chatservice.dart';
import 'controlles/pledgedcontroller.dart';
import 'models/eventlistmodel.dart'; // Event model
import 'models/giftdetailsmodel.dart';
import 'models/mainmodel.dart';
import 'models/pledgedmodel.dart'; // Import Event model

class ChatPage extends StatefulWidget
{
  final String friendId;
  final String friendName;
  final String currentUserId;

  const ChatPage({
    super.key,
    required this.friendId,
    required this.friendName,
    required this.currentUserId,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
{
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();

  String get chatId
  {
    print("Current User ID: ${widget.currentUserId}");
    print("Friend ID: ${widget.friendId}");

    if (widget.currentUserId.isEmpty || widget.friendId.isEmpty) {
      print("Error: One of the user IDs is empty!");
      return "error"; // Fallback to prevent incorrect chat ID
    }

    List<String> sortedIds = [widget.currentUserId, widget.friendId]..sort();
    String generatedChatId = "${sortedIds[0]}-${sortedIds[1]}";

    print("Generated Chat ID: $generatedChatId");
    return generatedChatId;
  }



  void _deleteMessage(String messageId)
  {
    _chatService.deleteMessage(chatId, messageId);
  }
  void _showDeleteDialog(BuildContext context, String messageId) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: const Text("Delete Message", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ListTile(
                title: const Text("Delete"),
                textColor: Colors.red,
                onTap: () {
                  _deleteMessage(messageId);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Cancel"),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }





  void _sendMessage()
  {
    if (_messageController.text.isNotEmpty)
    {
      _chatService.sendMessage(chatId, widget.currentUserId, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar(
        title: Text(' ${widget.friendName}'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Flexible(
            child: StreamBuilder(
              stream: _chatService.getMessages(chatId),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No messages yet."));
                }

                return ListView(
                  reverse: true,
                  children: snapshot.data!.docs.map((doc) {
                    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                    bool isMe = data['senderId'] == widget.currentUserId;
                    String messageId = doc.id;
                    return Align
                      (
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.5, // ✅ Limit width
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.green[700] : Colors.lightBlue[500],
                          borderRadius: BorderRadius.circular(10),
                        ),
                    child: IntrinsicHeight(
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // ✅ Prevents full-width expansion
                          crossAxisAlignment: CrossAxisAlignment.center, // ✅ Keeps delete icon aligned
                          children: [
                            Flexible(
                              child: Text(
                                data['message'],
                                softWrap: true, // ✅ Allows wrapping
                              ),
                            ),
                            if (isMe) // ✅ Show delete icon only for sender
                              IconButton(
                                icon: const Icon(Icons.arrow_drop_down, color: Colors.white30),
                                onPressed: ()=>_showDeleteDialog(context, messageId),

                                constraints: const BoxConstraints(), // ✅ Prevents extra padding
                                padding: EdgeInsets.zero, // ✅ Removes extra padding
                              ),
                          ],
                        ),
                      ),
                    ) );

                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Chat here!',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

