import 'package:flutter/material.dart';
import 'profile_screen.dart'; // Importa el ProfileScreen
import 'registro.dart'; // Importa el RegistroScreen
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Importa jwt_decoder

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isPasswordVisible = false;

  final _formKey = GlobalKey<FormState>();

  final emailPattern = r'^[a-zA-Z0-9._%+-]+@(gmail|hotmail|yahoo|outlook)\.[a-zA-Z]{2,}$';

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      _showLoadingDialog();
      try {
        final response = await _apiService.login(
          _emailController.text,
          _passwordController.text,
        );

        // Extraer el token de la respuesta JSON
        final token = response['token'];
        if (token == null) {
          throw Exception('Token no encontrado en la respuesta');
        }

        // Decodificar el token JWT para extraer el userId
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        final userId = decodedToken['id']; // Asegúrate de que el campo coincida con el JSON decodificado

        // Almacenar el userId y el token en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userId);
        await prefs.setString('token', token);

        // Cerrar el cuadro de diálogo de carga
        Navigator.of(context).pop();

        // Navegar a la pantalla de perfil
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
      } catch (e) {
        // Cerrar el cuadro de diálogo de carga
        Navigator.of(context).pop();

        print('Error de inicio de sesión: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Correo electrónico o contraseña incorrectos')),
        );
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Cargando...', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2DE), // Fondo beige
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
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
                        backgroundImage: AssetImage('assets/Logo_dogzline.png'), // Ruta de la imagen
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
                // Login Card
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Iniciar cuenta',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[700],
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        maxLength: 25,
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          border: UnderlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingresa tu correo electrónico';
                          }
                          if (!RegExp(emailPattern).hasMatch(value)) {
                            return 'Por favor, ingresa un correo electrónico válido';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        maxLength: 20,
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingresa tu contraseña';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: Text(
                          'Iniciar sesión',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                // Register Option
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegistroScreen()),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: '¿No tienes una cuenta? ',
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: 'Registrarse',
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
      ),
    );
  }
}