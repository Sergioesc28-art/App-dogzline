import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'models/data_model.dart';
import 'services/api_service.dart';
import 'matches_screen.dart';
import 'dog_detail_screen.dart';
import 'chat_screen.dart';
import 'chat_list_screen.dart'; // Añadir esta línea
import 'dart:math';

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
  Map<String, List<Map<String, dynamic>>> _likedDogsByProfile = {};
  Map<String, List<Map<String, dynamic>>> _dislikedDogsByProfile = {}; // Añadir esta línea
  final Map<String, Uint8List> _imageCache = {};
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    _loadLikedDogs();
    _loadDislikedDogs(); // Añadir esta línea
    _initializeCards();
  }

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('userId');
    });
  }

  Future<void> _loadLikedDogs() async {
    final prefs = await SharedPreferences.getInstance();
    final likedDogsString = prefs.getString('likedDogsByProfile') ?? '{}';
    final Map<String, dynamic> likedDogsMap = jsonDecode(likedDogsString);
    setState(() {
      _likedDogsByProfile = likedDogsMap.map((key, value) =>
          MapEntry(key, List<Map<String, dynamic>>.from(value)));
    });
  }

  Future<void> _loadDislikedDogs() async {
    final prefs = await SharedPreferences.getInstance();
    final dislikedDogsString = prefs.getString('dislikedDogsByProfile') ?? '{}';
    final Map<String, dynamic> dislikedDogsMap = jsonDecode(dislikedDogsString);
    setState(() {
      _dislikedDogsByProfile = dislikedDogsMap.map((key, value) =>
          MapEntry(key, List<Map<String, dynamic>>.from(value)));
    });
  }

  Future<void> _saveLikedDogs(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    final likedDogsString = jsonEncode(_likedDogsByProfile[profileId]);
    await prefs.setString('likedDogs_$profileId', likedDogsString);
  }

  Future<void> _saveDislikedDogs(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    final dislikedDogsString = jsonEncode(_dislikedDogsByProfile[profileId]);
    await prefs.setString('dislikedDogs_$profileId', dislikedDogsString);
  }

  Future<void> _initializeCards() async {
    List<Map<String, dynamic>> dogs = await generateDogs();
    _swipeItems.clear(); // Limpiar la lista antes de agregar nuevos elementos
    _swipeItems.addAll(dogs.map((profile) {
      return SwipeItem(
        content: profile,
        likeAction: () => _onLikeAction(profile, _currentUserId!), // Añadir profileId aquí
        nopeAction: () => _onDislikeAction(profile, _currentUserId!), // Añadir profileId aquí
      );
    }).toList());

    setState(() {
      _matchEngine = MatchEngine(swipeItems: _swipeItems);
    });
  }

  void _onLikeAction(Map<String, dynamic> profile, String profileId) {
    _showAction("LIKE ❤️", Colors.green);
    if (!_likedDogsByProfile.containsKey(profileId)) {
      _likedDogsByProfile[profileId] = [];
    }
    _likedDogsByProfile[profileId]!.insert(0, profile); // Añadir al principio de la lista
    _saveLikedDogs(profileId);
    _sendLikeNotification(profile);
  }

  void _onDislikeAction(Map<String, dynamic> profile, String profileId) {
    _showAction("DISLIKE ❌", Colors.red);
    if (!_dislikedDogsByProfile.containsKey(profileId)) {
      _dislikedDogsByProfile[profileId] = [];
    }
    _dislikedDogsByProfile[profileId]!.insert(0, profile); // Añadir al principio de la lista
    _saveDislikedDogs(profileId);
  }

Future<void> _sendLikeNotification(Map<String, dynamic> profile) async {
  // Validaciones más estrictas
  if (profile['idUsuario'] == null || profile['idUsuario'].isEmpty) {
    print("Error: No se puede enviar notificación sin ID de usuario");
    return;
  }

  if (profile['id'] == null || profile['id'].isEmpty) {
    print("Error: No se puede enviar notificación sin ID de mascota");
    return;
  }

  try {
    final notificacion = Notificacion(
      idUsuario: profile['idUsuario'],
      idMascota: profile['id'], // Ahora directo, no como objeto Data
      mensajeLlegada: DateTime.now(),
      contenido: "¡Te han dado un like en tu mascota: ${profile['name']}!",
      leido: false,
      foto: profile['fotos'],
    );

    final resultado = await _apiService.createNotificacion(notificacion);
    
    if (resultado != null) {
      print("Notificación enviada correctamente");
    } else {
      print("No se pudo enviar la notificación");
    }
  } catch (error) {
    print("Error al enviar notificación de like: $error");
  }
}
  Future<List<Map<String, dynamic>>> generateDogs() async {
    try {
      final randomPage = Random().nextInt(10) + 1;
      List<Data> dogs = await _apiService.getDogs(page: randomPage, limit: 10);
      dogs.shuffle();

      return dogs.map((dog) {
        // Prepara la imagen en formato Base64
        String imageData = dog.fotos ?? '';
        if (imageData.isNotEmpty && !imageData.startsWith('data:image')) {
          imageData = 'data:image/png;base64,$imageData';
        }

        // Regresamos un Map que incluye todos los campos necesarios
        return {
          'id': dog.id, // ID único de la mascota
          'idUsuario': dog.idUsuario, // ID del dueño, necesario para notificaciones
          'fotos': imageData, // Usamos la clave 'fotos' para que _sendLikeNotification la encuentre
          'name': dog.nombre,
          'age': dog.edad.toString(),
          'raza': dog.raza,
          'caracteristicas': dog.caracteristicas,
          'sexo': dog.sexo,
          'color': dog.color,
          'vacunas': dog.vacunas,
          'certificado': dog.certificado,
          'comportamiento': dog.comportamiento,
          'distancia': dog.distancia.toString(), // Convertir a String
        };
      }).toList();
    } catch (e) {
      print('Error obteniendo perros: $e');
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

  Future<Uint8List?> _getImageBytes(String? imageString) async {
    if (imageString == null || imageString.isEmpty) {
      return null;
    }

    try {
      String base64Data = imageString;
      if (base64Data.contains(',')) {
        base64Data = base64Data.split(',').last.trim();
      }
      base64Data = base64Data.replaceAll(RegExp(r'\s+'), '');

      while (base64Data.length % 4 != 0) {
        base64Data += '=';
      }

      final bytes = base64Decode(base64Data);
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
      future: _getImageBytes(profile['fotos']),
      builder: (context, snapshot) {
        Widget imageWidget;

        if (snapshot.connectionState == ConnectionState.waiting) {
          imageWidget = Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && snapshot.data != null) {
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

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DogDetailScreen(
                  dog: Data(
                    id: profile['id'],
                    nombre: profile['name'],
                    edad: int.parse(profile['age']),
                    raza: profile['raza'],
                    sexo: profile['sexo'],
                    color: profile['color'],
                    vacunas: profile['vacunas'],
                    caracteristicas: profile['caracteristicas'],
                    certificado: profile['certificado'],
                    fotos: profile['fotos'],
                    comportamiento: profile['comportamiento'],
                    idUsuario: profile['idUsuario'],
                    distancia: profile['distancia'],
                  ),
                ),
              ),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 5,
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    child: Container(
                      color: Colors.white,
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
        backgroundColor: Color(0xFF8B6F47),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
            icon: Icon(Icons.message), // Cambiar el icono de perfil al de mensajería
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
                    MatchesScreen(
                        likedDogs:
                            _likedDogsByProfile[_currentUserId] ?? [],
                        profileId: _currentUserId!), // Añadir profileId aquí
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return child; // Sin animación
                },
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatListScreen(
                  currentUserId: _currentUserId!, // Reemplaza con el ID del usuario actual
                  matches: _likedDogsByProfile[_currentUserId] ?? [], // Lista de matches
                ),
              ),
            );
          }
        },
        iconSize: 36,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}