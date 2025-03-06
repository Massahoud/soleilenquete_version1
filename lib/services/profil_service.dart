import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soleilenquete/models/user_model.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/material.dart'; 
class ProfilService {
  final String baseUrl = "https://soleilmainapi.vercel.app/api";
  final BuildContext context;

  ProfilService(this.context); 

  
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

 
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken'); // Suppression du token
    Navigator.pushNamedAndRemoveUntil(
        context, '/login', (route) => false); // Redirection vers login
  }
  Future<String?> getUserRole() async {
    final authToken = await _getAuthToken();
    if (authToken == null) {
      return null;
    }
  
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(authToken);
      return decodedToken['role']; 
    } catch (e) {
      print('Erreur lors du décodage du token: $e');
      _redirectToLogin();  
      return null;
    }
  }

 
  Future<String?> getUserIdFromToken() async {
    final authToken = await _getAuthToken();
    if (authToken == null) {
      print("Token non trouvé");
      _redirectToLogin(); 
      throw Exception('Aucun token d\'authentification trouvé');
    }

    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(authToken);
      return decodedToken['userId']; 
    } catch (e) {
      print('Erreur lors du décodage du token: $e');
      _redirectToLogin(); 
      throw Exception('Impossible de récupérer l\'ID utilisateur');
    }
  }

  
  Future<UserModel> getUserById() async {
    final id = await getUserIdFromToken();
    if (id == null) {
      throw Exception('Impossible de récupérer l\'ID utilisateur à partir du token');
    }

    final authToken = await _getAuthToken();
    if (authToken == null) {
      throw Exception('Aucun token d\'authentification trouvé');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );
      
      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Authentification échouée. Veuillez vérifier votre token.');
      } else {
        throw Exception('Échec de la récupération de l\'utilisateur: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur: $e');
      rethrow;
    }
  }

 
  void _redirectToLogin() {
    Navigator.pushReplacementNamed(context, '/login'); 
  }
}
