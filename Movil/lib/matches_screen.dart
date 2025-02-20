import 'package:flutter/material.dart';
import 'dart:convert'; // Importa dart:convert para usar base64Decode
import 'dart:typed_data'; // Importa dart:typed_data para usar Uint8List
import 'swipe.dart'; // Importa la pantalla de MatchScreen (swipe)
import 'dogs_list_screen.dart'; // Importa la nueva pantalla DogsListScreen
import 'package:shared_preferences/shared_preferences.dart'; // Importa shared_preferences

class MatchesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> likedDogs;

  MatchesScreen({required this.likedDogs});

  @override
  _MatchesScreenState createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  int _selectedIndex = 1; // Matches es el segundo ítem en la barra de navegación
  List<Map<String, dynamic>> _recentActivityDogs = [];

  @override
  void initState() {
    super.initState();
    _loadLikedDogs();
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MatchScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _loadLikedDogs() async {
    final prefs = await SharedPreferences.getInstance();
    final likedDogsString = prefs.getString('likedDogs') ?? '[]';
    final List<dynamic> likedDogsList = jsonDecode(likedDogsString);
    setState(() {
      _recentActivityDogs = likedDogsList.cast<Map<String, dynamic>>();
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
                Icon(Icons.pets, size: 60, color: Colors.brown.shade600),
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DogsListScreen(
                    title: 'Likes',
                    dogs: widget.likedDogs,
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
          _buildCategorySection('Actividad Reciente', _recentActivityDogs),
          _buildCategorySection('Intereses en Común', []),
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
          Icon(Icons.pets, size: 60, color: Colors.brown.shade600),
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
      imageBytes = base64Decode(dog['image'] ?? '');
    } catch (e) {
      print('Error decoding base64 image: $e');
    }

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
          imageBytes != null
              ? CircleAvatar(
                  backgroundImage: MemoryImage(imageBytes),
                  radius: 40,
                )
              : CircleAvatar(
                  child: Icon(Icons.pets),
                  radius: 40,
                ),
          SizedBox(height: 10),
          Text(dog['name'] ?? 'Nombre no disponible', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown)),
          Text('Edad: ${dog['age'] ?? 'Edad no disponible'}', style: TextStyle(fontSize: 16, color: Colors.brown.shade400)),
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
              icon: Icon(Icons.person),
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