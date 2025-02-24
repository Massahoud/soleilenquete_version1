import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soleilenquete/models/user_model.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
class UserService {
  final String baseUrl = "https://soleilmainapi.vercel.app/api";


Future<String?> getUserRole() async {
  final authToken = await getAuthToken();
  if (authToken == null) {
    return null;
  }
  
  try {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(authToken);
    return decodedToken['role']; 
  } catch (e) {
    print('Error decoding token: $e');
    return null;
  }
}

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

 Future<List<UserModel>> getAllUsers() async {
  final authToken = await getAuthToken();
  if (authToken == null) {
    throw Exception('No auth token found');
  }

  final role = await getUserRole();
  if (role != 'admin') {
    throw Exception('Unauthorized: Only admins can fetch users');
  }

  try {
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((json) => UserModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch users: ${response.statusCode} ${response.body}');
    }
  } catch (e) {
    print('Error fetching users: $e');
    rethrow;
  }
}


  Future<UserModel> getUserById(String id) async {
    final authToken = await getAuthToken();
    if (authToken == null) {
      throw Exception('No auth token found');
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
      } else {
        throw Exception('Failed to fetch user: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching user: $e');
      rethrow;
    }
  }

 Future<UserModel> createUser(UserModel user, html.File? imageFile) async {
  final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/users'));

  request.fields['nom'] = user.nom;
  request.fields['prenom'] = user.prenom;
  request.fields['email'] = user.email;
  request.fields['mot_de_passe'] = user.motDePasse;
  request.fields['telephone'] = user.telephone;
  request.fields['statut'] = user.statut;
  request.fields['groupe'] = user.groupe;

  if (imageFile != null) {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(imageFile);
    await reader.onLoadEnd.first;

    final bytes = reader.result as List<int>;
    request.files.add(http.MultipartFile.fromBytes(
      'photo', 
      bytes,
      filename: imageFile.name,
      contentType: MediaType('image', 'jpeg'),
    ));
  }

  try {
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      final jsonResponse = jsonDecode(responseBody);
      if (jsonResponse.containsKey('user')) {
        return UserModel.fromJson(jsonResponse['user']);
      } else {
        throw Exception('Invalid response format: $responseBody');
      }
    } else {
      throw Exception('Failed to create user: ${response.statusCode} $responseBody');
    }
  } catch (e) {
    print('Error creating user: $e');
    rethrow;
  }
}

Future<void> updateUserGroup(String userId, String groupName) async {
  try {
   
    var userRef = FirebaseFirestore.instance.collection('users').doc(userId);

  
    var userDoc = await userRef.get();

    if (userDoc.exists) {
      
      var userData = userDoc.data();
      var currentGroups = userData?['groupe'] ?? '';  

      
      if (currentGroups.contains(groupName)) {
        print("L'utilisateur $userId est déjà membre du groupe $groupName");
      } else {
       
        String updatedGroups = currentGroups.isEmpty ? groupName : '$currentGroups,$groupName';
        

        await userRef.update({
          'groupe': updatedGroups,
        });
        print("Groupe ajouté pour l'utilisateur $userId");
      }
    } else {
      print("Utilisateur non trouvé");
    }
  } catch (e) {
    print("Erreur de mise à jour de l'utilisateur : $e");
  }
}
Future<UserModel> updateUser(String id, UserModel user, html.File? imageFile) async {
  final token = await getAuthToken();
  if (token == null) {
    throw Exception('Token d’authentification introuvable.');
  }

  final request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/users/$id'));
  request.headers['Authorization'] = 'Bearer $token';

  request.fields['nom'] = user.nom;
  request.fields['prenom'] = user.prenom;
  request.fields['email'] = user.email;
  request.fields['telephone'] = user.telephone;
  request.fields['statut'] = user.statut;
  request.fields['groupe'] = user.groupe;

  if (imageFile != null) {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(imageFile);
    await reader.onLoadEnd.first;

    final bytes = reader.result as List<int>;
    request.files.add(http.MultipartFile.fromBytes(
      'photo', 
      bytes,
      filename: imageFile.name,
      contentType: MediaType('image', 'jpeg'),
    ));
  }

  try {
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(responseBody);
      if (jsonResponse.containsKey('user')) {
        return UserModel.fromJson(jsonResponse['user']);
      } else {
        throw Exception('Format de réponse invalide: $responseBody');
      }
    } else {
      throw Exception('Échec de la mise à jour de l’utilisateur: ${response.statusCode} $responseBody');
    }
  } catch (e) {
    print('Erreur lors de la mise à jour de l’utilisateur: $e');
    rethrow;
  }
}

  Future<void> deleteUser(String id) async {
    final authToken = await getAuthToken();
    if (authToken == null) {
      throw Exception('No auth token found');
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to delete user: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }
}