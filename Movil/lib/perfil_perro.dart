import 'package:flutter/material.dart';

class DogDetailScreen extends StatelessWidget {
  final Map<String, dynamic> dog;

  const DogDetailScreen({required this.dog, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber.shade100,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 250,
                width: double.infinity,
                color: Colors.grey.shade300, // Placeholder color for the image slot
                child: Center(
                  child: Text(
                    'Imagen del perro',
                    style: TextStyle(fontSize: 20, color: Colors.grey.shade600),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                dog['name'] ?? 'Desconocido',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.orange),
                  SizedBox(width: 5),
                  Text(dog['location'] ?? 'Ubicación desconocida', style: TextStyle(fontSize: 16)),
                ],
              ),
              SizedBox(height: 10),
              _buildSectionTitle('Sobre mí:'),
              _buildSectionContent(dog['description'] ?? 'Descripción no disponible'),
              _buildSectionTitle('Aspectos:'),
              _buildSectionContent('Color: ${dog['color'] ?? 'Desconocido'}\nPeso: ${dog['weight'] ?? 'Desconocido'} kg\nAltura: ${dog['height'] ?? 'Desconocido'} cm a la cruz'),
              _buildSectionTitle('Salud y Genética:'),
              _buildSectionContent(
                  'Estado de Salud: ${dog['health'] ?? 'Desconocido'}\nVacunas: ${dog['vaccines'] ?? 'Desconocido'}\nDesparasitación: ${dog['deworming'] ?? 'Desconocido'}\nAntecedentes Genéticos: ${dog['genetics'] ?? 'Desconocido'}\nAptitud para Reproducción: ${dog['breeding'] ?? 'Desconocido'}'),
              _buildSectionTitle('Preferencias de Apareamiento:'),
              _buildSectionContent(
                  'Disponibilidad: ${dog['availability'] ?? 'Desconocido'}\nTamaño Compatible: ${dog['size_preference'] ?? 'Desconocido'}'),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  onPressed: () {},
                  child: Text('Contactar', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 5),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(content, style: TextStyle(fontSize: 16)),
    );
  }
}