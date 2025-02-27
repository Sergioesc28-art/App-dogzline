import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'models/message_model.dart'; // Importa message_model.dart

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String matchUserId;

  ChatScreen({required this.currentUserId, required this.matchUserId});

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
      List<Message> mensajes = await _apiService.obtenerMensajes(widget.matchUserId);
      setState(() {
        _messages.addAll(mensajes);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los mensajes: $e')),
      );
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
      await _apiService.guardarMensaje(widget.matchUserId, widget.currentUserId, message.content);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar el mensaje: $e')),
      );
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
                      message.timestamp.toLocal().toString(),
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