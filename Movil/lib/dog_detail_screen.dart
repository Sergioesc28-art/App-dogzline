import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'models/data_model.dart';
import 'services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart'; // Importa Google Fonts

class DogDetailScreen extends StatefulWidget {
  final String? idDogLiked; // ID del perro que dio "like" (opcional)
  final Data? dog; // Objeto completo del perro (opcional)

  const DogDetailScreen({Key? key, this.idDogLiked, this.dog})
      : assert(idDogLiked != null || dog != null, 'Debe proporcionarse idDogLiked o dog'),
        super(key: key);

  @override
  _DogDetailScreenState createState() => _DogDetailScreenState();
}

class _DogDetailScreenState extends State<DogDetailScreen> {
  Data? likedDog; // Información del perro
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // Si se pasa un objeto Data directamente
    if (widget.dog != null) {
      likedDog = widget.dog;
      isLoading = false;
    } else {
      _fetchLikedDog(); // Buscar el perro por ID si solo se pasa idDogLiked
    }
  }

  // Método para obtener el perro que dio "like" por su ID
  Future<void> _fetchLikedDog() async {
    try {
      print('[DEBUG] Buscando perro con ID: ${widget.idDogLiked}');
      final dog = await ApiService().getDogById(widget.idDogLiked!);
      print('[DEBUG] Perro obtenido: ${dog.toJson()}');
      setState(() {
        likedDog = dog;
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar el perro: $e');
      setState(() => isLoading = false);
    }
  }

  // Decodificar imágenes base64
  Future<Uint8List?> _getImageBytes(String? imageString) async {
    if (imageString == null || imageString.isEmpty) return null;
    try {
      String base64Data =
      imageString.contains(',') ? imageString.split(',').last.trim() : imageString;
      while (base64Data.length % 4 != 0) base64Data += '=';
      return base64Decode(base64Data);
    } catch (e) {
      print('Error decodificando la imagen: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Dogzline',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.brown),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (likedDog == null)
          ? const Center(
        child: Text(
          'Error al cargar los datos del perro',
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDogImage(likedDog!.fotos),
            const SizedBox(height: 10),
            Text(
              likedDog!.nombre,
              style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.brown[800]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            _buildInfoRow('Edad:', '${likedDog!.edad} años'),
            _buildInfoRow('Raza:', likedDog!.raza),
            _buildInfoRow('Sexo:', likedDog!.sexo == 'M' ? 'Macho' : 'Hembra'),
            _buildInfoRow('Color:', likedDog!.color),
            _buildInfoRow('Vacunas:', likedDog!.vacunas),
            _buildInfoRow('Características:', likedDog!.caracteristicas),
            _buildInfoRow('Comportamiento:', likedDog!.comportamiento),
          ],
        ),
      ),
      backgroundColor: Color(0xFFF9F6E8), // Fondo beige
    );
  }

  // Mostrar imagen del perro
  Widget _buildDogImage(String? base64Image) {
    return FutureBuilder<Uint8List?>(
      future: _getImageBytes(base64Image),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && snapshot.data != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(20), // Ajusta el radio de las esquinas aquí
            child: Image.memory(snapshot.data!, fit: BoxFit.cover),
          );
        } else {
          return Container(
            height: 200,
            color: Colors.grey[200],
            child: const Center(
              child: Text(
                'Imagen no disponible',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          );
        }
      },
    );
  }

  // Mostrar información clave-valor
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label ',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown[700]),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.brown[500]),
            ),
          ),
        ],
      ),
    );
  }
}