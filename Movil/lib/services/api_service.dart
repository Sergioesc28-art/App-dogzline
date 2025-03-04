import 'package:dio/dio.dart';
import '../models/data_model.dart';
import '../models/message_model.dart'; // Importa message_model.dart
import 'package:shared_preferences/shared_preferences.dart'; // Importa shared_preferences
import 'package:flutter/material.dart';

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
        print('Response data: ${response.data}'); // Imprime la respuesta completa
        return response.data;
      } else {
        throw Exception('Failed to login: ${response.data['mensaje']}');
      }
    } catch (e) {
      throw Exception('Error de inicio de sesión: $e');
    }
  }

  // Método de registro
  Future<void> register(String nombreCompleto, String email, String contrasena, String role) async {
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
        throw Exception('Error: La respuesta no es una lista de notificaciones');
      }
    } catch (e) {
      print('Error obteniendo notificaciones: $e');
      rethrow;
    }
  }
  // Crear una nueva notificación
  Future<Notificacion?> createNotificacion(Notificacion notificacion) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token no encontrado');
      }

      final response = await _dio.post(
        'https://dogzline-1.onrender.com/api/notificaciones',
        data: notificacion.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
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

  // Método para dar like
  Future<void> darLike(String userId, String idMascotaLiked) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token no encontrado');
      }

      await _dio.post(
        'https://tu-api-url.com/api/encuentros/like',
        options: Options(headers: { 'Authorization': 'Bearer $token' }),
        data: { 'idMascotaLiked': idMascotaLiked },
      );
    } catch (e) {
      throw Exception('Error al enviar el like: $e');
    }
  }

  Future<List<dynamic>> getMatchesByUser(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token no encontrado');
      }

      final response = await _dio.get(
        'https://dogzline-1.onrender.com/api/matches/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data; // Asegúrate de mapear esto si tienes un modelo de Match
      } else {
        throw Exception('Error al obtener los matches');
      }
    } catch (e) {
      throw Exception('Error al obtener los matches: $e');
    }
  }
  // Método para guardar un mensaje
  Future<void> guardarMensaje(String chatId, String senderId, String content) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token no encontrado');
      }

      final response = await _dio.post(
        'https://dogzline-1.onrender.com/api/mensajes', // Verifica que esta URL sea correcta
        data: {
          'chatId': chatId,
          'senderId': senderId,
          'content': content,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode != 201) {
        throw Exception('Error al guardar el mensaje');
      }
    } catch (e) {
      throw Exception('Error al guardar el mensaje: $e');
    }
  }

  // Método para recuperar mensajes de un chat
  Future<List<Message>> obtenerMensajes(String chatId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token no encontrado');
      }

      final response = await _dio.get(
        'https://dogzline-1.onrender.com/api/mensajes/$chatId', // Verifica que esta URL sea correcta
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        List<Message> mensajes = (response.data as List)
            .map((json) => Message.fromJson(json))
            .toList();
        return mensajes;
      } else {
        throw Exception('Error al obtener los mensajes');
      }
    } catch (e) {
      throw Exception('Error al obtener los mensajes: $e');
    }
  }
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

  Future<List<Data>> getLikesDeMascota(String dogId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token no encontrado');
      }

      final response = await _dio.get(
        'https://tu-api-url.com/api/encuentros/likes/$dogId',
        options: Options(headers: { 'Authorization': 'Bearer $token' }),
      );

      if (response.statusCode == 200) {
        return (response.data['likes'] as List)
            .map((like) => Data.fromJson(like))
            .toList();
      } else {
        throw Exception('Error al obtener los likes');
      }
    } catch (e) {
      throw Exception('Error al obtener los likes: $e');
    }
  }
}


