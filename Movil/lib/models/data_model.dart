// data_model.dart
class User {
  final String token; // Token para autenticación

  User({
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      token: json['token'] ?? '', // Asegúrate de que el campo 'token' exista en la respuesta de tu API
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
  final String vacunas;       // Cambiado a String para coincidir con el backend
  final String caracteristicas;
  final String certificado;   // Cambiado a String para coincidir con el backend
  final String fotos;        // Cambiado a String para coincidir con el backend
  final String comportamiento; // Nota: en el backend es 'Comportamiento' con mayúscula
  final String idUsuario;

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
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['_id'] ?? '',
      nombre: json['nombre'] ?? '',
      edad: json['edad'] ?? 0,
      raza: json['raza'] ?? '',
      sexo: json['sexo'] ?? '',
      color: json['color'] ?? '',
      vacunas: json['vacunas'] ?? '',
      caracteristicas: json['caracteristicas'] ?? '',
      certificado: json['certificado'] ?? '',
      fotos: json['fotos'] ?? '',
      comportamiento: json['Comportamiento'] ?? '', // Nota la mayúscula
      idUsuario: json['id_usuario'] ?? '',
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
    'Comportamiento': comportamiento, // Asegúrate de que sea con mayúscula
    'id_usuario': idUsuario,
  };
}
}