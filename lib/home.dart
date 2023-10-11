import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:signin_signup/chatScreen.dart';
import 'package:signin_signup/constants/constants.dart';
import 'package:signin_signup/provider/chats_provider.dart';
import 'package:signin_signup/provider/models_provider.dart';



class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  Future<void> logout() async {
    final GoogleSignIn googleSign = GoogleSignIn();
    await googleSign.signOut();
  }

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ModelsProvider(),
        ),
        ChangeNotifierProvider(
          create:(_)=>ChatProvider(),
        ),
      ],
      child: MaterialApp(
        title: widget.title, // Use the provided title
        theme: ThemeData(
          scaffoldBackgroundColor: scaffoldBackgroundColor,
          appBarTheme: AppBarTheme(
            color: cardColor,
          ),
        ),
        home: const ChatScreen(),
      ),
    );
  }
}














// body: Column(
// children: [
// Container(
// padding: const EdgeInsets.only(left: 35, top: 130),
// child: const Text(
// 'hey what''s up',
// style: TextStyle(color: Colors.black, fontSize: 33),
// ),
// ),
// ElevatedButton(
// child: const Text('Logout'),
// onPressed: () {
// Navigator.pushNamed(context, 'login');
// },
// ),
// ],
// ),