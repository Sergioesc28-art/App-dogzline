import 'package:flutter/material.dart';
import 'dart:convert'; // Importa dart:convert para usar base64Decode
import 'dart:typed_data'; // Importa dart:typed_data para usar Uint8List
import 'swipe.dart'; // Importa la pantalla de MatchScreen (swipe)
import 'dogs_list_screen.dart'; // Importa la nueva pantalla DogsListScreen
import 'chat_screen.dart'; // Importa la pantalla de chat
import 'chat_list_screen.dart'; // Importa la pantalla de lista de chats
import 'package:shared_preferences/shared_preferences.dart'; // Importa shared_preferences
import 'models/data_model.dart'; // Importa el modelo de datos

class MatchesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> likedDogs;
  final String profileId; // Añadir el identificador del perfil

  MatchesScreen({required this.likedDogs, required this.profileId});

  @override
  _MatchesScreenState createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  int _selectedIndex = 1; // Matches es el segundo ítem en la barra de navegación
  List<Map<String, dynamic>> _recentActivityDogs = [];
  List<Map<String, dynamic>> _dislikedDogs = []; // Lista para los perros a los que les diste dislike
  Data? _currentDog;

  @override
  void initState() {
    super.initState();
    _loadLikedDogs();
    _loadDislikedDogs(); // Cargar los perros a los que les diste dislike
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MatchScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatListScreen(
            currentUserId: widget.profileId,
            matches: _recentActivityDogs,
          ),
        ),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _loadLikedDogs() async {
    final prefs = await SharedPreferences.getInstance();
    final likedDogsString = prefs.getString('likedDogs_${widget.profileId}') ?? '[]';
    final List<dynamic> likedDogsList = jsonDecode(likedDogsString);
    setState(() {
      _recentActivityDogs = likedDogsList.cast<Map<String, dynamic>>();
    });
  }

  Future<void> _loadDislikedDogs() async {
    final prefs = await SharedPreferences.getInstance();
    final dislikedDogsString = prefs.getString('dislikedDogs_${widget.profileId}') ?? '[]';
    final List<dynamic> dislikedDogsList = jsonDecode(dislikedDogsString);
    setState(() {
      _dislikedDogs = dislikedDogsList.cast<Map<String, dynamic>>();
    });
  }

  Widget _buildLikesSection() {
    return Column(
      children: [
        SizedBox(height: 20),
        Text(
          'Asciende a Premium y descubre quién ya te dio Like',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.brown),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        Center(
          child: Container(
            width: 150,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Text('Nombre', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown)),
                Text('Edad', style: TextStyle(fontSize: 16, color: Colors.brown.shade400)),
              ],
            ),
          ),
        ),
        Spacer(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: null, // Elimina la función onPressed
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8B6F47), // Café bajo
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
            child: Text(
              'Descubre a quién le gustas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFEFE6DD)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopPicksSection() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCategorySection('Tus "Me gusta"', _recentActivityDogs),
          _buildCategorySection('Segunda Oportunidad', _dislikedDogs), // Nueva sección para los perros a los que les diste dislike
          _buildCategorySection('Recomendado', []),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String title, List<Map<String, dynamic>> dogs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown[700]),
          ),
        ),
        Container(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dogs.isEmpty ? 10 : dogs.length, // Número de perfiles a mostrar
            itemBuilder: (context, index) {
              return dogs.isEmpty ? _buildProfileCard() : _buildDogProfileCard(dogs[index]);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DogsListScreen(
                    title: title,
                    dogs: dogs,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8B6F47), // Café bajo
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
            child: Text(
              'Ver más',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFEFE6DD)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: 150,
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          Text('Nombre', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown)),
          Text('Edad', style: TextStyle(fontSize: 16, color: Colors.brown.shade400)),
        ],
      ),
    );
  }

  Widget _buildDogProfileCard(Map<String, dynamic> dog) {
    Uint8List? imageBytes;
    try {
      String? imageData = dog['fotos'];

      if (imageData != null && imageData.isNotEmpty) {
        // Extraer la parte base64 si tiene prefijo
        if (imageData.contains(',')) {
          imageData = imageData.split(',').last;
        }

        // Eliminar espacios en blanco y caracteres no válidos
        imageData = imageData.replaceAll(RegExp(r'\s+'), '');

        // Decodificar la imagen base64
        imageBytes = base64Decode(imageData);
      }
    } catch (e) {
      print('Error decodificando imagen base64: $e');
      imageBytes = null;
    }

    return Container(
      width: 150,
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: imageBytes != null
                  ? Image.memory(
                      imageBytes,
                      fit: BoxFit.cover,
                      width: 150,
                      height: 150,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error mostrando imagen: $error');
                        return Container(
                          width: 150,
                          height: 150,
                          color: Colors.grey.shade300,
                        );
                      },
                    )
                  : Container(
                      width: 150,
                      height: 150,
                      color: Colors.grey.shade300,
                    ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            dog['name'] ?? 'Nombre no disponible',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
            textAlign: TextAlign.center,
          ),
          Text(
            'Edad: ${dog['age'] ?? 'Edad no disponible'}',
            style: TextStyle(fontSize: 14, color: Colors.brown.shade400),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Color(0xFFEFE6DD), // Beige
        appBar: AppBar(
          backgroundColor: Color(0xFF8B6F47), // Café bajo
          title: Text(
            'Dogzline',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
          ),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey.shade400,
            tabs: [
              Tab(text: 'Likes'),
              Tab(text: 'Top Picks'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLikesSection(),
            _buildTopPicksSection(),
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
              icon: Icon(Icons.message), // Cambiar a icono de mensajería
              label: '',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.brown[700],
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          iconSize: 36, // Tamaño de los iconos
          showSelectedLabels: false,
          showUnselectedLabels: false,
        ),
      ),
    );
  }
}