import 'package:flutter/material.dart';
import 'package:soleilenquete/component/customTextField.dart';
import 'package:soleilenquete/models/reponse_model.dart';
import 'package:soleilenquete/services/survey_service.dart';
import '../../models/question_model.dart';
import '../../services/question_service.dart';
import '../../services/response_service.dart';
import '../../widget/Single_question.dart';
import '../../widget/Multiple_question.dart';
import 'package:soleilenquete/models/survey_model.dart';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class SurveyPage extends StatefulWidget {
  @override
  _SurveyPageState createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  List<Map<String, dynamic>> questionsWithResponses = [];

  final SurveyService surveyService = SurveyService();
  String errorMessage = '';
  double progress = 0.0;
  final ScrollController _scrollController = ScrollController();
  final Map<String, TextEditingController> textControllers = {};
  SurveyModel? _tempSurvey;
  html.File? _imageFile;
  final Map<String, Map<String, String>> answers = {};
  
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is SurveyModel) {
        setState(() {
          _tempSurvey = args;
        });

      
      }
    });

    _loadQuestions();
    _scrollController.addListener(_updateProgress);
  }

  Future<String?> sendSurveyData(SurveyModel newSurvey) async {
    try {
      if (newSurvey.photoUrl != null &&
          newSurvey.photoUrl!.startsWith("blob:")) {
        _imageFile =
            await convertBlobUrlToFile(newSurvey.photoUrl!, "survey_image.png");
      }

      final String? surveyId =
          await surveyService.createSurvey(newSurvey, _imageFile);

      if (surveyId != null) {
        print('Survey envoyé avec succès : $surveyId');
      } else {
        print("Erreur : l'ID de l'enquête est null.");
      }

      return surveyId;
    } catch (e) {
      print("Erreur lors de l'envoi du survey : $e");
      return null;
    }
  }

  Future<html.File?> convertBlobUrlToFile(
      String blobUrl, String fileName) async {
    try {
      final response = await http.get(Uri.parse(blobUrl));

      if (response.statusCode == 200) {
        Uint8List uint8List = response.bodyBytes;

        final blob = html.Blob([uint8List]);
        final file = html.File([blob], fileName, {'type': 'image/png'});

        return file;
      } else {
        print("Erreur lors du téléchargement du blob: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Erreur: $e");
      return null;
    }
  }

  void _updateProgress() {
    if (_scrollController.hasClients) {
      setState(() {
        progress = _scrollController.offset /
            _scrollController.position.maxScrollExtent;
      });
    }
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await QuestionService().getAllQuestions();
      for (var question in questions) {
        _loadResponses(question);
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  void _loadResponses(Question question) async {
    setState(() {
      questionsWithResponses.add({
        'question': question,
        'responses': null,
      });
    });

    try {
      final responses =
          await ResponseService().getResponsesByQuestionId(question.id!);
      setState(() {
        final index = questionsWithResponses
            .indexWhere((q) => q['question'].id == question.id);
        if (index != -1) {
          questionsWithResponses[index]['responses'] = responses;
        }
      });
    } catch (e) {
      print("Erreur lors du chargement des réponses: $e");

      if (e.toString().contains('Unauthorized') ||
          e.toString().contains('403')) {
        _showTokenErrorDialog();
      }
    }
  }

  void _showTokenErrorDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Session Expirée"),
          content: Text("Votre session a expiré. Veuillez vous reconnecter."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    });
  }


  void _handleAnswer({
    required String questionId,
    required String questionText,
    required String questionNumber,
    String? responseId,
    String? responseText,
  }) {
    setState(() {
      String uniqueKey = "$questionId-$responseId";
      answers[uniqueKey] = {
        'question_id': questionId,
        'question_text': questionText,
        'numero': questionNumber,
        'reponse': responseId ?? '',
        'reponse_text': responseText ?? '',
      };
    });
  }

  Future<void> _sendAnswersToApi(String surveyId) async {
    if (answers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Aucune réponse à envoyer.'),
      ));
      return;
    }

    List<Map<String, dynamic>> responses = answers.values.toList();

    try {
      await surveyService.sendResponses(surveyId, responses);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Toutes les réponses ont été envoyées avec succès !'),
      ));

      setState(() {
        answers.clear();
      });
    } catch (e) {
      print('Erreur lors de l\'envoi des réponses : $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur lors de l\'envoi des réponses.'),
      ));
    }
  }

  Future<void> _sendSurveyAndAnswers(String avis) async {
    if (_tempSurvey == null) {
      print("Aucune enquête disponible à envoyer.");
      return;
    }

    SurveyModel newSurvey = SurveyModel(
      id: _tempSurvey!.id,
      numero: _tempSurvey!.numero,
      prenomEnqueteur: _tempSurvey!.prenomEnqueteur,
      nomEnqueteur: _tempSurvey!.nomEnqueteur,
      prenomEnfant: _tempSurvey!.prenomEnfant,
      nomEnfant: _tempSurvey!.nomEnfant,
      sexeEnfant: _tempSurvey!.sexeEnfant,
      contactEnfant: _tempSurvey!.contactEnfant,
      nomContactEnfant: _tempSurvey!.nomContactEnfant,
      ageEnfant: _tempSurvey!.ageEnfant,
      lieuEnquete: _tempSurvey!.lieuEnquete,
      dateHeureDebut: _tempSurvey!.dateHeureDebut,
      latitude: _tempSurvey!.latitude,
      longitude: _tempSurvey!.longitude,
      photoUrl: _tempSurvey!.photoUrl,
      avisEnqueteur: avis,
    );

    try {
      String? surveyId = await sendSurveyData(newSurvey);
      if (surveyId == null) throw Exception("L'ID de l'enquête est null.");
     

      await _sendAnswersToApi(surveyId);
      print("Réponses envoyées avec succès.");
    } catch (e) {
      print("Erreur lors de l'envoi des données : $e");
    }
  }

 Future<void> _afficherBoiteDialogueAvis() async {
  TextEditingController avisController = TextEditingController();
  bool isLoading = false;
final isMobile = MediaQuery.of(context).size.width < 600;
final dialogWidth = isMobile ? MediaQuery.of(context).size.width * 0.9 : 450.0;
final dialogHeight = isMobile ? MediaQuery.of(context).size.height * 0.30 : 310.0;

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Center(
            child: Container(
       width: dialogWidth,
height: dialogHeight,

              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child:  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Text(
                            "Avis de l'enquêteur",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[300],
                            ),
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.black87),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Zone de texte
                      Expanded(
                        child: TextField(
                          controller: avisController,
                          maxLines: null,
                          expands: true,
                          decoration: InputDecoration(
                            hintText: 'Écrire ici...',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Boutons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Annuler'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    await _sendSurveyAndAnswers(
                                        avisController.text);

                                    setState(() {
                                      isLoading = false;
                                    });

                                    Navigator.of(context).pop();
                                    _afficherBoiteSucces();
                                  },
                            child: isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.orange,
                                    ),
                                  )
                                : const Text('Enregistrer'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
 


  void _afficherBoiteSucces() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(
        'Enquête enregistrée avec succès',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      // On n'affiche pas de contenu supplémentaire, on peut mettre un SizedBox.shrink()
      content: SizedBox.shrink(),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
       
        // Bouton "Supprimer" (rouge)
        ElevatedButton(
           onPressed: () {
             
                Navigator.pushReplacementNamed(context, '/dashboard');
              },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            shape: StadiumBorder(),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            'ok',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
      },
    );
  }

 @override
Widget build(BuildContext context) {
  final isMobile = MediaQuery.of(context).size.width < 600; // Détection de l'écran mobile

  return Scaffold(
    backgroundColor: Colors.grey[100],
    appBar: AppBar(
      title: Text("Enquête"),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(4.0),
        child: LinearProgressIndicator(
          value: progress, // Connecté à la progression du défilement
          backgroundColor: Colors.grey[300],
          color: Colors.blue,
        ),
      ),
    ),
    body: Center(
      child: SingleChildScrollView(
        controller: _scrollController, // Contrôleur pour suivre le défilement
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: isMobile
                  ? double.infinity // Pleine largeur pour mobile
                  : MediaQuery.of(context).size.width * 0.6, // 60% pour les écrans non mobiles
              child: Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (questionsWithResponses.isEmpty)
                        Center(child: CircularProgressIndicator())
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: questionsWithResponses.length,
                          itemBuilder: (context, index) {
                            final questionData = questionsWithResponses[index];
                            final question = questionData['question'] as Question;
                            final responses =
                                questionData['responses'] as List<Response>?;

                            Widget questionWidget;
                            if (question.type == 'reponseunique') {
                              questionWidget = SingleChoiceQuestion(
                                questionNumber: question.numero,
                                question: question.question_text,
                                options: responses
                                        ?.map((response) => response.reponse_text)
                                        .toList() ??
                                    [],
                                onChanged: (selectedText) {
                                  final selectedResponse = responses?.firstWhere(
                                      (r) => r.reponse_text == selectedText);
                                  if (selectedResponse != null) {
                                    _handleAnswer(
                                      questionId: question.id!,
                                      questionText: question.question_text,
                                      questionNumber: question.numero,
                                      responseId: selectedResponse.id!,
                                      responseText: selectedResponse.reponse_text,
                                    );
                                  }
                                },
                              );
                            } else if (question.type == 'reponsemultiples') {
                              questionWidget = MultipleChoiceQuestion(
                                questionNumber: question.numero,
                                question: question.question_text,
                                options: responses
                                        ?.map((response) => response.reponse_text)
                                        .toList() ??
                                    [],
                                onChanged: (selectedTexts) {
                                  final selectedResponses = responses
                                      ?.where((r) =>
                                          selectedTexts.contains(r.reponse_text))
                                      .toList();

                                  if (selectedResponses != null) {
                                    for (var response in selectedResponses) {
                                      _handleAnswer(
                                        questionId: question.id!,
                                        questionText: question.question_text,
                                        questionNumber: question.numero,
                                        responseId: response.id!,
                                        responseText: response.reponse_text,
                                      );
                                    }
                                  }
                                },
                              );
                            } else {
                              questionWidget = Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CustomTextField(
                                  controller: textControllers.putIfAbsent(
                                      question.id!, () => TextEditingController()),
                                  labelText:
                                      "${question.numero}. ${question.question_text}",
                                  hintText: 'Entrez le texte',
                                  onChanged: (value) {
                                    _handleAnswer(
                                      questionId: question.id!,
                                      questionText: question.question_text,
                                      questionNumber: question.numero,
                                      responseText: value,
                                    );
                                  },
                                ),
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                questionWidget,
                              ],
                            );
                          },
                        ),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          onPressed: _afficherBoiteDialogueAvis,
                          child: const Text('Enregistrer', style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}
