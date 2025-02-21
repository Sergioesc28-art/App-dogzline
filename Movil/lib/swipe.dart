import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Importa dart:convert para usar base64Decode
import 'dart:typed_data'; // Importa dart:typed_data para usar Uint8List
import 'dart:ui';
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

class _MatchScreenState extends State<MatchScreen> {
  late MatchEngine _matchEngine;
  List<SwipeItem> _swipeItems = [];
  String _actionText = "";
  Color _actionColor = Colors.transparent;
  double _opacity = 0.0;
  final ApiService _apiService = ApiService();
  int _currentPage = 1;
  List<Map<String, dynamic>> _likedDogs = [];
  // Cache para imágenes decodificadas
  final Map<String, Uint8List> _imageCache = {};

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
      List<Data> dogs =
          await _apiService.getDogs(page: _currentPage, limit: 10);

      for (var dog in dogs) {
        if (dog.fotos != null && dog.fotos!.isNotEmpty) {
          print(
              'Perro: ${dog.nombre}, longitud de datos: ${dog.fotos!.length}');
        }
      }

      return dogs.map((dog) {
        String imageData = dog.fotos ?? '';

        // Asegurarte de que la imagen es una cadena base64 válida
        if (imageData.isNotEmpty && !imageData.startsWith('data:image')) {
          imageData = 'data:image/png;base64,$imageData';
        }

        return {
          'image': imageData,
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

  // Método mejorado para obtener datos de imagen
  Future<Uint8List?> _getImageBytes(String? imageString) async {
    if (imageString == null || imageString.isEmpty) {
      return null;
    }

    try {
      String base64Data = imageString;

      // Extraer la parte base64 si tiene prefijo
      if (base64Data.contains(',')) {
        base64Data = base64Data.split(',').last.trim();
      }

      // Eliminar espacios en blanco
      base64Data = base64Data.replaceAll(RegExp(r'\s+'), '');

      // Asegurar que la longitud sea múltiplo de 4 (requerido para base64)
      while (base64Data.length % 4 != 0) {
        base64Data += '=';
      }

      // Decodificar la imagen
      final bytes = base64Decode(base64Data);

      // Verificar que tengamos suficientes datos para una imagen
      if (bytes.length < 100) {
        print('Advertencia: Imagen demasiado pequeña (${bytes.length} bytes)');
        return null;
      }

      return bytes;
    } catch (e) {
      print('Error decodificando imagen: $e');
      return null;
    }
  }

  Widget buildProfileCard(Map<String, dynamic> profile) {
    return FutureBuilder<Uint8List?>(
      future: _getImageBytes(profile['image']),
      builder: (context, snapshot) {
        Widget imageWidget;

        if (snapshot.connectionState == ConnectionState.waiting) {
          // Mostrar indicador de carga mientras se decodifica la imagen
          imageWidget = Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && snapshot.data != null) {
          // Mostrar la imagen decodificada sin forzar dimensiones
          imageWidget = Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) {
              print('Error mostrando imagen: $error');
              return Center(child: Text('Error al cargar la imagen'));
            },
          );
        } else {
          // Mostrar un placeholder si no hay imagen
          imageWidget = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pets, size: 60, color: Colors.grey),
                SizedBox(height: 10),
                Text('Imagen no disponible'),
              ],
            ),
          );
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
              AspectRatio(
                aspectRatio: 1, // Mantener una relación de aspecto cuadrada
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child: Container(
                    color: Colors.white, // Fondo blanco para las imágenes
                    child: imageWidget,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      profile['name'] ?? 'Nombre no disponible',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      profile['age'] ?? 'Edad no disponible',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.brown.shade400,
                      ),
                    ),
                    if (profile['raza'] != null)
                      Text(
                        profile['raza'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.brown.shade300,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.red.shade700,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _matchEngine.currentItem?.like(),
          icon: Icon(Icons.thumb_up, color: Colors.green),
          label: Text("LIKE"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.green.shade700,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
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
                    builder: (context) => MatchesScreen(likedDogs: _likedDogs)),
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
              SizedBox(height: 10),
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
