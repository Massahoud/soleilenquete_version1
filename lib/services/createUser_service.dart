import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String apiUrl = 'https://soleilmainapi.vercel.app/api/sendInvite/invite';

  
  Future<void> sendInvite(String email, String role) async {
    try {
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'statut': role}),
      );

      

      if (response.statusCode == 200) {
        
        
   
        final responseData = json.decode(response.body);
        if (responseData.containsKey('token')) {
          await setAuthToken(responseData['token']);
        }
      } else {
       
        throw Exception("Erreur lors de l'envoi de l'email: \${response.body}");
      }
    } catch (error) {
     
      throw Exception("Erreur lors de l'envoi de l'email: \$error");
    }
  }

 
  Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

  
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }
}
