// api_service.dart
import 'package:dio/dio.dart';
import '../models/data_model.dart';
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
        print(
            'Response data: ${response.data}'); // Imprime la respuesta completa
        return response.data;
      } else {
        throw Exception('Failed to login: ${response.data['mensaje']}');
      }
    } catch (e) {
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
Future<List<Notificacion>> getNotificaciones(String userId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

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

    print("Respuesta del servidor: ${response.data}"); // Debug

    // Verificar si la respuesta es una lista
    if (response.data is List) {
      List<Notificacion> notificaciones = (response.data as List)
          .map((json) => Notificacion.fromJson(json))
          .toList();
      return notificaciones;
    } else {
      throw Exception('Error: La respuesta no es una lista de notificaciones');
    }
  } catch (e) {
    print('Error detallado: $e');
    throw Exception('Error al obtener notificaciones: $e');
  }
}
  // Crear una nueva notificación
  Future<Notificacion> createNotificacion(Notificacion notificacion) async {
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

      if (response.statusCode == 201) {
        return Notificacion.fromJson(response.data);
      } else {
        throw Exception('Error al crear la notificación');
      }
    } catch (e) {
      throw Exception('Error al crear la notificación: $e');
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
}
