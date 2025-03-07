import 'package:flutter/material.dart';
import 'profile_screen.dart'; // Importa el ProfileScreen
import 'main.dart'; // Importa el LoginPage
import 'package:shared_preferences/shared_preferences.dart'; // Importa SharedPreferences
import 'package:google_fonts/google_fonts.dart'; // Importa Google Fonts

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double maxDistance = 160;
  RangeValues ageRange = RangeValues(1, 4);
  bool showFarDogs = false;
  bool showOutOfRangeDogs = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F6E8), // Fondo beige
      appBar: AppBar(
        backgroundColor: Colors.white, // Barra de color blanco
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()), // Usa la clase ProfileScreen
            );
          },
        ),
        title: Text(
          'Configuraciones',
          style: GoogleFonts.poppins(
            color: Colors.brown,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSliderSetting(
              'Distancias Maxima',
              '${maxDistance.toInt()} Km',
              maxDistance,
              (value) {
                setState(() {
                  maxDistance = value;
                });
              },
            ),
            _buildSwitchSetting(
              'Mostrar perros más lejos si me quedo sin perfiles para ver.',
              showFarDogs,
              (value) {
                setState(() {
                  showFarDogs = value;
                });
              },
            ),
            _buildRangeSliderSetting(
              'Rango de edad',
              ageRange,
              (values) {
                setState(() {
                  ageRange = values;
                });
              },
            ),
            _buildSwitchSetting(
              'Mostrar perros fuera de mi rango preferido, si me quedo sin perfiles para ver.',
              showOutOfRangeDogs,
              (value) {
                setState(() {
                  showOutOfRangeDogs = value;
                });
              },
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown, // Changed from 'primary' to 'backgroundColor'
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(
                    'Cerrar sesión',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Eliminar todos los datos de sesión

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // Redirigir a la pantalla de inicio de sesión
    );
  }

  Widget _buildSliderSetting(String label, String value, double currentValue, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.brown, fontSize: 16),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Slider(
                value: currentValue,
                min: 0,
                max: 200,
                activeColor: Colors.brown,
                onChanged: onChanged,
              ),
            ),
            Text(value, style: GoogleFonts.poppins(color: Colors.brown)),
          ],
        ),
      ],
    );
  }

  Widget _buildSwitchSetting(String label, bool currentValue, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(color: Colors.brown, fontSize: 14),
          ),
        ),
        Switch(
          value: currentValue,
          activeColor: Colors.brown,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildRangeSliderSetting(String label, RangeValues currentRange, Function(RangeValues) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.brown, fontSize: 16),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: RangeSlider(
                values: currentRange,
                min: 0,
                max: 10,
                divisions: 10,
                activeColor: Colors.brown,
                onChanged: onChanged,
              ),
            ),
            Text(
              '${currentRange.start.toInt()}-${currentRange.end.toInt()}',
              style: GoogleFonts.poppins(color: Colors.brown),
            ),
          ],
        ),
      ],
    );
  }
}