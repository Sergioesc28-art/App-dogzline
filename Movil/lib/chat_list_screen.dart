import 'package:flutter/material.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  final String currentUserId;
  final List<Map<String, dynamic>> matches;

  ChatListScreen({required this.currentUserId, required this.matches});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        backgroundColor: Colors.brown[700],
      ),
      body: ListView.builder(
        itemCount: matches.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(''), // Dejar en blanco
            subtitle: Text(''), // Dejar en blanco
          );
        },
      ),
    );
  }
}