import 'package:flutter/material.dart';
import 'package:soleilenquete/component/customTextField.dart';
import 'package:soleilenquete/models/reponse_model.dart';
import '../../models/question_model.dart';
import '../../services/question_service.dart';
import '../../services/response_service.dart';
import '../../widget/Single_question.dart';
import '../../widget/Multiple_question.dart';

class SurveyPage extends StatefulWidget {
  @override
  _SurveyPageState createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  List<Map<String, dynamic>> questionsWithResponses = [];
  Map<String, dynamic> answers = {};

  String errorMessage = '';
  double progress = 0.0;
  final ScrollController _scrollController = ScrollController();
  final Map<String, TextEditingController> textControllers = {};

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _scrollController.addListener(_updateProgress);
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
    }
  }

  void _handleAnswer({
    required String questionId,
    required String questionText,
    required String questionNumber,
    List<Map<String, String>>? responses, // Liste pour les réponses multiples
    String? responseId, // Pour les réponses uniques
    String? responseText, // Pour les réponses saisies
  }) {
    setState(() {
      answers[questionId] = {
        'question_id': questionId,
        'question_text': questionText,
        'question_number': questionNumber,
        'responses': responses ?? [], // Liste pour les choix multiples
        'response_id': responseId ?? '', // ID pour un seul choix
        'response_text': responseText ?? '', // Texte d'un seul choix ou saisie
      };
    });
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
                                  .map((r) => {
                                        'response_id': r.id!,
                                        'response_text': r.reponse_text,
                                      })
                                  .toList();

                              _handleAnswer(
                                questionId: question.id!,
                                questionText: question.question_text,
                                questionNumber: question.numero,
                                responses:
                                    selectedResponses, // Utilisation de la liste
                              );
                            },
                          );
                        } else {
                          questionWidget = Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CustomTextField(
                              controller: textControllers.putIfAbsent(
                                  question.id!,
                                  () =>
                                      TextEditingController()), // Un contrôleur par question
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
        onPressed: () {
          print("Réponses: $answers");
        },
        child: Icon(Icons.save),
      ),
    );
  }
}
