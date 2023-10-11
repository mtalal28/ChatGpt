import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

import '../api.dart';
import '../chat_model.dart';



class ChatProvider with ChangeNotifier {
  List<ChatModel> chatList = [];
  String openAIResponse = '';

  void addUserMessage({required String msg}) {
    chatList.add(ChatModel(msg: msg, chatIndex: 0));
    notifyListeners();
  }

  void addOpenAIResponse({required String msg}) {
    openAIResponse = msg;
    notifyListeners();
  }

  // Define the clearChatList method to clear the chat list
  void clearChatList() {
    chatList.clear();
    notifyListeners();
  }

  Future<String> sendMessageAndGetAnswers({
    required String msg,
    required String chosenModelId,
    required DatabaseReference databaseReference,
  }) async {
    try {
      if (chosenModelId.toLowerCase().startsWith("gpt")) {
        chatList.addAll(await Api.sendMessageGPT(
          message: msg,
          modelId: chosenModelId,
        ));
      } else {
        chatList.addAll(await Api.sendMessage(
          message: msg,
          modelId: chosenModelId,
        ));
      }

      // Now, perform the Firebase Realtime Database write operation
      await databaseReference.push().set({
        'message': msg,
        'response': chatList.isNotEmpty ? chatList.last.msg : '', // Return the last response if chatList is not empty
        'timestamp': ServerValue.timestamp,
      });

      notifyListeners();

      // Return the GPT response (last message) or an empty string if chatList is empty
      return chatList.isNotEmpty ? chatList.last.msg : '';
    } catch (error) {
      // Handle any errors that occur during the write operation
      log("error $error");
      return 'Error: $error';
    }
  }

}
