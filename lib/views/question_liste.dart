import 'package:flutter/material.dart';
import 'package:soleilenquete/views/update_question.dart';
import '../models/question_model.dart';
import '../models/reponse_model.dart';
import '../services/question_service.dart';
import '../services/response_service.dart';

class QuestionListPage extends StatefulWidget {
  @override
  _QuestionListPageState createState() => _QuestionListPageState();
}

class _QuestionListPageState extends State<QuestionListPage> {
  bool isLoading = true;
  String errorMessage = '';
  List<Map<String, dynamic>> questionsWithResponses = [];

  @override
  void initState() {
    super.initState();
    _loadQuestionsAndResponses();
  }

  Future<void> _loadQuestionsAndResponses() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final questions = await QuestionService().getAllQuestions();
      
      final List<Map<String, dynamic>> tempQuestionsWithResponses = [];

      for (var question in questions) {
        final responses = await ResponseService().getResponsesByQuestionId(question.id!);
        tempQuestionsWithResponses.add({
          'question': question,
          'responses': responses,
        });
      }

      setState(() {
        questionsWithResponses = tempQuestionsWithResponses;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Questions'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: questionsWithResponses.length,
                  itemBuilder: (context, index) {
                    final question = questionsWithResponses[index]['question'] as Question;
                    final responses = questionsWithResponses[index]['responses'] as List<Response>;

                    // Extraire les IDs des réponses
                    final responseIds = responses.map((response) => response.id!).toList();

                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Naviguer vers la page de mise à jour en passant l'ID de la question et les IDs des réponses
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UpdateQuestionPage(
                                          questionId: question.id!,
                                          responseIds: responseIds, // Passer les IDs des réponses
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text('Update'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // Logique pour supprimer la question
                                    print('Supprimer la question avec ID: ${question.id}');
                                  },
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Question: ${question.question_text}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Réponses:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            ...responses.map((response) => Text('- ${response.reponse_text}')).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
