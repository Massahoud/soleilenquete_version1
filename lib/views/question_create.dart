import 'package:flutter/material.dart';
import '../services/question_service.dart';
import '../services/response_service.dart';
import '../models/question_model.dart';
import '../models/reponse_model.dart';

class CreateQuestionPage extends StatefulWidget {
  @override
  _CreateQuestionPageState createState() => _CreateQuestionPageState();
}

class _CreateQuestionPageState extends State<CreateQuestionPage> {
  final QuestionService questionService = QuestionService();
  final ResponseService responseService = ResponseService();

  final TextEditingController numeroController = TextEditingController();
  final TextEditingController questionController = TextEditingController();
  final TextEditingController instructionController = TextEditingController(); // Champ pour l'instruction
  String selectedType = 'choix'; // Valeur par défaut pour le type

  // Liste des contrôleurs pour chaque réponse
  List<Map<String, dynamic>> responseFields = [
    _createEmptyResponseField(),
  ];

  // Crée une nouvelle structure pour une réponse
  static Map<String, dynamic> _createEmptyResponseField() {
    return {
      'reponseController': TextEditingController(),
      'educationController': TextEditingController(),
      'alimentationController': TextEditingController(),
      'pauvreteController': TextEditingController(),
      'cadreVieController': TextEditingController(),
      'santePhysiqueController': TextEditingController(),
      'violenceController': TextEditingController(),
      'indiceSortirController': TextEditingController(),
    };
  }

  void _addResponseField() {
    setState(() {
      responseFields.add(_createEmptyResponseField());
    });
  }

  void _removeResponseField(int index) {
    setState(() {
      responseFields.removeAt(index);
    });
  }

  int _parseOrZero(String? value) {
    return int.tryParse(value ?? '') ?? 0;
  }

  Future<void> _createQuestion() async {
    try {
      // Créer la question avec les champs de texte, y compris l'instruction et le type
      final question = Question(
        numero: numeroController.text.isNotEmpty ? int.parse(numeroController.text) : 0,
        question_text: questionController.text,
        type: selectedType, // Utilisation du type sélectionné
        commentaire: instructionController.text, // Utilisation de l'instruction
      );

      // Appeler le service pour créer la question dans la base de données
      final newQuestion = await questionService.createQuestion(question);

      if (newQuestion.id != null && newQuestion.id!.isNotEmpty) {
        // Créer les réponses associées
        for (final responseField in responseFields) {
          final reponseText = responseField['reponseController'].text;
          if (reponseText.isNotEmpty) {
            final response = Response(
              question_id: newQuestion.id!,
              reponse_text: reponseText,
              education: _parseOrZero(responseField['educationController'].text),
              alimentation: _parseOrZero(responseField['alimentationController'].text),
              pauvrete: _parseOrZero(responseField['pauvreteController'].text),
              cadre_vie: _parseOrZero(responseField['cadreVieController'].text),
              sante_physique: _parseOrZero(responseField['santePhysiqueController'].text),
              violence: _parseOrZero(responseField['violenceController'].text),
              indice_sortir: responseField['indiceSortirController'].text,
            );
            // Appeler le service pour créer chaque réponse
            await responseService.createResponse(response);
          }
        }

        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Question et réponses créées avec succès')),
        );

        // Retourner à la page précédente
        Navigator.pop(context);
      } else {
        throw Exception('L\'ID de la question est manquant');
      }
    } catch (e, stackTrace) {
      print('Erreur : $e');
      print('Trace de la pile : $stackTrace');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Créer une Question')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: numeroController,
                decoration: InputDecoration(labelText: 'Numéro de la Question'),
              ),
              TextField(
                controller: questionController,
                decoration: InputDecoration(labelText: 'Texte de la Question'),
              ),
              TextField(
                controller: instructionController,
                decoration: InputDecoration(labelText: 'Instruction (optionnel)'),
              ),
              SizedBox(height: 20),
              DropdownButton<String>(
                value: selectedType,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedType = newValue!;
                  });
                },
                items: <String>['choix', 'text', 'reponseunique', 'reponsemultiples', 'photos']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Text('Réponses', style: TextStyle(fontSize: 18)),
              ...responseFields.asMap().entries.map((entry) {
                final index = entry.key;
                final responseField = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: responseField['reponseController'],
                            decoration: InputDecoration(labelText: 'Réponse ${index + 1}'),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeResponseField(index),
                        ),
                      ],
                    ),
                    TextField(
                      controller: responseField['educationController'],
                      decoration: InputDecoration(labelText: 'Éducation (optionnel)'),
                    ),
                    TextField(
                      controller: responseField['alimentationController'],
                      decoration: InputDecoration(labelText: 'Alimentation (optionnel)'),
                    ),
                    TextField(
                      controller: responseField['pauvreteController'],
                      decoration: InputDecoration(labelText: 'Pauvreté (optionnel)'),
                    ),
                    TextField(
                      controller: responseField['cadreVieController'],
                      decoration: InputDecoration(labelText: 'Cadre de Vie (optionnel)'),
                    ),
                    TextField(
                      controller: responseField['santePhysiqueController'],
                      decoration: InputDecoration(labelText: 'Santé Physique (optionnel)'),
                    ),
                    TextField(
                      controller: responseField['violenceController'],
                      decoration: InputDecoration(labelText: 'Violence (optionnel)'),
                    ),
                    TextField(
                      controller: responseField['indiceSortirController'],
                      decoration: InputDecoration(labelText: 'Indice Sortir (optionnel)'),
                    ),
                    SizedBox(height: 10),
                  ],
                );
              }).toList(),
              SizedBox(height: 10),
              TextButton.icon(
                onPressed: _addResponseField,
                icon: Icon(Icons.add),
                label: Text('Ajouter une réponse'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createQuestion,
                child: Text('Créer la Question'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
