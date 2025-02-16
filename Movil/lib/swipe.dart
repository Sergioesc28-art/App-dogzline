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
        primaryColor: Colors.brown[700],
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
  int _selectedIndex = 0;

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
        queryParameters: {'page': 1, 'limit': 10},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> dogs = (response.data['mascotas'] as List)
            .map((json) => {
                  "name": json['name'] ?? "Nombre desconocido",
                  "age": json['age'] != null ? "${json['age']} años" : "Edad desconocida",
                  "image": json['image'] ?? "https://via.placeholder.com/150"
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(profile['image'], height: 300, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(profile['name'], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text(profile['age'], style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton(
          heroTag: "dislike",
          onPressed: () => _matchEngine.currentItem?.nope(),
          backgroundColor: Colors.red,
          child: Icon(Icons.close, size: 32, color: Colors.white),
        ),
        SizedBox(width: 30),
        FloatingActionButton(
          heroTag: "like",
          onPressed: () => _matchEngine.currentItem?.like(),
          backgroundColor: Colors.green,
          child: Icon(Icons.favorite, size: 32, color: Colors.white),
        ),
      ],
    );
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Aquí puedes agregar navegación a diferentes pantallas si lo deseas
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dogzline", style: GoogleFonts.pacifico(fontSize: 28)),
        centerTitle: true,
        backgroundColor: Colors.brown[700],
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
              SizedBox(height: 10),
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.brown[700],
        selectedItemColor: Colors.orangeAccent,
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onNavBarTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: "Mascotas",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Matches",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Perfil",
          ),
        ],
      ),
    );
  }
}
