class User {
  final String email;
  final String contrasena;
  final String token;
  final String role;

  User({
    required this.email,
    required this.token,
    required this.role,
    required this.contrasena,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      token: json['token'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      contrasena: json['contraseña'] ?? '',
    );
  }
}

class Data {
  final String id;
  final String nombre;
  final int edad;
  final String raza;
  final String sexo;
  final String color;
  final String vacunas;
  final String caracteristicas;
  final String certificado;
  final String? fotos;
  final String comportamiento;
  final String idUsuario;
  final String distancia;

  Data({
    required this.id,
    required this.nombre,
    required this.edad,
    required this.raza,
    required this.sexo,
    required this.color,
    required this.vacunas,
    required this.caracteristicas,
    required this.certificado,
    required this.fotos,
    required this.comportamiento,
    required this.idUsuario,
    required this.distancia,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    String getId() {
      if (json['_id'] is Map && json['_id']['\$oid'] != null) {
        return json['_id']['\$oid'];
      }
      return json['_id']?.toString() ?? '';
    }

    String getUserId() {
      if (json['id_usuario'] is Map && json['id_usuario']['\$oid'] != null) {
        return json['id_usuario']['\$oid'];
      }
      return json['id_usuario']?.toString() ?? '';
    }

    return Data(
      id: getId(),
      nombre: json['nombre'] ?? '',
      edad: json['edad'] ?? 0, // Si no viene, usa 0
      raza: json['raza'] ?? '',
      sexo: json['sexo'] ?? '',
      color: json['color'] ?? '',
      vacunas: json['vacunas'] ?? '',
      caracteristicas: json['caracteristicas'] ?? '',
      certificado: json['certificado'] ?? '',
      fotos: json['fotos'] as String?,
      comportamiento: json['Comportamiento'] ?? '',
      idUsuario: getUserId(),
      distancia: json['distancia'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'edad': edad,
      'raza': raza,
      'sexo': sexo,
      'color': color,
      'vacunas': vacunas,
      'caracteristicas': caracteristicas,
      'certificado': certificado,
      'fotos': fotos,
      'Comportamiento': comportamiento,
      'id_usuario': idUsuario,
      'distancia': distancia,
    };
  }
}

class Notificacion {
  final String id;
  final String idUsuario;
  final Data? idMascota; // Usaremos Data para representar idMascota
  final DateTime mensajeLlegada;
  final String contenido;
  bool leido;
  final String? foto;

  Notificacion({
    required this.id,
    required this.idUsuario,
    this.idMascota,
    required this.mensajeLlegada,
    required this.contenido,
    this.leido = false,
    this.foto,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['_id']?.toString() ?? '',
      idUsuario: json['id_usuario']?.toString() ?? '',
      idMascota: json['id_mascota'] is Map<String, dynamic> // Verifica si es un objeto
          ? Data.fromJson(json['id_mascota'])
          : null, // Si es un string, lo ignora o lo maneja de otra forma
      mensajeLlegada: DateTime.parse(json['mensaje_llegada'] ?? DateTime.now().toIso8601String()),
      contenido: json['contenido'] ?? '',
      leido: json['leido'] ?? false,
      foto: json['foto']?.toString(),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id_usuario': idUsuario,
      'id_mascota': idMascota?.toJson(), // Utilizando el método toJson() de Data
      'mensaje_llegada': mensajeLlegada.toIso8601String(),
      'contenido': contenido,
      'leido': leido,
      'foto': foto,
    };
  }
}
class Match {
  final String id;
  final String idUsuario1;
  final String nombreUsuario1;
  final String idUsuario2;
  final String nombreUsuario2;
  final String idEncuentro;
  final DateTime fechaMatch;

  Match({
    required this.id,
    required this.idUsuario1,
    required this.nombreUsuario1,
    required this.idUsuario2,
    required this.nombreUsuario2,
    required this.idEncuentro,
    required this.fechaMatch,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['_id'],
      idUsuario1: json['id_usuario1']['_id'],  // Ahora es un objeto con los datos del usuario
      nombreUsuario1: json['id_usuario1']['nombre'],
      idUsuario2: json['id_usuario2']['_id'],
      nombreUsuario2: json['id_usuario2']['nombre'],
      idEncuentro: json['id_encuentro'],
      fechaMatch: DateTime.parse(json['fecha_match']),
    );
  }
}
