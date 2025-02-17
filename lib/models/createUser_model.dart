// models/userModel.dart
class UserModel {
  String email;
  String role;

  UserModel({required this.email, required this.role});

  // Méthode pour convertir un utilisateur en Map
  Map<String, dynamic> toMap() {
    return {'email': email, 'role': role};
  }

  // Méthode pour créer un utilisateur depuis un Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'],
      role: map['role'],
    );
  }
}
