import 'package:flutter/material.dart';
import 'profile_screen.dart'; // Importa el ProfileScreen
import 'perfil_perro.dart'; // Importa el DogDetailScreen

class DogzlineScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber.shade100,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
        ),
        title: Text('Dogzline', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.brown)),
        actions: [
          Icon(Icons.notifications_none, color: Colors.black),
          SizedBox(width: 10),
          Icon(Icons.settings, color: Colors.black),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/chucho.jpg'),
          ),
          SizedBox(height: 10),
          Text('Chucho', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Busqueda',
                prefixIcon: Icon(Icons.search),
                suffixIcon: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    icon: Icon(Icons.filter_list),
                    items: [],
                    onChanged: (value) {},
                  ),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchDogsFromDatabase(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar los datos'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No hay perros disponibles'));
                }
                
                final dogs = snapshot.data!;
                return ListView.builder(
                  itemCount: dogs.length,
                  itemBuilder: (context, index) {
                    final dog = dogs[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(dog['image']),
                        ),
                        title: Text(dog['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${dog['gender']}, ${dog['age']} años\n${dog['distance']} de distancia'),
                        trailing: Icon(Icons.location_on, color: Colors.orange),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DogDetailScreen(dog: dog)),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchDogsFromDatabase() async {
    // Simulación de datos desde la base de datos
    await Future.delayed(Duration(seconds: 2));
    return [
      {'name': 'Oliver', 'gender': 'Macho', 'age': 2, 'distance': '0.9 Km', 'image': 'https://example.com/oliver.jpg'},
      {'name': 'Bobby', 'gender': 'Macho', 'age': 6, 'distance': '2.6 Km', 'image': 'https://example.com/bobby.jpg'},
      {'name': 'Bella', 'gender': 'Hembra', 'age': 12, 'distance': '5.9 Km', 'image': 'https://example.com/bella.jpg'},
      {'name': 'Firulais', 'gender': 'Macho', 'age': 8, 'distance': '10 Km', 'image': 'https://example.com/firulais.jpg'},
    ];
  }
}