import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "https://soleilmainapi.vercel.app/api"; 

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
      final userId = responseBody['user_id'];
      final role = responseBody['role']; 

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', token);
      await prefs.setString('userId', userId);
      await prefs.setString('userRole', role);

     
    } else if (response.statusCode == 429) {
      throw Exception('Trop de tentatives de connexion. Réessayez plus tard.');
    } else {
      throw Exception('Échec de la connexion: ${response.statusCode} ${response.body}');
    }
  }

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRole');
  }
}
