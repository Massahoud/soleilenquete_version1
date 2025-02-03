import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soleilenquete/models/user_model.dart';
import 'package:http_parser/http_parser.dart';

import 'package:cloud_firestore/cloud_firestore.dart';  // Importez Firestore
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
class UserService {
  final String baseUrl = "http://192.168.1.68:3000/api"; // Replace with your API URL

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
      'photo', // Nom du champ pour le fichier côté backend
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
    // Référence au document utilisateur dans Firestore
    var userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    // Récupération du document utilisateur
    var userDoc = await userRef.get();

    if (userDoc.exists) {
      // Vérifier si l'utilisateur a déjà un groupe
      var userData = userDoc.data();
      var currentGroups = userData?['groupe'] ?? '';  // Si pas de groupe, initialise comme chaîne vide

      // Vérifier si le groupe existe déjà dans la chaîne
      if (currentGroups.contains(groupName)) {
        print("L'utilisateur $userId est déjà membre du groupe $groupName");
      } else {
        // Ajouter le groupe à la chaîne en séparant par une virgule
        String updatedGroups = currentGroups.isEmpty ? groupName : '$currentGroups,$groupName';
        
        // Mettre à jour l'utilisateur avec le nouveau groupe
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
  final authToken = await getAuthToken();
  if (authToken == null) {
    throw Exception('No auth token found');
  }

  // Vérification que l'ID de l'utilisateur dans les données correspond à celui dans l'URL
  if (user.id != id) {
    throw Exception('User ID mismatch: The ID in the request body does not match the ID in the URL.');
  }

  // Affiche les informations reçues avant d'envoyer la requête
  print('User ID: $id');
  print('Nom: ${user.nom}');
  print('Prénom: ${user.prenom}');
  print('Email: ${user.email}');
  print('Mot de passe: ${user.motDePasse}');
  print('Téléphone: ${user.telephone}');
  print('Statut: ${user.statut}');
  print('Groupe: ${user.groupe}');

  // Prépare le corps de la requête en utilisant jsonEncode
  final requestBody = jsonEncode({
    'nom': user.nom,
    'prenom': user.prenom,
    'email': user.email,
    'mot_de_passe': user.motDePasse,
    'telephone': user.telephone,
    'statut': user.statut,
    'groupe': user.groupe,
  });

  final response = await http.put(
    Uri.parse('$baseUrl/users/$id'),
    headers: {
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'application/json', // Indique que c'est un corps JSON
    },
    body: requestBody, // Corps de la requête
  );

  try {
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse.containsKey('user')) {
        return UserModel.fromJson(jsonResponse['user']);
      } else {
        throw Exception('Invalid response format: ${response.body}');
      }
    } else {
      throw Exception('Failed to update user: ${response.statusCode} ${response.body}');
    }
  } catch (e) {
    print('Error updating user: $e');
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