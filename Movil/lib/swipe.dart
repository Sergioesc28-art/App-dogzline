import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:google_fonts/google_fonts.dart';

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

  List<Map<String, dynamic>> generateDogs() {
    return List.generate(10, (index) => {
          "name": "Perrito ${index + 1}",
          "age": "${(index % 10) + 1} años",
          "image": "https://placedog.net/500?random=${index + DateTime.now().millisecondsSinceEpoch}",
        });
  }

  @override
  void initState() {
    super.initState();
    _initializeCards();
  }

  void _initializeCards() {
    _swipeItems = generateDogs().map((profile) {
      return SwipeItem(
        content: profile,
        likeAction: () => _showAction("LIKE ❤️", Colors.green),
        nopeAction: () => _showAction("DISLIKE ❌", Colors.red),
      );
    }).toList();

    _matchEngine = MatchEngine(swipeItems: _swipeItems);
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

  Widget buildProfileCard(Map<String, dynamic> profile) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(profile['image'], height: 400, fit: BoxFit.cover),
          ),
          SizedBox(height: 10),
          Text(profile['name'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)),
          Text(profile['age'],
              style: TextStyle(fontSize: 18, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: () => _matchEngine.currentItem?.nope(),
            backgroundColor: Colors.red,
            child: Icon(Icons.close, size: 30, color: Colors.white),
          ),
          FloatingActionButton(
            onPressed: () => _matchEngine.currentItem?.like(),
            backgroundColor: Colors.green,
            child: Icon(Icons.favorite, size: 30, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
