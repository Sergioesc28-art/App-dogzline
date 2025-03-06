import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'models/data_model.dart'; 

// Asegúrate de que Message esté definido en data_model.dart
class Message {
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
  });

  // Método para convertir JSON a objeto Message
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderId: json['id_emisor'] ?? '',
      receiverId: json['id_receptor'] ?? '',
      content: json['contenido'] ?? '',
      timestamp: json['fecha_creacion'] != null 
                ? DateTime.parse(json['fecha_creacion']) 
                : DateTime.now(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String matchUserId;
  final String chatId; // ID de la conversación

  ChatScreen({
    required this.currentUserId,
    required this.matchUserId,
    required this.chatId,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      List<dynamic> mensajesData = await _apiService.getMensajesByConversacion(widget.chatId); // Cambiado conversacionId a chatId
      
      setState(() {
        _messages.clear();
        // Convertir los datos a objetos Message
        for (var json in mensajesData) {
          _messages.add(Message.fromJson(json));
        }
        // Ordenar mensajes por timestamp
        _messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar los mensajes: $e')),
        );
      }
    }
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final message = Message(
      senderId: widget.currentUserId,
      receiverId: widget.matchUserId,
      content: _controller.text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(message);
    });

    _controller.clear();

    try {
      // Crear el objeto de datos del mensaje
      Map<String, dynamic> mensajeData = {
        'id_conversacion': widget.chatId,
        'id_emisor': widget.currentUserId,
        'id_receptor': widget.matchUserId,
        'contenido': message.content,
      };
      
      // Llamar al método correcto en ApiService
      await _apiService.createMensaje(mensajeData);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar el mensaje: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        backgroundColor: Colors.brown[700],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.senderId == widget.currentUserId;
                return ListTile(
                  title: Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.brown[100] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(message.content),
                    ),
                  ),
                  subtitle: Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Text(
                      message.timestamp.toLocal().toString().substring(0, 16), // Formato más corto para timestamp
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}