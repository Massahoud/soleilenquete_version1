import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'dart:html' as html;

import 'package:http_parser/http_parser.dart';
import '../models/survey_model.dart';

class SurveyService {
  final String baseUrl = "http://192.168.1.81:3000/api"; // Remplace par l'URL de ton API

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

 Future<void> sendResponses(String surveyId, List<Map<String, dynamic>> responses) async {
  final url = Uri.parse('$baseUrl/surveys/Reponse');

  final authToken = await getAuthToken();
  final headers = {
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };


  final responsesWithSurveyId = responses.map((response) {
    return {
      ...response,
      'enquete_id': surveyId, 
    };
  }).toList();

  try {
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'responses': responsesWithSurveyId}),
    );

    if (response.statusCode == 200) {
      print("Réponses envoyées avec succès !");
    } else {
      print("Erreur lors de l'envoi des réponses: ${response.body}");
    }
  } catch (e) {
    print("Erreur de connexion : $e");
  }
}




Future<String?> createSurvey(SurveyModel survey, html.File? imageFile) async {
  final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/surveys'));

  final authToken = await getAuthToken();
  if (authToken != null) {
    request.headers['Authorization'] = 'Bearer $authToken';
  } else {
    print("Avertissement : Aucun token trouvé !");
  }

  Map<String, dynamic> geolocalisation = {
    'latitude': survey.latitude,
    'longitude': survey.longitude,
  };

  if (geolocalisation['latitude'] is! double) {
    geolocalisation['latitude'] = double.tryParse(survey.latitude.toString()) ?? 0.0;
  }
  if (geolocalisation['longitude'] is! double) {
    geolocalisation['longitude'] = double.tryParse(survey.longitude.toString()) ?? 0.0;
  }

  request.fields['numero'] = survey.numero.toString();
  request.fields['age_enfant'] = survey.ageEnfant.toString();
  request.fields['latitude'] = geolocalisation['latitude'].toString();
  request.fields['longitude'] = geolocalisation['longitude'].toString();
  request.fields['prenom_enqueteur'] = survey.prenomEnqueteur;
  request.fields['nom_enqueteur'] = survey.nomEnqueteur;
  request.fields['prenom_enfant'] = survey.prenomEnfant;
  request.fields['nom_enfant'] = survey.nomEnfant;
  request.fields['sexe_enfant'] = survey.sexeEnfant;
  request.fields['contact_enfant'] = survey.contactEnfant;
  request.fields['nomcontact_enfant'] = survey.nomContactEnfant;
  request.fields['lieuenquete'] = survey.lieuEnquete;
request.fields['avis_enqueteur']= survey.avisEnqueteur;
  request.fields['geolocalisation'] = jsonEncode(geolocalisation);

  if (imageFile != null) {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(imageFile);
    await reader.onLoadEnd.first;

    final bytes = reader.result as List<int>;
    request.files.add(http.MultipartFile.fromBytes(
      'photo_url',
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
        final surveyId = jsonResponse['survey']['id'];
        print("ID de l'enquête créée : $surveyId");

        return surveyId;
      } else {
        throw Exception('Format de réponse invalide: $responseBody');
      }
    } else {
      throw Exception('Échec de la création du survey: ${response.statusCode} $responseBody');
    }
  } catch (e) {
    print('Erreur lors de la création du survey: $e');
    return null;
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
