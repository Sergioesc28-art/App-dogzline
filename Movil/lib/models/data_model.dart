class User {
  final String email;
  final String contrasena;
  final String token;
  final String role;
  final String nombreCompleto;  // Nuevo campo agregado

  User({
    required this.email,
    required this.token,
    required this.role,
    required this.contrasena,
    required this.nombreCompleto,  // Incluir en el constructor
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      token: json['token'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      contrasena: json['contrasena'] ?? '',
      nombreCompleto: json['NombreCompleto'] ?? '',  // Asegúrate de que el campo coincide con el JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'email': email,
      'role': role,
      'contrasena': contrasena,
      'NombreCompleto': nombreCompleto,  // Incluir en el JSON
    };
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
      '_id': id,
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
  final String idMascota; // Changed from Data? to String
  final DateTime mensajeLlegada;
  final String contenido;
  bool leido;
  final String? foto;

  Notificacion({
    this.id = '', // Default empty string
    required this.idUsuario,
    required this.idMascota,
    required this.mensajeLlegada,
    required this.contenido,
    this.leido = false,
    this.foto,
  });

  // Add this method to resolve the fromJson error
  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['_id']?.toString() ?? '',
      idUsuario: json['id_usuario']?.toString() ?? '',
      idMascota: json['id_mascota']?.toString() ?? '',
      mensajeLlegada: json['mensaje_llegada'] != null 
          ? DateTime.parse(json['mensaje_llegada']) 
          : DateTime.now(),
      contenido: json['contenido'] ?? '',
      leido: json['leido'] ?? false,
      foto: json['foto']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id_usuario': idUsuario,
      'id_mascota': idMascota,
      'mensaje_llegada': mensajeLlegada.toIso8601String(),
      'contenido': contenido,
      'leido': leido,
      'foto': foto,
    };
  }
}

class Match {
  final String id;
  final String idMascota1;
  final String idMascota2;
  final DateTime fechaMatch;

  Match({
    required this.id,
    required this.idMascota1,
    required this.idMascota2,
    required this.fechaMatch,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['_id'],
      idMascota1: json['id_mascota1'],
      idMascota2: json['id_mascota2'],
      fechaMatch: DateTime.parse(json['fecha_match']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id_mascota1': idMascota1,
      'id_mascota2': idMascota2,
      'fecha_match': fechaMatch.toIso8601String(),
    };
  }
}

class Conversacion {
  final String id;
  final List<String> participantes;
  final String? ultimoMensaje;
  final DateTime fechaActualizacion;

  Conversacion({
    required this.id,
    required this.participantes,
    this.ultimoMensaje,
    required this.fechaActualizacion,
  });

  factory Conversacion.fromJson(Map<String, dynamic> json) {
    return Conversacion(
      id: json['_id'],
      participantes: List<String>.from(json['participantes']),
      ultimoMensaje: json['ultimo_mensaje'],
      fechaActualizacion: DateTime.parse(json['fecha_actualizacion']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'participantes': participantes,
      'ultimo_mensaje': ultimoMensaje,
      'fecha_actualizacion': fechaActualizacion.toIso8601String(),
    };
  }
}

class Mensaje {
  final String id;
  final String idConversacion;
  final String emisor;
  final String receptor;
  final String contenido;
  final String tipo;
  final bool leido;
  final DateTime fechaCreacion;
  final DateTime? fechaLeido;

  Mensaje({
    required this.id,
    required this.idConversacion,
    required this.emisor,
    required this.receptor,
    required this.contenido,
    this.tipo = 'texto',
    this.leido = false,
    required this.fechaCreacion,
    this.fechaLeido,
  });

  factory Mensaje.fromJson(Map<String, dynamic> json) {
    return Mensaje(
      id: json['_id'],
      idConversacion: json['id_conversacion'],
      emisor: json['emisor'],
      receptor: json['receptor'],
      contenido: json['contenido'],
      tipo: json['tipo'] ?? 'texto',
      leido: json['leido'] ?? false,
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
      fechaLeido: json['fecha_leido'] != null ? DateTime.parse(json['fecha_leido']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id_conversacion': idConversacion,
      'emisor': emisor,
      'receptor': receptor,
      'contenido': contenido,
      'tipo': tipo,
      'leido': leido,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_leido': fechaLeido?.toIso8601String(),
    };
  }
}