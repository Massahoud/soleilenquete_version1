import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "http://192.168.1.68:3000/api"; // Remplacez par l'URL de votre API

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'mot_de_passe': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final token = responseBody['token'];
      final userId = responseBody['user_id']; // Suppose que l'ID utilisateur est renvoyé sous 'user_id'
      
      // Enregistrer le token et l'ID de l'utilisateur dans les préférences partagées
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', token);
      await prefs.setString('userId', userId);

      print('Connexion réussie : Token et ID utilisateur enregistrés.');
    } else {
      throw Exception('Failed to login: ${response.statusCode} ${response.body}');
    }
  }
}
