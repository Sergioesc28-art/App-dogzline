import 'package:flutter/material.dart';
import 'dialogue.dart'; // Importa el DialogueScreen
import 'create_dog.dart'; // Importa el CreateDogPage
import 'config.dart'; // Importa el SettingsScreen
import 'apartado_screen.dart'; // Importa el ApartadoScreen
import 'perfil.dart'; // Importa el PerfilScreen
import 'dogzline_ui.dart'; // Importa el DogzlineScreen
import 'services/api_service.dart'; // Importa el ApiService
import 'models/data_model.dart'; // Importa el modelo de datos
import 'package:shared_preferences/shared_preferences.dart'; // Importa SharedPreferences
import 'swipe.dart'; // Importa el MatchScreen
import 'dart:convert'; // Importa dart:convert para decodificar base64
import 'dog_detail_screen.dart'; // Importa DogDetailScreen

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 0; // Home es el primer ítem en la barra de navegación

  static List<Widget> _widgetOptions = <Widget>[
    ProfileScreenContent(), // Home Page
    ApartadoScreen(),
    PerfilScreen(), // Perfil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Apartado',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.brown[700],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateDogPage()),
          );
        },
        backgroundColor: Color(0xFF8B6F47), // Café bajo
        child: Icon(Icons.add),
      ),
      backgroundColor: Color(0xFFF9F6E8),
    );
  }
}

class ProfileScreenContent extends StatefulWidget {
  @override
  _ProfileScreenContentState createState() => _ProfileScreenContentState();
}

class _ProfileScreenContentState extends State<ProfileScreenContent> {
  final ApiService _apiService = ApiService();
  List<Data> _mascotas = [];
  bool _isLoading = true;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchMascotas();
  }

  Future<void> _fetchUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Usuario';
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
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.settings, color: Colors.brown[700]), // Cambiar el icono de filtrado al de configuración
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      SettingsScreen()), // Navegar a SettingsScreen
            );
          },
        ),
        title: Text(
          'Dogzline',
          style: TextStyle(
            fontSize: 24,
            color: Colors.brown[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.brown[700]),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Mensaje de bienvenida
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    'Bienvenido, $_userName',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[700],
                    ),
                  ),
                ],
              ),
            ),
            // Nivel de suscripción
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DialogueScreen()),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(15),
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
                      'Dogzline',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown[700],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '¿Qué incluye?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown[700],
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.check, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Recomendaciones Personalizadas'),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.check, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Coincidencias Prioritarias'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Perros registrados
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Perros registrados',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown[700],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _mascotas.isEmpty
                          ? Center(child: Text('No hay perros registrados.'))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ..._mascotas.map((mascota) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MatchScreen()),
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundImage: MemoryImage(
                                              base64Decode(mascota.fotos!
                                                  .split(',')
                                                  .last)),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          mascota.nombre ?? '',
                                          style: TextStyle(
                                              color: Colors
                                                  .brown[700]), // Texto café
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFFF9F6E8),
    );
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  Future<List<Notificacion>> _futureNotificaciones = Future.value([]); // Inicializado aquí

  @override
  void initState() {
    super.initState();
    _loadUser(); // Llamada correcta a la función
    IdAndFetchNotifications();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) {
      print('ID de usuario no encontrado');
    }
  }

  Future<void> IdAndFetchNotifications() async { // Cambiado a Future<void>
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    setState(() { // Actualiza el estado después de obtener el userId
      if (userId != null) {
        _futureNotificaciones = ApiService().getNotificaciones(userId);
      } else {
        print('ID de usuario no encontrado');
        _futureNotificaciones = Future.value([]);
      }
    });
  }

  Future<void> _refreshNotificaciones() async {
    await _loadUser(); // Espera a que termine
    await IdAndFetchNotifications(); // Espera a que termine
  }

  Widget _buildAvatarFromBase64(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return Icon(Icons.notifications, color: Colors.brown[700]);
    }
    try {
      if (base64String.contains('base64,')) {
        base64String = base64String.split('base64,').last;
      }
      final decodedBytes = base64Decode(base64String);
      return CircleAvatar(
        backgroundImage: MemoryImage(decodedBytes),
      );
    } catch (e) {
      print("Error al decodificar la imagen: $e");
      return Icon(Icons.error, color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.brown[700]),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Notificaciones',
          style: TextStyle(
            fontSize: 20,
            color: Colors.brown[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotificaciones,
        child: FutureBuilder<List<Notificacion>>(
          future: _futureNotificaciones,
          builder: (BuildContext context,
              AsyncSnapshot<List<Notificacion>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              String errorMessage = 'Error al cargar las notificaciones.';
              if (snapshot.error is Exception) {
                errorMessage = (snapshot.error as Exception).toString();
              }
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 60),
                      SizedBox(height: 16),
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 16, color: Colors.brown[700]),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasData) {
              final notifications = snapshot.data!;
              if (notifications.isEmpty) {
                return Center(
                  child: Text(
                    'Aún no hay notificaciones.',
                    style: TextStyle(fontSize: 18, color: Colors.brown[700]),
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (BuildContext context, int index) {
                    final notificacion = notifications[index];
                    return ListTile(
                      leading: _buildAvatarFromBase64(notificacion.foto),
                      title: Text(
                        notificacion.contenido,
                        style: TextStyle(color: Colors.brown[700]),
                      ),
                      subtitle: Text(
                        'Recibido el ${notificacion.mensajeLlegada.toLocal()}',
                        style: TextStyle(color: Colors.grey),
                      ),
                      trailing: notificacion.leido
                          ? Icon(Icons.check, color: Colors.green)
                          : Icon(Icons.circle, color: Colors.red, size: 12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DogDetailScreen(
                              dog: Data(
                                id: notificacion.idMascota,
                                nombre: notificacion.contenido,
                                edad: 0, // Reemplaza con la edad real
                                raza: '', // Reemplaza con la raza real
                                sexo: '', // Reemplaza con el sexo real
                                color: '', // Reemplaza con el color real
                                vacunas: '', // Reemplaza con las vacunas reales
                                caracteristicas: '', // Reemplaza con las características reales
                                certificado: '', // Reemplaza con el certificado real
                                fotos: notificacion.foto,
                                comportamiento: '', // Reemplaza con el comportamiento real
                                idUsuario: notificacion.idUsuario,
                                distancia: '', // Reemplaza con la distancia real
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              }
            }
            return Center(
              child: Text(
                'Aún no hay notificaciones.',
                style: TextStyle(fontSize: 18, color: Colors.brown[700]),
              ),
            );
          },
        ),
      ),
      backgroundColor: Color(0xFFF9F6E8),
    );
  }
}