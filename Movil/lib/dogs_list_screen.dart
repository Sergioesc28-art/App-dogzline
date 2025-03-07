import 'package:flutter/material.dart';
import 'dart:convert'; // Importa dart:convert para usar base64Decode
import 'dart:typed_data'; // Importa dart:typed_data para usar Uint8List

class DogsListScreen extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> dogs;

  DogsListScreen({required this.title, required this.dogs});

  Widget _buildDogProfileCard(Map<String, dynamic> dog) {
    Uint8List? imageBytes;
    try {
      if (dog['image'] != null && dog['image'].isNotEmpty) {
        imageBytes = base64Decode(dog['image']);
      }
    } catch (e) {
      print('Error decoding base64 image: $e');
    }

    return Container(
      width: 180,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                  radius: 50,
                )
              : CircleAvatar(
                  child: Icon(Icons.pets),
                  radius: 50,
                ),
          SizedBox(height: 10),
          Text(dog['name'] ?? 'Nombre no disponible',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown)),
          Text('Edad: ${dog['age'] ?? 'Edad no disponible'}',
              style: TextStyle(fontSize: 16, color: Colors.brown.shade400)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF8B6F47), // Café bajo
        title: Text(
          title,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75, // Ajusta el aspecto de las tarjetas
            ),
            itemCount: dogs.length,
            itemBuilder: (context, index) {
              return _buildDogProfileCard(dogs[index]);
            },
          ),
        ),
      ),
    );
  }
}