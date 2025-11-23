import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore;

  ChatService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  // Generate a unique chat room ID for two users
  String getChatRoomId(String userId, String otherUserId) {
    if (userId.compareTo(otherUserId) > 0) {
      return '$userId-$otherUserId';
    } else {
      return '$otherUserId-$userId';
    }
  }

  Future<void> sendMessage(String senderId, String receiverId, String text) async {
    final chatRoomId = getChatRoomId(senderId, receiverId);
    final message = Message(
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      timestamp: Timestamp.now(),
    );

    final chatRoomDoc = _firestore.collection('chat_rooms').doc(chatRoomId);

    // Add the message to the messages subcollection
    await chatRoomDoc.collection('messages').add(message.toMap());

    // Update the chat room document with the latest message for previews
    await chatRoomDoc.set({
      'lastMessage': message.toMap(),
      'participants': [senderId, receiverId],
    }, SetOptions(merge: true));
  }

  Stream<List<Message>> getChatStream(String userId, String otherUserId) {
    final chatRoomId = getChatRoomId(userId, otherUserId);
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList();
        });
  }
}
