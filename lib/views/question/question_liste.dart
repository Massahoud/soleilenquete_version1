import 'package:flutter/material.dart';
import 'package:soleilenquete/component/filters.dart';
import 'package:soleilenquete/component/search_bar.dart';
import 'package:soleilenquete/views/HomePage.dart';
import 'package:soleilenquete/views/question/update_question.dart';
import '../../models/question_model.dart';
import '../../models/reponse_model.dart';
import '../../services/question_service.dart';
import '../../services/response_service.dart';

class QuestionListPage extends StatefulWidget {
  @override
  _QuestionListPageState createState() => _QuestionListPageState();
}

class _QuestionListPageState extends State<QuestionListPage> {
  String errorMessage = '';
  List<Map<String, dynamic>> questionsWithResponses = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
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
        'responses': null, // Placeholder en attendant les réponses
      });
    });

    try {
      final responses = await ResponseService().getResponsesByQuestionId(question.id!);
      setState(() {
        final index = questionsWithResponses.indexWhere((q) => q['question'].id == question.id);
        if (index != -1) {
          questionsWithResponses[index]['responses'] = responses;
        }
      });
    } catch (e) {
      print("Erreur lors du chargement des réponses: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body:Row(
        children:[
           Container(
            width: MediaQuery.of(context).size.width * 0.2, // 20% of screen width
            color: Colors.blue, // Customize this as needed
            child: HomePage(), // Replace with your widget
          ),
          Expanded(
            child: Column(
              children:[
                 SearchBarWidget(),
                  SizedBox(height: 20),
              Filters(),
              Expanded(
                child : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
          : ListView.builder(
              itemCount: questionsWithResponses.length,
              itemBuilder: (context, index) {
                final question = questionsWithResponses[index]['question'] as Question;
                final responses = questionsWithResponses[index]['responses'] as List<Response>?;

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
                                if (responses != null) {
                                  final responseIds = responses.map((r) => r.id!).toList();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UpdateQuestionPage(
                                        questionId: question.id!,
                                        responseIds: responseIds,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Text('Update'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                print('Supprimer la question avec ID: ${question.id}');
                              },
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Question: ${question.question_text}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Réponses:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        if (responses == null)
                          Center(child: CircularProgressIndicator())
                        else if (responses.isEmpty)
                          Text('Aucune réponse disponible')
                        else
                          ...responses.map((response) => Text('- ${response.reponse_text}')),
                      ],
                    ),
                  ),
                );
              },
            ),
    )]),)],));
  }
}
