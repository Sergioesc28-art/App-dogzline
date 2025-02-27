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
          final match = matches[index];
          final matchUserId = match['idUsuario'];
          final matchUserName = match['nombre'];

          return ListTile(
            title: Text(matchUserName ?? 'Usuario desconocido'),
            subtitle: Text('Tap to chat'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    currentUserId: currentUserId,
                    matchUserId: matchUserId,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}