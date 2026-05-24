class UsuarioModel {
  final int id;
  final String email;
  final String nombre;
  final String? apellido;
  final String? fotoUrl;

  const UsuarioModel({
    required this.id,
    required this.email,
    required this.nombre,
    this.apellido,
    this.fotoUrl,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) => UsuarioModel(
    id: json['id'],
    email: json['email'],
    nombre: json['nombre'],
    apellido: json['apellido'],
    fotoUrl: json['fotoUrl'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'nombre': nombre,
    'apellido': apellido,
    'fotoUrl': fotoUrl,
  };
}
