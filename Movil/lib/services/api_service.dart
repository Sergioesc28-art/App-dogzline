import 'package:dio/dio.dart';
import '../models/data_model.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importa shared_preferences

class ApiService {
  final Dio _dio = Dio();

  // Método de inicio de sesión
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post(
        'https://dogzline-1.onrender.com/api/login',
        data: {
          'email': username,
          'contraseña': password,
        },
      );

      if (response.statusCode == 200) {
        print(
            'Response data: ${response.data}'); // Imprime la respuesta completa
        return response.data;
      } else {
        print(
            'Error: ${response.data['mensaje']}'); // Imprime el mensaje de error
        throw Exception('Failed to login: ${response.data['mensaje']}');
      }
    } catch (e) {
      print('Error de inicio de sesión: $e'); // Imprime el error
      throw Exception('Error de inicio de sesión: $e');
    }
  }

  // Método de registro
  Future<void> register(String nombreCompleto, String email, String contrasena,
      String role) async {
    try {
      final response = await _dio.post(
        'https://dogzline-1.onrender.com/api/usuarios',
        data: {
          'NombreCompleto': nombreCompleto,
          'email': email,
          'contraseña': contrasena,
          'role': role,
        },
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to register: ${response.data['mensaje']}');
      }
    } catch (e) {
      throw Exception('Error al registrar: $e');
    }
  }

  // Método para crear una nueva mascota
  Future<Data> createMascota(Data mascota) async {
    try {
      // Obtener el token de SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token no encontrado');
      }

      final response = await _dio.post(
        'https://dogzline-1.onrender.com/api/mascotas',
        data: mascota.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 201) {
        return Data.fromJson(response.data);
      } else {
        throw Exception('Failed to create pet: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Error al crear la mascota: $e');
    }
  }

  // Método para obtener las mascotas de un usuario
  Future<List<Data>> getMascotasByUser(int page, int limit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token no encontrado');
      }

      final response = await _dio.get(
        'https://dogzline-1.onrender.com/api/mascotas/usuario',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        List<Data> mascotas = (response.data['mascotas'] as List)
            .map((json) => Data.fromJson(json))
            .toList();
        return mascotas;
      } else {
        throw Exception('Error al obtener las mascotas');
      }
    } catch (e) {
      throw Exception('Error al obtener las mascotas: $e');
    }
  }

  // Método para obtener todas las mascotas
  Future<List<Data>> getDogs({int page = 1, int limit = 10}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token no encontrado');
      }

      final response = await _dio.get(
        'https://dogzline-1.onrender.com/api/mascotas',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        List<Data> dogs = (response.data['mascotas'] as List)
            .map((json) => Data.fromJson(json))
            .toList();
        return dogs;
      } else {
        throw Exception('Error al obtener las mascotas');
      }
    } catch (e) {
      throw Exception('Error al obtener las mascotas: $e');
    }
  }

  // Método para obtener las notificaciones de un usuario
  Future<List<Notificacion>> getNotificaciones(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print("Token utilizado: $token");
      print("User ID utilizado: $userId");

      if (token == null) {
        throw Exception('Token no encontrado');
      }

      final response = await _dio.get(
        'https://dogzline-1.onrender.com/api/notificaciones/usuario/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      // Verifica el status de la respuesta
      print("Status Code: ${response.statusCode}");
      print("Response Data: ${response.data}");

      if (response.data is List) {
        List<Notificacion> notificaciones = (response.data as List)
            .map((json) => Notificacion.fromJson(json))
            .toList();
        return notificaciones;
      } else {
        throw Exception(
            'Error: La respuesta no es una lista de notificaciones');
      }
    } catch (e) {
      print('Error obteniendo notificaciones: $e');
      rethrow;
    }
  }

  Future<Notificacion?> createNotificacion(Notificacion notificacion) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token no encontrado');
      }

      // Validación más robusta
      if (notificacion.idUsuario.isEmpty || notificacion.idMascota.isEmpty) {
        throw Exception('IDs no pueden estar vacíos');
      }

      final response = await _dio.post(
        'https://dogzline-1.onrender.com/api/notificaciones',
        data: notificacion.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
        ),
      );

      print("Código de respuesta: ${response.statusCode}");
      print("Respuesta del servidor: ${response.data}");

      if (response.statusCode == 201) {
        return Notificacion.fromJson(response.data);
      } else {
        print("Error al crear notificación: ${response.statusMessage}");
        return null;
      }
    } on DioException catch (e) {
      print('Error de red al crear notificación: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Excepción al crear la notificación: $e');
      return null;
    }
  }

  // Actualizar notificación (marcar como leída)
  Future<void> marcarNotificacionComoLeida(String idNotificacion) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token no encontrado');
      }

      final response = await _dio.put(
        'https://dogzline-1.onrender.com/api/notificaciones/$idNotificacion',
        data: {'leido': true},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar la notificación');
      }
    } catch (e) {
      throw Exception('Error al actualizar la notificación: $e');
    }
  }

  // Método para obtener una mascota por ID
  Future<Data> getDogById(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token no encontrado');
      }

      final response = await _dio.get(
        'https://dogzline-1.onrender.com/api/mascotas/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return Data.fromJson(response.data);
      } else {
        throw Exception('Error al obtener la mascota');
      }
    } catch (e) {
      throw Exception('Error al obtener la mascota: $e');
    }
  }

  darLike(String userId, String idUsuario) {}

  // Método para crear un match
  Future<void> createMatch(Map<String, dynamic> matchData, profile) async {
    try {
      // Obtener el token de SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token no encontrado');
      }

      final response = await _dio.post(
        'https://dogzline-1.onrender.com/api/matchs',
        data: matchData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 201) {
        print("Match creado exitosamente");
      } else {
        print(
            'Error al crear el match: ${response.statusCode} ${response.statusMessage}');
        throw Exception('Error al crear el match');
      }
    } catch (e) {
      print('Error al crear el match: $e');
      throw Exception('Error al crear el match: $e');
    }
  }

  // Método para obtener conversaciones por usuario
 Future<List<Map<String, dynamic>>> getConversacionesByUserId(String userId) async {
  try {
    final response = await _dio.get(
      'https://dogzline-1.onrender.com/api/conversaciones/$userId',
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(response.data);
    } else {
      throw Exception('Error al obtener las conversaciones');
    }
  } catch (e) {
    throw Exception('Error al obtener las conversaciones: $e');
  }
}

  // Método para enviar un mensaje
  Future<void> createMensaje(Map<String, dynamic> mensajeData) async {
    try {
      final response = await _dio.post(
        'https://dogzline-1.onrender.com/api/mensajes',
        data: mensajeData,
      );

      if (response.statusCode != 201) {
        throw Exception('Error al enviar el mensaje');
      }
    } catch (e) {
      throw Exception('Error al enviar el mensaje: $e');
    }
  }

  // Método para obtener mensajes por usuario
  Future<List<dynamic>> getMensajesByUserId(String userId) async {
    try {
      final response = await _dio.get(
        'https://dogzline-1.onrender.com/api/mensajes/$userId',
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error al obtener los mensajes');
      }
    } catch (e) {
      throw Exception('Error al obtener los mensajes: $e');
    }
  }

// Método para obtener mensajes por ID de conversación
  Future<List<dynamic>> getMensajesByConversacion(String conversacionId) async {
    try {
      final response = await _dio.get(
        'https://dogzline-1.onrender.com/api/mensajes/conversacion/$conversacionId',
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error al obtener los mensajes de la conversación');
      }
    } catch (e) {
      throw Exception('Error al obtener los mensajes de la conversación: $e');
    }
  }

 Future<String> createConversacion(List<String> participantes) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token no encontrado');
    }

    final response = await _dio.post(
      'https://dogzline-1.onrender.com/api/conversaciones',
      data: {'participantes': participantes},
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    print("Código de respuesta: ${response.statusCode}");
    print("Respuesta del servidor: ${response.data}");

    if (response.statusCode == 201 || response.statusCode == 200) {
      return response.data['_id']; // Retornar el ID de la conversación creada
    } else {
      throw Exception('Error al crear la conversación: ${response.statusCode} ${response.statusMessage}');
    }
  } catch (e) {
    print("Error al crear la conversación: $e");
    throw Exception('Error al crear la conversación: $e');
  }
}
}
