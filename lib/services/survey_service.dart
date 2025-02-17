import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:html' as html;

import 'package:http_parser/http_parser.dart';
import '../models/survey_model.dart';

class SurveyService {
  final String baseUrl = "http://192.168.1.98:3000/api"; // Remplace par l'URL de ton API

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

 Future<List<SurveyModel>> getAllSurveys() async {
  final authToken = await getAuthToken();
  if (authToken == null) {
    throw Exception('Erreur : Aucun token d’authentification trouvé');
  }

  try {
    final response = await http.get(
      Uri.parse('$baseUrl/surveys'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => SurveyModel.fromJson(json)).toList();
    } else {
      throw Exception(
          'Erreur ${response.statusCode}: ${jsonDecode(response.body)['message'] ?? 'Impossible de récupérer les enquêtes'}');
    }
  } catch (e) {
    print('[getAllSurveys] Erreur: $e');
    rethrow;
  }
}


  Future<SurveyModel> getSurveyById(String id) async {
    final authToken = await getAuthToken();
    if (authToken == null) {
      throw Exception('No auth token found');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/surveys/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );
      if (response.statusCode == 200) {
        return SurveyModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch survey: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching survey: $e');
      rethrow;
    }
  }

Future<SurveyModel> createSurvey(SurveyModel survey, html.File? imageFile) async {
  final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/surveys'));

  // Ajouter les champs textuels du survey
  request.fields['numero'] = survey.numero;
  request.fields['prenomEnqueteur'] = survey.prenomEnqueteur;
  request.fields['nomEnqueteur'] = survey.nomEnqueteur;
  request.fields['prenomEnfant'] = survey.prenomEnfant;
  request.fields['nomEnfant'] = survey.nomEnfant;
  request.fields['sexeEnfant'] = survey.sexeEnfant;
  request.fields['contactEnfant'] = survey.contactEnfant;
  request.fields['nomContactEnfant'] = survey.nomContactEnfant;
  request.fields['ageEnfant'] = survey.ageEnfant;
  request.fields['lieuEnquete'] = survey.lieuEnquete;
  
  request.fields['latitude'] = survey.latitude.toString();
  request.fields['longitude'] = survey.longitude.toString();

  // Ajouter l'image si elle existe
  if (imageFile != null) {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(imageFile);
    await reader.onLoadEnd.first;

    final bytes = reader.result as List<int>;
    request.files.add(http.MultipartFile.fromBytes(
      'photo_url', // Nom du champ pour le fichier côté backend
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
      if (jsonResponse.containsKey('survey')) {
        return SurveyModel.fromJson(jsonResponse['survey']);
      } else {
        throw Exception('Format de réponse invalide: $responseBody');
      }
    } else {
      throw Exception('Échec de la création du survey: ${response.statusCode} $responseBody');
    }
  } catch (e) {
    print('Erreur lors de la création du survey: $e');
    rethrow;
  }
}



  Future<SurveyModel> updateSurvey(String id, SurveyModel survey) async {
    final authToken = await getAuthToken();
    if (authToken == null) {
      throw Exception('No auth token found');
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/surveys/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(survey.toJson()),
      );
      if (response.statusCode == 200) {
        return SurveyModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update survey: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error updating survey: $e');
      rethrow;
    }
  }

  Future<void> deleteSurvey(String id) async {
    final authToken = await getAuthToken();
    if (authToken == null) {
      throw Exception('No auth token found');
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/surveys/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to delete survey: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error deleting survey: $e');
      rethrow;
    }
  }
}
