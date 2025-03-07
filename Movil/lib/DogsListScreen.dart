import 'package:flutter/material.dart';
import 'dart:convert'; // Importa dart:convert para usar base64Decode
import 'dart:typed_data'; // Importa dart:typed_data para usar Uint8List

class DogsListScreen extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> dogs;

  DogsListScreen({required this.title, required this.dogs});

  Uint8List? _getImageBytes(String? imageString) {
    if (imageString == null || imageString.isEmpty) return null;
    try {
      String base64Data = imageString.contains(',') ? imageString.split(',').last.trim() : imageString;
      while (base64Data.length % 4 != 0) base64Data += '=';
      return base64Decode(base64Data);
    } catch (e) {
      print('Error decodificando la imagen: $e');
      return null;
    }
  }

  Widget _buildDogProfileCard(Map<String, dynamic> dog) {
    Uint8List? imageBytes = _getImageBytes(dog['fotos']);

    return Container(
      width: 150,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
          imageBytes != null
              ? ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.memory(
                    imageBytes,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 100, // Ajusta la altura según tus necesidades
                    errorBuilder: (context, error, stackTrace) {
                      print('Error mostrando imagen: $error');
                      return Container(
                        width: double.infinity,
                        height: 100,
                        color: Colors.grey.shade300,
                        child: Icon(Icons.pets, size: 60, color: Colors.brown.shade600),
                      );
                    },
                  ),
                )
              : Container(
                  width: double.infinity,
                  height: 100,
                  color: Colors.grey.shade300,
                  child: Icon(Icons.pets, size: 60, color: Colors.brown.shade600),
                ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              dog['name'] ?? 'Nombre no disponible',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown),
              textAlign: TextAlign.center,
            ),
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF8B6F47), // Café bajo
        title: Text(
          title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: dogs.isEmpty
          ? Center(
              child: Text(
                'No hay perros para mostrar',
                style: TextStyle(fontSize: 18, color: Colors.brown.shade700),
              ),
            )
          : GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Número de columnas en la cuadrícula
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75, // Ajusta la relación de aspecto según tus necesidades
              ),
              itemCount: dogs.length,
              itemBuilder: (context, index) {
                return _buildDogProfileCard(dogs[index]);
              },
            ),
    );
  }
}