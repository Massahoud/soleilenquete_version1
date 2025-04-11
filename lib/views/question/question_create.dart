import 'package:flutter/material.dart';
import 'package:soleilenquete/views/HomePage.dart';
import 'package:soleilenquete/widget/customDialog.dart';
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
              education:
                  _parseOrZero(responseField['educationController'].text),
              alimentation:
                  _parseOrZero(responseField['alimentationController'].text),
              pauvrete: _parseOrZero(responseField['pauvreteController'].text),
              cadre_vie: _parseOrZero(responseField['cadreVieController'].text),
              sante_physique:
                  _parseOrZero(responseField['santePhysiqueController'].text),
              violence: _parseOrZero(responseField['violenceController'].text),
              indice_sortir: responseField['indiceSortirController'].text,
            );
            await responseService.createResponse(response);
          }
        }

      showCustomSnackBar(
        context: context,
        message: "Question et réponse  créée avec succes.",
        actionLabel: "VOIR",
        onAction: () {
          Navigator.pop(context);
        },
        backgroundColor: Colors.grey[700]!,
      );
        Navigator.pop(context);
      } else {
        throw Exception('L\'ID de la question est manquant');
      }
    } catch (e) {
      showRoleErrorDialog();
    
    }
  }
void showRoleErrorDialog() {
  showDialog(
    context: context,
    builder: (context) => CustomDialog(
      title: "Ereur",
      content: "Veuillez vous réconnecter pour créer un formulaire",
      buttonText: "OK",
      onPressed: () {
        Navigator.pushReplacementNamed(context, '/login');
      },
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Créer un formulaire",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: null, // Désactivé
            icon: Icon(Icons.remove_red_eye, color: Colors.grey),
            label: Text(
              "Visualiser",
              style: TextStyle(color: Colors.grey),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
          ),
          SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: _createQuestion,
            icon: Icon(Icons.check_circle, color: Colors.white),
            label: Text("Enregistrer",style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
          ),
          SizedBox(width: 20),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      color: Colors.white,
                      margin: EdgeInsets.only(bottom: 16),
                      child: IntrinsicHeight(
                        // S'adapte à la hauteur du plus grand enfant
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment
                              .stretch, // Étire la bannière sur toute la hauteur
                          children: [
                            // Bannière verticale
                            Container(
                              width: 8, // Largeur de la bannière
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(
                                    255, 83, 83, 83), // Couleur de la bannière
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  bottomLeft: Radius.circular(4),
                                ),
                              ),
                            ),
                            // Contenu principal
                            Expanded(
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
                                      items: <String>[
                                        'choix',
                                        'text',
                                        'reponseunique',
                                        'reponsemultiples',
                                        'photos'
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
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
                          ],
                        ),
                      ),
                    ),
                    Card(
                      color: Colors.white,
                      margin: EdgeInsets.only(bottom: 16),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Bannière verticale
                            Container(
                              width: 8,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 83, 83, 83),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  bottomLeft: Radius.circular(4),
                                ),
                              ),
                            ),
                            // Contenu principal
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Réponses',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    ...responseFields
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      final index = entry.key;
                                      final responseField = entry.value;
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 10),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              if (responseField[
                                                      'reponseController'] !=
                                                  null)
                                                SizedBox(
                                                  width: 200,
                                                  child: CustomTextField(
                                                    controller: responseField[
                                                        'reponseController'],
                                                    hintText: 'Réponse',
                                                    labelText: '',
                                                  ),
                                                ),
                                              _buildResponseField(
                                                  'Éducation',
                                                  responseField[
                                                      'educationController'],
                                                  width: 100),
                                              _buildResponseField(
                                                  'Alimentation',
                                                  responseField[
                                                      'alimentationController'],
                                                  width: 100),
                                              _buildResponseField(
                                                  'Pauvreté',
                                                  responseField[
                                                      'pauvreteController'],
                                                  width: 100),
                                              _buildResponseField(
                                                  'Cadre de vie',
                                                  responseField[
                                                      'cadreVieController'],
                                                  width: 100),
                                              _buildResponseField(
                                                  'Santé physique',
                                                  responseField[
                                                      'santePhysiqueController'],
                                                  width: 100),
                                              _buildResponseField(
                                                  'Violence',
                                                  responseField[
                                                      'violenceController'],
                                                  width: 100),
                                              _buildResponseField(
                                                  'Indice à sortir',
                                                  responseField[
                                                      'indiceSortirController'],
                                                  width: 100),
                                              SizedBox(
                                                width: 50,
                                                child: IconButton(
                                                  icon: Icon(Icons.delete,
                                                      color: Colors.red),
                                                  onPressed: () =>
                                                      _removeResponseField(
                                                          index),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      );
                                    }).toList(),
                                    SizedBox(height: 10),
                                    TextButton.icon(
                                      onPressed: _addResponseField,
                                      icon:
                                          Icon(Icons.add, color: Colors.orange),
                                      label: Text(
                                        'Ajouter une réponse',
                                        style: TextStyle(color: Colors.orange),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildResponseField(String label, TextEditingController controller,
      {double width = 100}) {
    return SizedBox(
      width: width,
      child: CustomTextField(
        controller: controller,
        labelText: label,
        hintText: 'Entrez la valeur',
      ),
    );
  }
}
