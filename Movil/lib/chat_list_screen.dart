import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'services/api_service.dart';
import 'models/data_model.dart';

class ChatListScreen extends StatefulWidget {
  final String currentUserId;

  ChatListScreen({required this.currentUserId, required List<Map<String, dynamic>> matches});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _conversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      List<Map<String, dynamic>> conversations =
    List<Map<String, dynamic>>.from(await _apiService.getConversacionesByUserId(widget.currentUserId));
      setState(() {
        _conversations = conversations;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar conversaciones: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        backgroundColor: Colors.brown[700],
      ),
      body: _conversations.isEmpty
          ? Center(child: Text('No tienes conversaciones aún.'))
          : ListView.builder(
              itemCount: _conversations.length,
              itemBuilder: (context, index) {
                final conversation = _conversations[index];
                final chatId = conversation['idConversacion'];
                final matchUserName = conversation['nombre'];
                final matchUserId = conversation['idUsuario'];

                return ListTile(
                  title: Text(matchUserName ?? 'Usuario desconocido'),
                  subtitle: Text('Tap para chatear'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          currentUserId: widget.currentUserId,
                          matchUserId: matchUserId,
                          chatId: chatId, // Pasamos el id de la conversación
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
