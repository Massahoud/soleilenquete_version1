import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../models/reponse_model.dart';
import '../services/question_service.dart';
import '../services/response_service.dart';

class UpdateQuestionPage extends StatefulWidget {
  final String questionId; // L'ID de la question à mettre à jour
  final List<String> responseIds; // Liste des IDs des réponses

  UpdateQuestionPage({required this.questionId, required this.responseIds});

  @override
  _UpdateQuestionPageState createState() => _UpdateQuestionPageState();
}

class _UpdateQuestionPageState extends State<UpdateQuestionPage> {
  final QuestionService questionService = QuestionService();
  final ResponseService responseService = ResponseService();

  final TextEditingController numeroController = TextEditingController();
  final TextEditingController questionController = TextEditingController();
  final TextEditingController instructionController = TextEditingController();
  String selectedType = 'text';

  // Liste des contrôleurs pour chaque réponse
  List<Map<String, TextEditingController>> responseFields = [
    _createEmptyResponseField(),
  ];

  @override
  void initState() {
    super.initState();
    _loadQuestionData();
  }

  // Charge les données de la question et des réponses associées
  Future<void> _loadQuestionData() async {
    try {
      // Utiliser l'ID de la question pour récupérer les données
      final question = await questionService.getQuestionById(widget.questionId);

      // Remplir les champs avec les données récupérées
      numeroController.text = question.numero.toString();
      questionController.text = question.question_text ?? '';
      instructionController.text = question.commentaire ?? '';
      selectedType = question.type ?? 'text';

      // Charger les réponses associées
      final responses = await responseService.getResponsesByQuestionId(widget.questionId);
      setState(() {
        responseFields = responses.map((response) {
          return {
            'reponseController': TextEditingController(text: response.reponse_text ?? ''),
            'educationController': TextEditingController(text: response.education?.toString() ?? ''),
            'alimentationController': TextEditingController(text: response.alimentation?.toString() ?? ''),
            'pauvreteController': TextEditingController(text: response.pauvrete?.toString() ?? ''),
            'cadreVieController': TextEditingController(text: response.cadre_vie?.toString() ?? ''),
            'santePhysiqueController': TextEditingController(text: response.sante_physique?.toString() ?? ''),
            'violenceController': TextEditingController(text: response.violence?.toString() ?? ''),
            'indiceSortirController': TextEditingController(text: response.indice_sortir ?? ''),
          };
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement de la question: $e')),
      );
    }
  }

  // Crée une nouvelle structure pour une réponse
  static Map<String, TextEditingController> _createEmptyResponseField() {
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

  // Ajouter un nouveau champ de réponse
  void _addResponseField() {
    setState(() {
      responseFields.add(_createEmptyResponseField());
    });
  }

  // Supprimer un champ de réponse
  void _removeResponseField(int index) {
    setState(() {
      responseFields.removeAt(index);
    });
  }

  // Mettre à jour la question et ses réponses
  Future<void> _updateQuestion() async {
    try {
      final updatedQuestion = Question(
        id: widget.questionId,
        numero: numeroController.text.isNotEmpty ? int.parse(numeroController.text) : 0,
        question_text: questionController.text,
        type: selectedType,
        commentaire: instructionController.text,
      );

      // Appeler le service pour mettre à jour la question dans la base de données
      await questionService.updateQuestion(widget.questionId, updatedQuestion);

    // Mettre à jour ou ajouter les réponses associées
for (int i = 0; i < responseFields.length; i++) {
  final responseText = responseFields[i]['reponseController']!.text.trim();

  // Vérifier si la réponse est non vide
  if (responseText.isNotEmpty) {
    final response = Response(
      id: widget.responseIds[i], // Utiliser l'ID de la réponse pour la mise à jour
      question_id: widget.questionId,
      reponse_text: responseText,
      education: int.tryParse(responseFields[i]['educationController']!.text) ?? 0,
      alimentation: int.tryParse(responseFields[i]['alimentationController']!.text) ?? 0,
      pauvrete: int.tryParse(responseFields[i]['pauvreteController']!.text) ?? 0,
      cadre_vie: int.tryParse(responseFields[i]['cadreVieController']!.text) ?? 0,
      sante_physique: int.tryParse(responseFields[i]['santePhysiqueController']!.text) ?? 0,
      violence: int.tryParse(responseFields[i]['violenceController']!.text) ?? 0,
      indice_sortir: responseFields[i]['indiceSortirController']!.text,
    );

    // Appeler le service pour mettre à jour chaque réponse avec l'ID et la réponse
    await responseService.updateResponse(response.id?? "", response); // Pass both ID and Response object
  }
}


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Question et réponses mises à jour avec succès')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mettre à jour la Question')),
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
                items: <String>['text', 'reponseunique', 'reponsemultiples', 'photos']
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
                onPressed: _updateQuestion,
                child: Text('Mettre à jour la Question'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
