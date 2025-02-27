import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'models/data_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart'; // Importa ApiService

class DogDetailScreen extends StatelessWidget {
  final Data dog;

  const DogDetailScreen({Key? key, required this.dog}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber.shade100,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Dogzline', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.brown)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            FutureBuilder<Uint8List?>(
              future: _getImageBytes(dog.fotos),
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

                return AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      color: Colors.white,
                      child: imageWidget,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 10),
            Text(dog.nombre, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Edad: ${dog.edad} años', style: TextStyle(fontSize: 18)),
            Text('Raza: ${dog.raza}', style: TextStyle(fontSize: 18)),
            Text('Sexo: ${dog.sexo == 'M' ? 'Macho' : 'Hembra'}', style: TextStyle(fontSize: 18)),
            Text('Color: ${dog.color}', style: TextStyle(fontSize: 18)),
            Text('Vacunas: ${dog.vacunas}', style: TextStyle(fontSize: 18)),
            Text('Características: ${dog.caracteristicas}', style: TextStyle(fontSize: 18)),
            Text('Certificado: ${dog.certificado}', style: TextStyle(fontSize: 18)),
            Text('Comportamiento: ${dog.comportamiento}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Lógica para dar like
                    _handleLike(context);
                  },
                  icon: Icon(Icons.thumb_up),
                  label: Text('Like'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Lógica para rechazar
                    _handleDislike(context);
                  },
                  icon: Icon(Icons.thumb_down),
                  label: Text('Dislike'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleLike(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId != null) {
      try {
        // Lógica para dar like
        await ApiService().darLike(userId, dog.idUsuario);
        _saveDogToPreferences('likedDogs_$userId', dog);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Like enviado.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al dar like: $e')),
        );
      }
    }
  }

  void _handleDislike(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId != null) {
      _saveDogToPreferences('dislikedDogs_$userId', dog);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dislike enviado.')),
      );
    }
    Navigator.pop(context);
  }

  void _saveDogToPreferences(String key, Data dog) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> dogs = prefs.getStringList(key) ?? [];
    dogs.add(jsonEncode(dog.toJson()));
    await prefs.setStringList(key, dogs);
  }
}