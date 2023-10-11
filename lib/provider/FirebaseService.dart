

import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final _database = FirebaseDatabase.instance.reference();

  Future<void> addChatMessage(String userMessage, String openaiResponse) async {
    await _database.child('chat_messages').push().set({
      'user_message': userMessage,
      'openai_response': openaiResponse,
      'timestamp': ServerValue.timestamp,
    });
  }

  Stream<DatabaseEvent> getChatMessages() {
    return _database.child('chat_messages').onValue;
  }
}
