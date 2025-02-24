// models/userModel.dart
class UserModel {
  String email;
  String role;

  UserModel({required this.email, required this.role});

  
  Map<String, dynamic> toMap() {
    return {'email': email, 'role': role};
  }

 
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'],
      role: map['role'],
    );
  }
}
