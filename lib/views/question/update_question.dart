import 'package:flutter/material.dart';
import 'package:soleilenquete/widget/customDialog.dart';
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
      final responses =
          await responseService.getResponsesByQuestionId(widget.questionId);

      setState(() {
        // Vérifiez que la réponse n'est pas null avant de créer les contrôleurs
        responseFields = responses.map((response) {
          if (response != null) {
            return {
              'reponseController':
                  TextEditingController(text: response.reponse_text ?? ''),
              'educationController': TextEditingController(
                  text: response.education?.toString() ?? ''),
              'alimentationController': TextEditingController(
                  text: response.alimentation?.toString() ?? ''),
              'pauvreteController': TextEditingController(
                  text: response.pauvrete?.toString() ?? ''),
              'cadreVieController': TextEditingController(
                  text: response.cadre_vie?.toString() ?? ''),
              'santePhysiqueController': TextEditingController(
                  text: response.sante_physique?.toString() ?? ''),
              'violenceController': TextEditingController(
                  text: response.violence?.toString() ?? ''),
              'indiceSortirController':
                  TextEditingController(text: response.indice_sortir ?? ''),
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


Future<void> deleteQuestionAndResponses(String questionId) async {
  try {
    // Récupérer les réponses associées à la question
 List<String> responseIds = (await responseService.getResponsesByQuestionId(questionId))
    .map((response) => response.id!)
    .toList();


    // Supprimer chaque réponse associée
    for (String responseId in responseIds) {
      await responseService.deleteResponse(responseId);
    }

    // Supprimer la question après avoir supprimé toutes les réponses
    await questionService.deleteQuestion(questionId);

    print("Question et ses réponses supprimées avec succès.");
  } catch (e) {
    print("Erreur lors de la suppression : $e");
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

  void _removeResponseField(int index) async {
  // Vérifier si la réponse a un ID (existe déjà dans la base de données)
  if (index < widget.responseIds.length && widget.responseIds[index].isNotEmpty) {
    String responseId = widget.responseIds[index];

    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirmation"),
        content: Text("Voulez-vous vraiment supprimer cette réponse ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (!confirmDelete) return; // Annuler la suppression

    try {
      await responseService.deleteResponse(responseId);
      
      setState(() {
        widget.responseIds.removeAt(index); // Supprimer l'ID
        responseFields.removeAt(index); // Supprimer l'affichage
      });

      showCustomSnackBar(
        context: context,
        message: "Réponse supprimée avec succès.",
        backgroundColor: Colors.green,
      );

    } catch (e) {
      showCustomSnackBar(
        context: context,
        message: "Erreur lors de la suppression.",
        backgroundColor: Colors.red,
      );
    }
  } else {
    // Supprimer une réponse locale qui n'est pas encore enregistrée
    setState(() {
      responseFields.removeAt(index);
    });
  }
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
      if (updatedQuestion.numero.isEmpty ||
          updatedQuestion.question_text.isEmpty) {
        throw Exception(
            "Le numéro et le texte de la question ne peuvent pas être vides.");
      }

      try {
        await questionService.updateQuestion(
            widget.questionId, updatedQuestion);
      } catch (e) {
        print('Erreur lors de la mise à jour de la question : $e');
      }

      // Mettre à jour ou ajouter les réponses associées
      for (int i = 0; i < responseFields.length; i++) {
        final responseText =
            responseFields[i]['reponseController']!.text.trim();

        // Vérifier si la réponse est non vide
        if (responseText.isNotEmpty) {
          // Récupérer et vérifier les autres champs de réponse
          final education = int.tryParse(
                  responseFields[i]['educationController']!.text.trim()) ??
              0;
          final alimentation = int.tryParse(
                  responseFields[i]['alimentationController']!.text.trim()) ??
              0;
          final pauvrete = int.tryParse(
                  responseFields[i]['pauvreteController']!.text.trim()) ??
              0;
          final cadreVie = int.tryParse(
                  responseFields[i]['cadreVieController']!.text.trim()) ??
              0;
          final santePhysique = int.tryParse(
                  responseFields[i]['santePhysiqueController']!.text.trim()) ??
              0;
          final violence = int.tryParse(
                  responseFields[i]['violenceController']!.text.trim()) ??
              0;
          final indiceSortir =
              responseFields[i]['indiceSortirController']!.text.trim();

          // Vérifiez que l'ID de la réponse existe et n'est pas vide
          if (i < widget.responseIds.length &&
              widget.responseIds[i].isNotEmpty) {
            // Mise à jour des réponses existantes
            final response = Response(
              id: widget.responseIds[i], // Utiliser l'ID existant
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

            // Appeler le service pour mettre à jour chaque réponse existante
            await responseService.updateResponse(response.id ?? '', response);
          } else {
            final newResponse = Response(
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

            await responseService.createResponse(newResponse);
          }
        } else {
          print('Réponse vide pour la réponse ${i + 1}.');
        }
      }

      showCustomSnackBar(
        context: context,
        message: "Question et réponse  mise à jour avec succes.",
        actionLabel: "VOIR",
        onAction: () {
          Navigator.pop(context);
        },
        backgroundColor: Colors.grey[700]!,
      );

      Navigator.pop(context);
    } catch (e) {
      print('Erreur lors de la mise à jour : $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors de la mise à jour: ${e.toString()}')),
      );
    }
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
            "Modifier le formulaire",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "117 questions",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
      actions: [
        OutlinedButton.icon(
          onPressed: ()=>deleteQuestionAndResponses(widget.questionId), // Désactivé
          icon: Icon(Icons.remove_red_eye, color: Colors.red),
          label: Text(
            "Supprimer",
            style: TextStyle(color: Colors.white),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.red),
             backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
        SizedBox(width: 10),
        ElevatedButton.icon(
         onPressed: _updateQuestion, // Ajouter la logique d'enregistrement
          icon: Icon(Icons.check_circle, color: Colors.white),
          label: Text("Enregistrer" ,style: TextStyle(color: Colors.white), ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.shade700,
            
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
        SizedBox(width: 20),
      ],
    ),
        body: 
            Center(
            child: SingleChildScrollView(
             
                 
                child: Column(children: [
                 
          ConstrainedBox(
  constraints: BoxConstraints(
    maxWidth: 1050, // Largeur maximale
    minWidth: 850,  // Largeur minimale
  ),
  child: Card(
    color: Colors.white,
    margin: EdgeInsets.only(bottom: 16),
    child: IntrinsicHeight( // S'adapte à la hauteur du plus grand enfant
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Étire la bannière sur toute la hauteur
        children: [
          // Bannière verticale
          Container(
            width: 8, // Largeur de la bannière
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 83, 83, 83), // Couleur de la bannière
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
                    hintText: 'Numéro',
                    labelText: 'Numéro',
                  ),
                  SizedBox(height: 10),
                  CustomTextField(
                    controller: questionController,
                    hintText: 'Texte de la question',
                    labelText: 'Texte de la Question',
                  ),
                  SizedBox(height: 10),
                  CustomTextField(
                    controller: instructionController,
                    hintText: 'Instruction (optionnel)',
                    labelText: 'Instruction (optionnel)',
                  ),
                  SizedBox(height: 10),
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
                    ].map<DropdownMenuItem<String>>((String value) {
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
),


              SizedBox(height: 20),
                ConstrainedBox(
  constraints: BoxConstraints(
    maxWidth: 1060, // Largeur maximale
    minWidth: 860,  // Largeur minimale
  ),
          child: Card(
  color: Colors.white,
  margin: EdgeInsets.only(bottom: 16),
  child: IntrinsicHeight( // Assure que la bannière prend toute la hauteur
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch, // Étire la bannière sur toute la hauteur
      children: [
        // Bannière verticale
        Container(
          width: 8, // Largeur de la bannière
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 83, 83, 83), // Couleur de la bannière
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
                Text('Réponses', style: TextStyle(fontSize: 18)),
                ...responseFields.asMap().entries.map((entry) {
                  final index = entry.key;
                  final responseField = entry.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (responseField['reponseController'] != null)
                            SizedBox(
                              width: 200,
                              child: CustomTextField(
                                controller: responseField['reponseController']!,
                                hintText: 'Réponse',
                                labelText: '',
                              ),
                            ),
                          if (responseField['educationController'] != null)
                            SizedBox(
                              width: 100,
                              child: CustomTextField(
                                controller: responseField['educationController']!,
                                hintText: 'Valeur éducation',
                                labelText: 'Éducation',
                              ),
                            ),
                          if (responseField['reponseController'] != null)
                            SizedBox(
                              width: 100,
                              child: CustomTextField(
                                  controller: responseField['alimentationController']!,
                                  hintText: 'Valeur alimentation',
                                  labelText: 'Alimentation'),
                            ),
                          if (responseField['reponseController'] != null)
                            SizedBox(
                              width: 100,
                              child: CustomTextField(
                                  controller: responseField['pauvreteController']!,
                                  hintText: 'Valeur pauvreté',
                                  labelText: 'Pauvreté'),
                            ),
                          if (responseField['reponseController'] != null)
                            SizedBox(
                              width: 100,
                              child: CustomTextField(
                                  controller: responseField['cadreVieController']!,
                                  hintText: 'Valeur cadre de vie',
                                  labelText: 'Cadre de Vie'),
                            ),
                          if (responseField['reponseController'] != null)
                            SizedBox(
                              width: 100,
                              child: CustomTextField(
                                  controller: responseField['santePhysiqueController']!,
                                  hintText: 'Valeur santé physique',
                                  labelText: 'Santé Physique'),
                            ),
                          if (responseField['reponseController'] != null)
                            SizedBox(
                              width: 100,
                              child: CustomTextField(
                                  controller: responseField['violenceController']!,
                                  hintText: 'Valeur violence',
                                  labelText: 'Violence'),
                            ),
                          if (responseField['reponseController'] != null)
                            SizedBox(
                              width: 100,
                              child: CustomTextField(
                                  controller: responseField['indiceSortirController']!,
                                  labelText: 'Indice Sortir',
                                  hintText: 'Indice à retenir'),
                            ),
                          SizedBox(
                            width: 50,
                            child: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeResponseField(index),
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
                  icon: Icon(Icons.add, color: Colors.orange), // Couleur de l'icône
                  label: Text(
                    'Ajouter une réponse',
                    style: TextStyle(color: Colors.orange), // Couleur du texte
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
)

            )]))));
  }
}
