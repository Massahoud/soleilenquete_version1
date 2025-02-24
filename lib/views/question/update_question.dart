import 'package:flutter/material.dart';
import '../../models/question_model.dart';
import '../../models/reponse_model.dart';
import '../../services/question_service.dart';
import '../../services/response_service.dart';
import 'package:soleilenquete/component/CustomTextField.dart';

class UpdateQuestionPage extends StatefulWidget {
  final String questionId;
  final List<String> responseIds;

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
      // Vérifiez que la réponse n'est pas null avant de créer les contrôleurs
      responseFields = responses.map((response) {
        if (response != null) {
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
        } else {
          return _createEmptyResponseField(); // Créer un champ vide si la réponse est null
        }
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

 Future<void> _updateQuestion() async {
  try {
    final updatedQuestion = Question(
      id: widget.questionId,
      numero: numeroController.text.trim(),
      question_text: questionController.text.trim(),
      type: selectedType,
      commentaire: instructionController.text.trim(),
    );

    // Vérification des champs de la question
    if (updatedQuestion.numero.isEmpty || updatedQuestion.question_text.isEmpty) {
      throw Exception("Le numéro et le texte de la question ne peuvent pas être vides.");
    }
try {
   await questionService.updateQuestion(widget.questionId, updatedQuestion);
} catch (e) {
  print('Erreur lors de la mise à jour de la question : $e');
}

    // Appeler le service pour mettre à jour la question dans la base de données
   

    // Mettre à jour ou ajouter les réponses associées
    for (int i = 0; i < responseFields.length; i++) {
      final responseText = responseFields[i]['reponseController']!.text.trim();

      // Vérifier si la réponse est non vide
      if (responseText.isNotEmpty) {
        // Récupérer et vérifier les autres champs de réponse
        final education = int.tryParse(responseFields[i]['educationController']!.text.trim()) ?? 0;
        final alimentation = int.tryParse(responseFields[i]['alimentationController']!.text.trim()) ?? 0;
        final pauvrete = int.tryParse(responseFields[i]['pauvreteController']!.text.trim()) ?? 0;
        final cadreVie = int.tryParse(responseFields[i]['cadreVieController']!.text.trim()) ?? 0;
        final santePhysique = int.tryParse(responseFields[i]['santePhysiqueController']!.text.trim()) ?? 0;
        final violence = int.tryParse(responseFields[i]['violenceController']!.text.trim()) ?? 0;
        final indiceSortir = responseFields[i]['indiceSortirController']!.text.trim();

        // Vérifiez que tous les champs nécessaires ne sont pas nuls
        if (widget.responseIds[i] == null || widget.responseIds[i].isEmpty) {
          throw Exception("L'ID de la réponse est manquant pour la réponse ${i + 1}.");
        }

        final response = Response(
          id: widget.responseIds[i], // Utiliser l'ID de la réponse pour la mise à jour
          question_id: widget.questionId,
          reponse_text: responseText,
          education: education,
          alimentation: alimentation,
          pauvrete: pauvrete,
          cadre_vie: cadreVie,
          sante_physique: santePhysique,
          violence: violence,
          indice_sortir: indiceSortir,
        );

        // Afficher la réponse récupérée pour la mise à jour
        print('Mise à jour de la réponse ${i + 1}: ${response.toJson()}');

        // Appeler le service pour mettre à jour chaque réponse avec l'ID et la réponse
        await responseService.updateResponse(response.id ?? '', response); // Pass both ID and Response object
      } else {
        print('Réponse vide pour la réponse ${i + 1}.');
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Question et réponses mises à jour avec succès')),
    );

    Navigator.pop(context);
  } catch (e) {
    print('Erreur lors de la mise à jour : $e');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur lors de la mise à jour: ${e.toString()}')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(title: Text('Mettre à jour la Question')),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
                child: Column(children: [
              Card(
                  color: Colors.white,
                  margin: EdgeInsets.only(bottom: 16),
                  child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Numéro de la Question (Non modifiable)
                                SizedBox(
                                  width:
                                      60, // Ajuste la largeur selon tes besoins
                                  child: CustomTextField(
                                    controller: numeroController,
                                    hintText: 'Numéro',
                                    labelText: 'Numéro',
                                  ),
                                ),

                                SizedBox(
                                    width: 10), // Espacement entre les champs

                                // Texte de la Question
                                Expanded(
                                  child: CustomTextField(
                                    controller: questionController,
                                    hintText: 'Texte de la question',
                                    labelText: 'Texte de la Question',
                                  ),
                                ),

                                SizedBox(width: 10), // Espacement

                                // Instruction de la Question
                                Expanded(
                                  child: CustomTextField(
                                    controller: instructionController,
                                    hintText: 'Instruction (optionnel)',
                                    labelText: 'Instruction (optionnel)',
                                  ),
                                ),

                                SizedBox(width: 10), // Espacement

                                // Dropdown de Type de Réponse
                                DropdownButton<String>(
                                  value: selectedType,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedType = newValue!;
                                    });
                                  },
                                  items: <String>[
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
                          ]))),
              SizedBox(height: 20),
              Card(
                color: Colors.white,
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Réponses', style: TextStyle(fontSize: 18)),
                      ...responseFields.asMap().entries.map((entry) {
                        final index = entry.key;
                        final responseField = entry.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10), // Espacement entre les lignes
                            Wrap(
                              spacing: 8, // Espace horizontal entre les champs
                              runSpacing:
                                  8, // Espace vertical entre les lignes si nécessaire
                              children: [
                                if (responseField['reponseController'] != null)
                                  SizedBox(
                                    width: 200,
                                    child: CustomTextField(
                                      controller:
                                          responseField['reponseController']!,
                                      hintText: 'reponse',
                                      labelText: '',
                                    ),
                                  ),

                                if (responseField['educationController'] !=
                                    null)
                                  SizedBox(
                                    width: 100,
                                    child: CustomTextField(
                                      controller:
                                          responseField['educationController']!,
                                      hintText: 'Valeur education',
                                      labelText: 'Education',
                                    ),
                                  ),
                                if (responseField['reponseController'] != null)
                                  SizedBox(
                                    width: 100,
                                    child: CustomTextField(
                                        controller: responseField[
                                            'alimentationController']!,
                                        hintText: 'Valeur education',
                                        labelText: 'Alimentation'),
                                  ),
                                if (responseField['reponseController'] != null)
                                  SizedBox(
                                    width: 100,
                                    child: CustomTextField(
                                        controller: responseField[
                                            'pauvreteController']!,
                                        hintText: 'Valeur education',
                                        labelText: 'Pauvreté'),
                                  ),
                                if (responseField['reponseController'] != null)
                                  SizedBox(
                                    width: 100,
                                    child: CustomTextField(
                                        controller: responseField[
                                            'cadreVieController']!,
                                        hintText: 'Valeur education',
                                        labelText: 'Cadre de Vie'),
                                  ),
                                if (responseField['reponseController'] != null)
                                  SizedBox(
                                    width: 100,
                                    child: CustomTextField(
                                        controller: responseField[
                                            'santePhysiqueController']!,
                                        hintText: 'Valeur education',
                                        labelText: 'Santé Physique'),
                                  ),
                                if (responseField['reponseController'] != null)
                                  SizedBox(
                                    width: 100,
                                    child: CustomTextField(
                                        controller: responseField[
                                            'violenceController']!,
                                        hintText: 'Valeur education',
                                        labelText: 'Violence'),
                                  ),
                                if (responseField['reponseController'] != null)
                                  SizedBox(
                                    width: 100,
                                    child: CustomTextField(
                                        controller: responseField[
                                            'indiceSortirController']!,
                                        labelText: 'Indice Sortir',
                                        hintText: 'Indice à rétenir'),
                                  ),

                                // Ajout du bouton de suppression sur la même ligne
                                SizedBox(
                                  width: 50,
                                  child: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () =>
                                        _removeResponseField(index),
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
            ]))));
  }
}
