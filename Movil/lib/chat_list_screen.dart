import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'services/api_service.dart';
import 'models/data_model.dart';

class ChatListScreen extends StatefulWidget {
  final String currentUserId;
  final List<Map<String, dynamic>> matches;

  ChatListScreen({required this.currentUserId, required this.matches});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ApiService _apiService = ApiService();
  List<Conversacion> _conversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      List<Map<String, dynamic>> conversationsData =
          await _apiService.getConversacionesByUserId(widget.currentUserId);
      print("Conversaciones cargadas: $conversationsData");
      setState(() {
        _conversations = conversationsData.map((data) => Conversacion.fromJson(data)).toList();
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
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: _conversations.isEmpty
          ? Center(child: Text('No tienes conversaciones aún.'))
          : ListView.builder(
              itemCount: _conversations.length,
              itemBuilder: (context, index) {
                final conversation = _conversations[index];
                final chatId = conversation.id;
                final matchUserName = conversation.ultimoMensaje ?? 'Usuario desconocido';
                final participantes = conversation.participantes;
                
                // Verificar que participantes sea una lista
                if (participantes is List<String>) {
                  final matchUserId = participantes.firstWhere(
                    (id) => id != widget.currentUserId,
                    orElse: () => '',
                  );

                  return ListTile(
                    title: Text(matchUserName),
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
                } else {
                  return ListTile(
                    title: Text('Error en los datos de la conversación'),
                    subtitle: Text('Tap para chatear'),
                  );
                }
              },
            ),
    );
  }
}