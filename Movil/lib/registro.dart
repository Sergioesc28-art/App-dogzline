import 'package:flutter/material.dart';
import 'profile_screen.dart'; // Importa la pantalla de perfil
import '../services/api_service.dart'; // Asegúrate de importar tu ApiService
import 'main.dart'; // Importa la pantalla de inicio de sesión

class RegistroScreen extends StatefulWidget {
  @override
  _RegistroScreenState createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final TextEditingController _nombreCompletoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _obscureText = true;

  Future<void> _register() async {
    if (_nombreCompletoController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    try {
      await _apiService.register(
        _nombreCompletoController.text,
        _emailController.text,
        _passwordController.text,
        'usuario', // Establecer el rol como "usuario" por defecto
      );

      // Navegar a la pantalla de inicio de sesión
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      // Manejar el error
      print('Error de registro: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de registro: $e')),
      );
    }
  }

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
                backgroundImage: AssetImage('assets/Logo_dogzline.png'), // Ajusta según tu logo
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
              _buildTextField("Nombre Completo", _nombreCompletoController),
              SizedBox(height: 10),
              _buildTextField("E-mail", _emailController),
              SizedBox(height: 10),
              _buildTextField("Contraseña", _passwordController, isPassword: true),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC4B08F), // Botón en tono marrón claro
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                ),
                child: Text("Registrarse"),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text("Ya tienes una cuenta? Inicia sesión"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscureText : false,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
    );
  }
}