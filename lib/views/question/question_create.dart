import 'package:flutter/material.dart';
import 'package:soleilenquete/views/HomePage.dart';
import '../../services/question_service.dart';
import '../../services/response_service.dart';
import '../../models/question_model.dart';
import '../../models/reponse_model.dart';
import 'package:soleilenquete/component/customTextField.dart';

class CreateQuestionPage extends StatefulWidget {
  @override
  _CreateQuestionPageState createState() => _CreateQuestionPageState();
}

class _CreateQuestionPageState extends State<CreateQuestionPage> {
  final QuestionService questionService = QuestionService();
  final ResponseService responseService = ResponseService();

  final TextEditingController numeroController = TextEditingController();
  final TextEditingController questionController = TextEditingController();
  final TextEditingController instructionController = TextEditingController();
  String selectedType = 'choix';

  List<Map<String, dynamic>> responseFields = [
    _createEmptyResponseField(),
  ];

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
      final question = Question(
        numero: numeroController.text,
        question_text: questionController.text,
        type: selectedType,
        commentaire: instructionController.text,
      );

      final newQuestion = await questionService.createQuestion(question);

      if (newQuestion.id != null && newQuestion.id!.isNotEmpty) {
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
            await responseService.createResponse(response);
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Question et réponses créées avec succès')),
        );
        Navigator.pop(context);
      } else {
        throw Exception('L\'ID de la question est manquant');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.2,
            color: Colors.blue,
            child: HomePage(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                        color: Colors.white,
                      margin: EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextField(
                              controller: numeroController,
                              labelText: 'Numéro',
                              hintText: 'Numéro de la question',
                            ),
                            CustomTextField(
                              controller: questionController,
                              labelText: 'Question',
                              hintText: 'Entrez la question',
                            ),
                            CustomTextField(
                              controller: instructionController,
                              labelText: 'Instruction',
                              hintText: 'Entrez l\'instruction',
                            ),
                            SizedBox(height: 16),
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
                          ],
                        ),
                      ),
                    ),
                    Card(
                        color: Colors.white,
                      margin: EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Réponses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ...responseFields.asMap().entries.map((entry) {
                              final index = entry.key;
                              final responseField = entry.value;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CustomTextField(
                                          controller: responseField['reponseController'],
                                          labelText: 'Réponse ${index + 1}',
                                          hintText: 'Entrez la réponse',
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _removeResponseField(index),
                                      ),
                                    ],
                                  ),
                                  _buildResponseField('Éducation', responseField['educationController']),
                                  _buildResponseField('Alimentation', responseField['alimentationController']),
                                  _buildResponseField('Pauvreté', responseField['pauvreteController']),
                                  _buildResponseField('Cadre de vie', responseField['cadreVieController']),
                                  _buildResponseField('Santé physique', responseField['santePhysiqueController']),
                                  _buildResponseField('Violence', responseField['violenceController']),
                                  _buildResponseField('Indice à sortir', responseField['indiceSortirController']),
                                  SizedBox(height: 16),
                                ],
                              );
                            }).toList(),
                            TextButton.icon(
                              onPressed: _addResponseField,
                              icon: Icon(Icons.add),
                              label: Text('Ajouter une réponse'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _createQuestion,
                      child: Text('Créer la Question'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseField(String label, TextEditingController controller) {
    return CustomTextField(
      controller: controller,
      labelText: label,
      hintText: 'Entrez la valeur',
    );
  }
}
