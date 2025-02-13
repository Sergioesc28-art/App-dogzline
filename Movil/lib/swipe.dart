import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeCards();
  }

  Future<List<Map<String, dynamic>>> generateDogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token no encontrado');
      }

      final response = await Dio().get(
        'https://dogzline-1.onrender.com/api/mascotas',
        queryParameters: {
          'page': 1,
          'limit': 10,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> dogs = (response.data['mascotas'] as List)
            .map((json) => {
                  "name": json['name'],
                  "age": "${json['age']} años",
                  "image": json['image'],
                })
            .toList();
        return dogs;
      } else {
        throw Exception('Error al obtener las mascotas');
      }
    } catch (e) {
      throw Exception('Error al obtener las mascotas: $e');
    }
  }

  void _initializeCards() async {
    List<Map<String, dynamic>> dogs = await generateDogs();
    _swipeItems = dogs.map((profile) {
      return SwipeItem(
        content: profile,
        likeAction: () => _showAction("LIKE ❤️", Colors.green),
        nopeAction: () => _showAction("DISLIKE ❌", Colors.red),
      );
    }).toList();

    _matchEngine = MatchEngine(swipeItems: _swipeItems);
    setState(() {});
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
    return Card(
      child: Column(
        children: [
          Image.network(profile['image']),
          Text(profile['name']),
          Text(profile['age']),
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
                child: SwipeCards(
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