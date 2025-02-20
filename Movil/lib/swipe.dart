import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Importa dart:convert para usar base64Decode
import 'dart:typed_data'; // Importa dart:typed_data para usar Uint8List
import 'models/data_model.dart';
import 'services/api_service.dart';
import 'matches_screen.dart'; // Importa el archivo de matches

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

// Importa el archivo de matches

class _MatchScreenState extends State<MatchScreen> {
  late MatchEngine _matchEngine;
  List<SwipeItem> _swipeItems = [];
  String _actionText = "";
  Color _actionColor = Colors.transparent;
  double _opacity = 0.0;
  final ApiService _apiService = ApiService();
  int _currentPage = 1;
  List<Map<String, dynamic>> _likedDogs = [];

  @override
  void initState() {
    super.initState();
    _loadLikedDogs();
    _initializeCards();
  }

  Future<void> _loadLikedDogs() async {
    final prefs = await SharedPreferences.getInstance();
    final likedDogsString = prefs.getString('likedDogs') ?? '[]';
    final List<dynamic> likedDogsList = jsonDecode(likedDogsString);
    setState(() {
      _likedDogs = likedDogsList.cast<Map<String, dynamic>>();
    });
  }

  Future<void> _saveLikedDogs() async {
    final prefs = await SharedPreferences.getInstance();
    final likedDogsString = jsonEncode(_likedDogs);
    await prefs.setString('likedDogs', likedDogsString);
  }

  Future<void> _initializeCards() async {
    List<Map<String, dynamic>> dogs = await generateDogs();
    _swipeItems.addAll(dogs.map((profile) {
      return SwipeItem(
        content: profile,
        likeAction: () {
          _showAction("LIKE ❤️", Colors.green);
          _likedDogs.add(profile);
          _saveLikedDogs();
        },
        nopeAction: () => _showAction("DISLIKE ❌", Colors.red),
      );
    }).toList());

    setState(() {
      _matchEngine = MatchEngine(swipeItems: _swipeItems);
    });
  }

  Future<List<Map<String, dynamic>>> generateDogs() async {
    try {
      List<Data> dogs = await _apiService.getDogs(page: _currentPage, limit: 10);

      return dogs.map((dog) {
        String? base64Image = '';

        if (dog.fotos != null) {
          if (dog.fotos!.startsWith('data:image')) {
            // Si la cadena ya incluye el prefijo, no hacemos nada
            base64Image = dog.fotos;
          } else {
            // Para manejar casos con Binary.createFromBase64
            final regex = RegExp(r"Binary\.createFromBase64\('(.*)',\s*\d+\)");
            final match = regex.firstMatch(dog.fotos!);
            if (match != null) {
              base64Image = 'data:image/png;base64,${match.group(1)}';
            } else {
              print('No se pudo extraer la imagen para el perro: ${dog.nombre}');
            }
          }
        }

        if (base64Image!.isEmpty) {
          print('No se pudo obtener la imagen para el perro: ${dog.nombre}');
        }

        return {
          'image': base64Image,
          'name': dog.nombre,
          'age': dog.edad.toString(),
          'raza': dog.raza,
          'caracteristicas': dog.caracteristicas,
        };
      }).toList();
    } catch (e) {
      print('Error obteniendo perros: $e');
      print('Stack trace: ${StackTrace.current}');
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
      if (profile['image'] != null && profile['image'].isNotEmpty) {
        final base64String = profile['image'].split(',').last;
        imageBytes = base64Decode(base64String);
      }
    } catch (e) {
      print('Error decodificando imagen base64: $e');
      print('Cadena base64 inválida: ${profile['image']}');
      imageBytes = null;
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 5,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              child: imageBytes != null
                  ? Image.memory(
                      imageBytes,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error mostrando imagen: $error');
                        return Center(child: Text('Error al cargar la imagen'));
                      },
                    )
                  : Center(child: Text('Imagen no disponible')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  profile['name'] ?? 'Nombre no disponible',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown),
                ),
                Text(
                  profile['age'] ?? 'Edad no disponible',
                  style: TextStyle(fontSize: 16, color: Colors.brown.shade400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
   Widget buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () => _matchEngine.currentItem?.nope(),
          icon: Icon(Icons.thumb_down, color: Colors.red),
          label: Text("DISLIKE"),
        ),
        ElevatedButton.icon(
          onPressed: () => _matchEngine.currentItem?.like(),
          icon: Icon(Icons.thumb_up, color: Colors.green),
          label: Text("LIKE"),
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
          backgroundColor: Color(0xFF8B6F47), // Café bajo
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MatchesScreen(likedDogs: _likedDogs)),
                );
              },
            ),
          ],
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
                          onStackFinished: () async {
                            setState(() {
                              _currentPage++;
                            });
                            await _initializeCards();
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
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: _actionColor),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '',
            ),
          ],
          selectedItemColor: Colors.brown[700],
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            if (index == 1) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      MatchesScreen(likedDogs: _likedDogs),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return child; // Sin animación
                  },
                ),
              );
            }
          },
          iconSize: 36, // Tamaño de los iconos
          showSelectedLabels: false,
          showUnselectedLabels: false,
        ),
      );
    }
  }

