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

        print("Données récupérées : ${_tempSurvey.toString()}");
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
      print("Données de l'enquête envoyées avec succès. ID: $surveyId");

      await _sendAnswersToApi(surveyId);
      print("Réponses envoyées avec succès.");
    } catch (e) {
      print("Erreur lors de l'envoi des données : $e");
    }
  }

  Future<void> _afficherBoiteDialogueAvis() async {
    TextEditingController avisController = TextEditingController();
    bool isLoading = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Avis de l\'enquêteur'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Veuillez entrer votre avis:'),
                    TextField(
                      controller: avisController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Écrire ici',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Annuler'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: isLoading
                      ? SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text('Enregistrer'),
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                          });

                          await _sendSurveyAndAnswers(avisController.text);

                          setState(() {
                            isLoading = false;
                          });

                          Navigator.of(context).pop();

                          _afficherBoiteSucces();
                        },
                ),
              ],
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
          title: Text('Succès'),
          content: Text('Votre avis a été enregistré avec succès !'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/dashboard');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Enquête"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            color: Colors.blue,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.all(16.0),
              child: questionsWithResponses.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
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
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _afficherBoiteDialogueAvis,
        child: Icon(Icons.save),
      ),
    );
  }
}
