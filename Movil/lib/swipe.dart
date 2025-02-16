import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Importa dart:convert para usar base64Decode
import 'dart:typed_data'; // Importa dart:typed_data para usar Uint8List
import 'models/data_model.dart';
import 'services/api_service.dart';

void main() {
  runApp(DogzlineApp());
}

class DogzlineApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.orange,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: MatchScreen(),
    );
  }
}

class MatchScreen extends StatefulWidget {
  @override
  _MatchScreenState createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  late MatchEngine _matchEngine;
  List<SwipeItem> _swipeItems = [];
  String _actionText = "";
  Color _actionColor = Colors.transparent;
  double _opacity = 0.0;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _initializeCards();
  }

  Future<void> _initializeCards() async {
    List<Map<String, dynamic>> dogs = await generateDogs();
    _swipeItems = dogs.map((profile) {
      return SwipeItem(
        content: profile,
        likeAction: () => _showAction("LIKE ❤️", Colors.green),
        nopeAction: () => _showAction("DISLIKE ❌", Colors.red),
      );
    }).toList();

    setState(() {
      _matchEngine = MatchEngine(swipeItems: _swipeItems);
    });
  }

  Future<List<Map<String, dynamic>>> generateDogs() async {
    try {
      List<Data> dogs = await _apiService.getDogs(page: 1, limit: 10);
      return dogs.map((dog) {
        String base64Image = dog.fotos.split(',').last;
        return {
          'image': base64Image,
          'name': dog.nombre,
          'age': dog.edad.toString(),
        };
      }).toList();
    } catch (e) {
      print('Error fetching dogs: $e');
      return [];
    }
  }

  void _showAction(String action, Color color) {
    setState(() {
      _actionText = action;
      _actionColor = color;
      _opacity = 1.0;
    });

    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _actionText = "";
        _actionColor = Colors.transparent;
        _opacity = 0.0;
      });
    });
  }

  Widget buildProfileCard(Map<String, dynamic> profile) {
    Uint8List? imageBytes;
    try {
      imageBytes = base64Decode(profile['image'] ?? '');
    } catch (e) {
      print('Error decoding base64 image: $e');
    }

    return Card(
      child: Column(
        children: [
          imageBytes != null
              ? Image.memory(imageBytes)
              : Text('Imagen no disponible'),
          Text(profile['name'] ?? 'Nombre no disponible'),
          Text(profile['age'] ?? 'Edad no disponible'),
        ],
      ),
    );
  }

  Widget buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () => _matchEngine.currentItem?.nope(),
          child: Text("DISLIKE"),
        ),
        ElevatedButton(
          onPressed: () => _matchEngine.currentItem?.like(),
          child: Text("LIKE"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dogzline", style: GoogleFonts.pacifico(fontSize: 28)),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              Expanded(
                child: _swipeItems.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : SwipeCards(
                        matchEngine: _matchEngine,
                        itemBuilder: (context, index) {
                          final profile = _swipeItems[index].content;
                          return buildProfileCard(profile);
                        },
                        onStackFinished: () {
                          setState(() {
                            _initializeCards();
                          });
                        },
                      ),
              ),
              buildActionButtons(),
            ],
          ),
          Positioned(
            top: 200,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 200),
              opacity: _opacity,
              child: Text(
                _actionText,
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: _actionColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}