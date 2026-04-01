import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService
{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send a message
  Future<void> sendMessage(String chatId, String senderId, String message) async
  {
    try
    {
      await _firestore.collection('chats').doc(chatId).collection('messages').add({
        'senderId': senderId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  Future<void> deleteMessage(String chatId, String messageId) async
  {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      print("Error deleting message: $e");
    }
  }


  // Stream chat messages
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

}
