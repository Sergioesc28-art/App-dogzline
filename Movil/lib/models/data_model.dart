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

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUser {
  final String id;
  final String nombreCompleto;
  final String email;
  final String? photoUrl;
  final DateTime ultimaConexion;
  final bool online;

  ChatUser({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    this.photoUrl,
    required this.ultimaConexion,
    this.online = false,
  });

  factory ChatUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatUser(
      id: doc.id,
      nombreCompleto: data['nombreCompleto'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      ultimaConexion: (data['ultimaConexion'] as Timestamp).toDate(),
      online: data['online'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombreCompleto': nombreCompleto,
      'email': email,
      'photoUrl': photoUrl,
      'ultimaConexion': Timestamp.fromDate(ultimaConexion),
      'online': online,
    };
  }
}

class ChatRoom {
  final String id;
  final List<String> participantes;
  final String? ultimoMensaje;
  final DateTime ultimaActualizacion;
  final Map<String, bool> leido; // {userId: boolean}
  final Map<String, ChatInfo> infoParticipantes; // Metadata por participante

  ChatRoom({
    required this.id,
    required this.participantes,
    this.ultimoMensaje,
    required this.ultimaActualizacion,
    required this.leido,
    required this.infoParticipantes,
  });

  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Convertir el map de info de participantes
    Map<String, ChatInfo> infoMap = {};
    if (data['infoParticipantes'] != null) {
      (data['infoParticipantes'] as Map<String, dynamic>).forEach((key, value) {
        infoMap[key] = ChatInfo.fromMap(value as Map<String, dynamic>);
      });
    }

    return ChatRoom(
      id: doc.id,
      participantes: List<String>.from(data['participantes'] ?? []),
      ultimoMensaje: data['ultimoMensaje'],
      ultimaActualizacion: (data['ultimaActualizacion'] as Timestamp).toDate(),
      leido: Map<String, bool>.from(data['leido'] ?? {}),
      infoParticipantes: infoMap,
    );
  }

  Map<String, dynamic> toFirestore() {
    Map<String, dynamic> infoMap = {};
    infoParticipantes.forEach((key, value) {
      infoMap[key] = value.toMap();
    });

    return {
      'participantes': participantes,
      'ultimoMensaje': ultimoMensaje,
      'ultimaActualizacion': Timestamp.fromDate(ultimaActualizacion),
      'leido': leido,
      'infoParticipantes': infoMap,
    };
  }
}

class ChatInfo {
  final String nombreMascota;
  final String? fotoMascota;
  final DateTime ultimaVezVisto;
  final bool escribiendo;

  ChatInfo({
    required this.nombreMascota,
    this.fotoMascota,
    required this.ultimaVezVisto,
    this.escribiendo = false,
  });

  factory ChatInfo.fromMap(Map<String, dynamic> map) {
    return ChatInfo(
      nombreMascota: map['nombreMascota'] ?? '',
      fotoMascota: map['fotoMascota'],
      ultimaVezVisto: (map['ultimaVezVisto'] as Timestamp).toDate(),
      escribiendo: map['escribiendo'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombreMascota': nombreMascota,
      'fotoMascota': fotoMascota,
      'ultimaVezVisto': Timestamp.fromDate(ultimaVezVisto),
      'escribiendo': escribiendo,
    };
  }
}

class ChatMessage {
  final String id;
  final String roomId;
  final String emisorId;
  final String contenido;
  final String tipo;
  final DateTime timestamp;
  final Map<String, bool> leido;
  final Map<String, DateTime>? fechasLeido;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.emisorId,
    required this.contenido,
    this.tipo = 'texto',
    required this.timestamp,
    required this.leido,
    this.fechasLeido,
    this.metadata,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Convertir el map de fechas de leído
    Map<String, DateTime>? fechasMap;
    if (data['fechasLeido'] != null) {
      fechasMap = {};
      (data['fechasLeido'] as Map<String, dynamic>).forEach((key, value) {
        fechasMap![key] = (value as Timestamp).toDate();
      });
    }

    return ChatMessage(
      id: doc.id,
      roomId: data['roomId'],
      emisorId: data['emisorId'],
      contenido: data['contenido'],
      tipo: data['tipo'] ?? 'texto',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      leido: Map<String, bool>.from(data['leido'] ?? {}),
      fechasLeido: fechasMap,
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    // Convertir el map de fechas para Firestore
    Map<String, Timestamp>? fechasMap;
    if (fechasLeido != null) {
      fechasMap = {};
      fechasLeido!.forEach((key, value) {
        fechasMap![key] = Timestamp.fromDate(value);
      });
    }

    return {
      'roomId': roomId,
      'emisorId': emisorId,
      'contenido': contenido,
      'tipo': tipo,
      'timestamp': Timestamp.fromDate(timestamp),
      'leido': leido,
      'fechasLeido': fechasMap,
      'metadata': metadata,
    };
  }
}