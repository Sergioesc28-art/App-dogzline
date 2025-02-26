import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';
import 'models/data_model.dart';
import 'dart:convert';

class PerfilScreen extends StatefulWidget {
  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final ApiService _apiService = ApiService();
  List<Data> _mascotas = [];
  bool _isLoading = true;
  String _userName = 'Usuario';
  String _ubicacion = 'Ubicación no disponible';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchMascotas();
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Usuario';
      _ubicacion = prefs.getString('ubicacion') ?? 'Ubicación no disponible';
    });
  }

  Future<void> _fetchMascotas() async {
    try {
      List<Data> mascotas = await _apiService.getMascotasByUser(1, 10);
      setState(() {
        _mascotas = mascotas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener las mascotas: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5EEDC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage('assets/default_profile.png'),
                    ),
                    SizedBox(height: 12),
                    Text(
                      _userName,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(_ubicacion),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Perros registrados',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _isLoading
                ? CircularProgressIndicator()
                : _mascotas.isEmpty
                    ? Text('No hay perros registrados')
                    : Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: _mascotas.map((mascota) {
                          return PetCard(
                            image: mascota.fotos != null && mascota.fotos!.isNotEmpty
                                ? MemoryImage(base64Decode(mascota.fotos!.split(',').last))
                                : AssetImage('assets/default_dog.png') as ImageProvider,
                            name: mascota.nombre ?? 'Sin nombre',
                            age: mascota.edad?.toString() ?? '0',
                          );
                        }).toList(),
                      ),
          ],
        ),
      ),
    );
  }
}

class PetCard extends StatelessWidget {
  final ImageProvider image;
  final String name;
  final String age;

  PetCard({required this.image, required this.name, required this.age});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: image,
        ),
        SizedBox(height: 6),
        Text(
          '$name, $age',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}