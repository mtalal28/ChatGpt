import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class RealTimeDataScreen extends StatefulWidget {
  const RealTimeDataScreen({super.key});

  @override
  _RealTimeDataScreenState createState() => _RealTimeDataScreenState(chatIdentifier: '');
}

class _RealTimeDataScreenState extends State<RealTimeDataScreen> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.reference().child('chat_messages'); // Replace with your database reference

  final String chatIdentifier; // Add a chat identifier

  List<String> data = [];

  _RealTimeDataScreenState({required this.chatIdentifier});

  @override
  void initState() {
    super.initState();
    _loadDataFromDatabase();
  }

  Future<void> _loadDataFromDatabase() async {
    // Listen for real-time updates when data changes for the specific chat identifier
    _databaseReference.child(chatIdentifier).onValue.listen((event) {
      final Map<dynamic, dynamic>? dataMap = event.snapshot.value as Map?;
      if (dataMap != null) {
        setState(() {
          // Extract and display the data
          data = dataMap.entries
              .map((entry) => "${entry.value['message']} - ${entry.value['response']}")
              .toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Real-Time Data Screen'),
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              data[index],
              style: TextStyle(
                color: Colors.white, // Set text color to white
              ),
            ),
          );
        },
      ),
    );
  }
}

