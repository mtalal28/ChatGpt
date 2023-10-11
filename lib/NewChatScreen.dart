import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:signin_signup/provider/chats_provider.dart';
import 'package:signin_signup/provider/models_provider.dart';
import 'package:signin_signup/services.dart';
import 'RealTimeDataScreen.dart';
import 'TextWidget.dart';
import 'chatWidget.dart';
import 'constants/constants.dart';
import 'login.dart';
import 'package:firebase_database/firebase_database.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final DatabaseReference _databaseReference =
  FirebaseDatabase.instance.reference().child('chat_messages');

  bool _isTyping = false;

  late TextEditingController textEditingController;
  late ScrollController _listScrollController;
  late FocusNode focusNode;
  late ChatProvider chatProvider; // Declare chatProvider here

  @override
  void initState() {
    _listScrollController = ScrollController();
    textEditingController = TextEditingController();
    focusNode = FocusNode();

    chatProvider = Provider.of<ChatProvider>(context, listen: false); // Initialize chatProvider

    chatProvider.clearChatList();

    _databaseReference.onChildAdded.listen((event) {
      print('New message: ${event.snapshot.value}');
    });

    super.initState();
  }




  @override
  void dispose() {
    _listScrollController.dispose();
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: const Text("ChatGPT"),
        actions: [
          IconButton(
            onPressed: () async {
              await Services.showModalSheet(context: context);
            },
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              // Navigate to the new chat screen here
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NewChatScreen(), // Replace with the actual new chat screen widget
                ),
              );
            },
            icon: const Icon(Icons.add, color: Colors.white), // Plus sign icon
          ),
        ],
      ),

      drawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Color(0xFF444654), // Set the background color here
        ),
        child: Drawer(
          child: Column( // Wrap the contents in a Column
            children: <Widget>[
              Expanded( // Use Expanded to take remaining vertical space
                child: ListView(
                  children: <Widget>[
                    Container(
                      height: 80, // Set the desired height here
                      child: const DrawerHeader(
                        decoration: BoxDecoration(
                          color: Color(0xFF343541),
                        ),
                        child: Center(
                          child: Text(
                            'Chat GPT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20, // Adjust the font size as needed
                            ),
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        'Real-Time Data',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RealTimeDataScreen(),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle logout action here
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyLogin(),
                    ),
                  ); // Replace 'login' with your actual login route
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF343541), // Set the button's background color
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Icon(
                        Icons.logout, // You can change the icon to a logout icon
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                controller: _listScrollController,
                itemCount: chatProvider.chatList.length,
                itemBuilder: (context, index) {
                  return ChatWidget(
                    msg: chatProvider.chatList[index].msg,
                    chatIndex: chatProvider.chatList[index].chatIndex,
                  );
                },
              ),
            ),
            if (_isTyping) ...[
              const SpinKitThreeBounce(
                color: Colors.white,
                size: 18,
              ),
            ],
            const SizedBox(
              height: 15,
            ),
            Material(
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        focusNode: focusNode,
                        style: const TextStyle(color: Colors.white),
                        controller: textEditingController,
                        onSubmitted: (value) async {
                          await sendMessageFCT(
                            modelsProvider: modelsProvider,
                            chatProvider: chatProvider,
                            databaseReference: _databaseReference, // Pass the database reference here
                          );
                        },
                        decoration: const InputDecoration.collapsed(
                            hintText: "How can I help you",
                            hintStyle: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await sendMessageFCT(
                          modelsProvider: modelsProvider,
                          chatProvider: chatProvider,
                          databaseReference: _databaseReference, // Pass the database reference here
                        );
                      },
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    )

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void scrollListToEND() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.easeOut);
  }

  Future<void> sendMessageFCT({
    required ModelsProvider modelsProvider,
    required ChatProvider chatProvider,
    required DatabaseReference databaseReference, // Pass the database reference here
  }) async {    if (_isTyping) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: TextWidget(
          label: "You can't send multiple messages at a time",
        ),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }
  if (textEditingController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: TextWidget(
          label: "Please type a message",
        ),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }
  try {
    String msg = textEditingController.text;
    setState(() {
      _isTyping = true;
      chatProvider.addUserMessage(msg: msg);
      textEditingController.clear();
      focusNode.unfocus();
    });

    final chatGptResponse = await chatProvider.sendMessageAndGetAnswers(
      msg: msg,
      chosenModelId: modelsProvider.getCurrentModel,
      databaseReference: databaseReference, // Pass the reference here
    );

// Debugging: Print the AI response
    print('AI Response: $chatGptResponse');

    // Store the chat message in Firebase Realtime Database
    try {
      await _databaseReference.push().set({
        'message': msg,
        'response': chatGptResponse,
        'timestamp': ServerValue.timestamp,
      });
      print('Data written to Firebase successfully');
    } catch (error) {
      print('Firebase database error: $error');
    }
    setState(() {});
  } catch (error) {
    log("error $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: TextWidget(
          label: error.toString(),
        ),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    setState(() {
      scrollListToEND();
      _isTyping = false;
    });
  }
  }

}




// Future<void> sendMessageFCT(
//     {required ModelsProvider modelsProvider,
//       required ChatProvider chatProvider}) async {
//   if (_isTyping) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: TextWidget(
//           label: "You cant send multiple messages at a time",
//         ),
//         backgroundColor: Colors.red,
//       ),
//     );
//     return;
//   }
//   if (textEditingController.text.isEmpty) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: TextWidget(
//           label: "Please type a message",
//         ),
//         backgroundColor: Colors.red,
//       ),
//     );
//     return;
//   }
//   try {
//     String msg = textEditingController.text;
//     setState(() {
//       _isTyping = true;
//       // chatList.add(ChatModel(msg: textEditingController.text, chatIndex: 0));
//       chatProvider.addUserMessage(msg: msg);
//       textEditingController.clear();
//       focusNode.unfocus();
//     });
//     await chatProvider.sendMessageAndGetAnswers(
//         msg: msg,
//         chosenModelId: modelsProvider.getCurrentModel);
//     // chatList.addAll(await ApiService.sendMessage(
//     //   message: textEditingController.text,
//     //   modelId: modelsProvider.getCurrentModel,
//     // ));
//     setState(() {});
//   } catch (error) {
//     log("error $error");
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: TextWidget(
//         label: error.toString(),
//       ),
//       backgroundColor: Colors.red,
//     ));
//   } finally {
//     setState(() {
//       scrollListToEND();
//       _isTyping = false;
//     });
//   }
// }
// }






