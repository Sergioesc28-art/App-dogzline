import 'package:flutter/material.dart';
import 'main.dart'; // Importa la pantalla de inicio de sesión
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';

class RegistroScreen extends StatefulWidget {
  @override
  _RegistroScreenState createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final TextEditingController _nombreCompletoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isPasswordValid = false;
  bool _isPasswordMatching = false;

  final emailPattern = r'^[a-zA-Z0-9._%+-]+@(gmail|hotmail|yahoo|outlook)\.[a-zA-Z]{2,}$';
  final passwordPattern = r'^(?=.*[0-9])(?=.*[!@#\$&*~]).{6,}$';

  void _validatePassword(String password) {
    setState(() {
      _isPasswordValid = RegExp(passwordPattern).hasMatch(password);
      _isPasswordMatching = password == _confirmPasswordController.text;
    });
  }

  void _validateConfirmPassword(String confirmPassword) {
    setState(() {
      _isPasswordMatching = confirmPassword == _passwordController.text;
    });
  }

  Future<void> _register() async {
    if (_nombreCompletoController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _passwordController.text.isEmpty || 
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    if (!RegExp(emailPattern).hasMatch(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingresa un correo electrónico válido')),
      );
      return;
    }

    if (!_isPasswordValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('La contraseña debe tener al menos 6 caracteres, un número y un signo especial')),
      );
      return;
    }

    if (!_isPasswordMatching) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    try {
      await _apiService.register(
        _nombreCompletoController.text,
        _emailController.text,
        _passwordController.text,
        'usuario', // Rol predeterminado
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de registro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2DE), // Fondo beige
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/Logo_dogzline.png'),
                      backgroundColor: Colors.transparent,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Dogzline',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown[700],
                      ),
                    ),
                    Text(
                      'Encuentra. Conoce. Conecta.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.brown[400],
                      ),
                    ),
                  ],
                ),
              ),
              // Registro Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Crear cuenta',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown[700],
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _nombreCompletoController,
                      maxLength: 30,
                      decoration: InputDecoration(
                        labelText: 'Nombre Completo',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      maxLength: 25,
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    Tooltip(
                      message: 'La contraseña debe tener al menos 6 caracteres, un número y un signo especial',
                      child: TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        maxLength: 20,
                        onChanged: _validatePassword,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          border: UnderlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      onChanged: _validateConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirmar Contraseña',
                        border: UnderlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _passwordController.text.length >= 6 ? Icons.check_circle : Icons.cancel,
                              color: _passwordController.text.length >= 6 ? Colors.green : Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '6 caracteres',
                              style: TextStyle(
                                fontSize: 14,
                                color: _passwordController.text.length >= 6 ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              RegExp(r'[0-9]').hasMatch(_passwordController.text) ? Icons.check_circle : Icons.cancel,
                              color: RegExp(r'[0-9]').hasMatch(_passwordController.text) ? Colors.green : Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Un número',
                              style: TextStyle(
                                fontSize: 14,
                                color: RegExp(r'[0-9]').hasMatch(_passwordController.text) ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              RegExp(r'[!@#\$&*~]').hasMatch(_passwordController.text) ? Icons.check_circle : Icons.cancel,
                              color: RegExp(r'[!@#\$&*~]').hasMatch(_passwordController.text) ? Colors.green : Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Un signo especial',
                              style: TextStyle(
                                fontSize: 14,
                                color: RegExp(r'[!@#\$&*~]').hasMatch(_passwordController.text) ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text(
                        'Registrarse',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              // Login Option
              Padding(
                padding: const EdgeInsets.only(top: 10), // Ajusta el padding para subir el texto
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: '¿Ya tienes una cuenta? ',
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: 'Inicia sesión',
                          style: TextStyle(
                            color: Colors.brown[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}