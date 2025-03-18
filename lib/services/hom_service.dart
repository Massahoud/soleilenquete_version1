import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

 Future<String?> getUserRole() async {
    final authToken = await getAuthToken();
    if (authToken == null) return null;

    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(authToken);
      return decodedToken['role'];
    } catch (e) {
      print('Erreur lors du décodage du token: $e');
      return null;
    }
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }