import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reponse_model.dart';

class ResponseService {
  final String baseUrl = "https://soleilmainapi.vercel.app/api"; 

  
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

 
  Future<List<Response>> getAllResponses() async {
    final token = await getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/responses'),
      headers: {
        'Authorization': 'Bearer $token', 
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Response.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des réponses');
    }
  }


  Future<Response> getResponseById(String id) async {
    final token = await getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/responses/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Response.fromJson(data);
    } else {
      throw Exception('Erreur lors du chargement de la réponse');
    }
  }

 Future<List<Response>> getResponsesByQuestionId(String questionId) async {
  try {
    final token = await getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/responses/question/$questionId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Response.fromJson(json)).toList();
    } else {
      throw Exception(
        'Erreur ${response.statusCode}: ${response.body}',
      );
    }
  } catch (e) {
    throw Exception('Échec de la récupération des réponses: $e');
  }
}


Future<Response> createResponse(Response response) async {
  final token = await getAuthToken();
  final responseApi = await http.post(
    Uri.parse('$baseUrl/responses'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', 
    },
    body: json.encode(response.toJson()),
  );

  print('Statut HTTP : ${responseApi.statusCode}');
  print('Réponse brute : ${responseApi.body}');

 
  if (responseApi.statusCode == 201) {
    final responseJson = json.decode(responseApi.body);

    
    if (responseJson['reponse_text'] != null) {
      return Response.fromJson(responseJson['reponse_text']);
    } else {
      throw Exception('Réponse invalide, clé "reponse_text" manquante');
    }
  } else {
    throw Exception('Erreur lors de la création de la réponse');
  }
}


Future<Response> updateResponse(String id, Response response) async {
  if (id.isEmpty) {
    throw Exception('L\'ID de réponse est vide.');
  }

  final token = await getAuthToken();
  final url = '$baseUrl/responses/$id';

  try {
    
    print('Mise à jour de la réponse : $id');
    print('URL: $url');
    print('Token: $token');
    print('Payload: ${response.toJson()}');

    final responseApi = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(response.toJson()),
    );

    if (responseApi.statusCode == 200) {
      print('Mise à jour réussie : ${responseApi.body}');
      return Response.fromJson(json.decode(responseApi.body)['reponse_text']);

    } else {
      print('Erreur API : ${responseApi.statusCode} - ${responseApi.body}');
      throw Exception(
        'Erreur lors de la mise à jour de la réponse : ${responseApi.statusCode} - ${responseApi.reasonPhrase}',
      );
    }
  } catch (e) {
    print('Exception : $e');
    throw Exception('Erreur lors de la mise à jour de la réponse : $e');
  }
}



  Future<void> deleteResponse(String id) async {
    final token = await getAuthToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/responses/$id'),
      headers: {
        'Authorization': 'Bearer $token', 
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression de la réponse');
    }
  }
}
