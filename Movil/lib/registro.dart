import 'package:flutter/material.dart';
import 'profile_screen.dart'; // Importa la pantalla de perfil

class RegistroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F5E9), // Fondo en tono crema
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/logo.png'), // Ajusta según tu logo
                backgroundColor: Colors.transparent,
              ),
              SizedBox(height: 20),
              Text(
                "Registrarse",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9B6A37), // Color marrón del texto
                ),
              ),
              SizedBox(height: 20),
              _buildTextField("Nombre Completo"),
              _buildTextField("E-mail"),
              _buildTextField("Contraseña", isPassword: true),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navegar a ProfileScreen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC4B08F), // Botón en tono beige
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text(
                  "Registrar",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  // Redirige a la pantalla de inicio de sesión
                  Navigator.pop(context);
                },
                child: Text(
                  "¿Ya tienes una cuenta? Iniciar sesión",
                  style: TextStyle(color: Color(0xFF9B6A37)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFF9B6A37)),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF9B6A37)),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF9B6A37)),
          ),
        ),
      ),
    );
  }
}