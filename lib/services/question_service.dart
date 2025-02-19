import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question_model.dart';
import '../models/reponse_model.dart';

class QuestionService {
  final String baseUrl = "http://192.168.1.81:3000/api"; // Remplacez par votre URL d'API

  // Récupérer le token d'authentification
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // Enregistrer un nouveau token
  Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

  // Obtenir toutes les questions
  Future<List<Question>> getAllQuestions() async {
    final token = await getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/questions'),
      headers: {
        'Authorization': 'Bearer $token', // Ajouter le token dans les headers
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Question.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des questions');
    }
  }

  // Obtenir une question par ID
  Future<Question> getQuestionById(String id) async {
    final token = await getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/questions/$id'),
      headers: {
        'Authorization': 'Bearer $token', // Ajouter le token dans les headers
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Question.fromJson(data);
    } else {
      throw Exception('Erreur lors du chargement de la question');
    }
  }

  Future<Question> createQuestion(Question question) async {
  final token = await getAuthToken();
  final url = '$baseUrl/questions';



  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: json.encode(question.toJson()),
  );

  

  // Vérification des erreurs et du statut HTTP
  if (response.statusCode == 201) {
    final responseBody = json.decode(response.body);
    
    // Assurez-vous que la réponse contient la clé attendue
    if (responseBody.containsKey('question')) {
      return Question.fromJson(responseBody['question']);
    } else if (responseBody.containsKey('question_text')) {
      return Question.fromJson(responseBody['question_text']);
    } else {
      throw Exception('La réponse de l\'API est inattendue ou mal formée.');
    }
  } else {
    throw Exception('Erreur lors de la création de la question');
  }
}

  // Mettre à jour une question
  Future<Question> updateQuestion(String id, Question question) async {
    final token = await getAuthToken();
    final response = await http.put(
      Uri.parse('$baseUrl/questions/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Ajouter le token dans les headers
      },
      body: json.encode(question.toJson()),
    );

    if (response.statusCode == 200) {
      return Question.fromJson(json.decode(response.body)['question']);
    } else {
      throw Exception('Erreur lors de la mise à jour de la question');
    }
  }

  // Supprimer une question
  Future<void> deleteQuestion(String id) async {
    final token = await getAuthToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/questions/$id'),
      headers: {
        'Authorization': 'Bearer $token', // Ajouter le token dans les headers
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression de la question');
    }
  }


}
