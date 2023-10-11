import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:signin_signup/home.dart';
import 'package:signin_signup/login.dart';
import 'package:signin_signup/register.dart';
import 'package:signin_signup/forget.dart';
import 'package:signin_signup/chatScreen.dart';
import 'package:signin_signup/RealTimeDataScreen.dart';

import 'NewChatScreen.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'login',
      routes: {
        'login': (context) => const MyLogin(),
        'register': (context) => const MyRegister(),
        '/home': (context) => const MyHomePage(title:'chat gpt'),
        'ChatScreen': ( context)=> const ChatScreen(),
        'forget': (context) => const MyForget(),
        'RealTimeDataScreen':(context)=> const RealTimeDataScreen(),
        'NewChatScreen':(context)=>const NewChatScreen(),
      },
    );
  }
}
