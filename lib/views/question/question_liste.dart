import 'package:flutter/material.dart';
import 'package:soleilenquete/component/filtre/filtreQuestion.dart';

import 'package:soleilenquete/component/search_bar.dart';
import 'package:soleilenquete/views/HomePage.dart';
import 'package:soleilenquete/views/question/update_question.dart';
import 'package:soleilenquete/widget/customDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/question_model.dart';
import '../../../models/reponse_model.dart';
import '../../../services/question_service.dart';
import '../../../services/response_service.dart';

class QuestionsPage extends StatefulWidget {
  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionsPage> {
  String errorMessage = '';
  List<Map<String, dynamic>> questionsWithResponses = [];
  String _searchQuery = '';
  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }
 void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }
 List<Map<String, dynamic>> _filteredQuestions() {
    return questionsWithResponses.where((q) {
      final question = q['question'] as Question;
      final numeroMatch = question.numero.toString().contains(_searchQuery);
      final textMatch =
          question.question_text.toLowerCase().contains(_searchQuery);
      return numeroMatch || textMatch;
    }).toList();
  }
  Future<void> _loadQuestions() async {
    try {
      final questions = await QuestionService().getAllQuestions();
      for (var question in questions) {
        _loadResponses(question);
      }
    } catch (e) {
     if (e.toString().contains('Unauthorized')) {
      
      showRoleErrorDialog();
    }
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
      showSessionExpiredDialog();
    } 
  }
}


void showRoleErrorDialog()async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('authToken'); // Suppression du token
  await prefs.remove('userRole'); // Suppression du rôle de l'utilisateur
  await prefs.remove('userId'); // Suppression de l'ID de l'utilisateur
 Future.delayed(Duration.zero, () {
  showDialog(
    context: context,
    builder: (context) => CustomDialog(
      title: "Ereur",
      content: "Vous n'avez pas les droits pour accéder à cette page",
      buttonText: "OK",
      onPressed: () {
        Navigator.pushReplacementNamed(context, '/login');
      },
  ));
 });
}
void showSessionExpiredDialog()async {
 final prefs = await SharedPreferences.getInstance();
  await prefs.remove('authToken'); // Suppression du token
  await prefs.remove('userRole'); // Suppression du rôle de l'utilisateur
  await prefs.remove('userId'); // Suppression de l'ID de l'utilisateur
 Future.delayed(Duration.zero, () {
  showDialog(
    context: context,
    builder: (context) => CustomDialog(
      title: "Session Expirée",
      content: "Votre session a expiré. Veuillez vous reconnecter.",
      buttonText: "OK",
      onPressed: () {
        Navigator.pushReplacementNamed(
          context,
          '/login',
        );
      },
    ),
  );
});
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Fond personnalisé pour le Scaffold
      body: Row(
        children: [
          // Panneau latéral gauche
          Container(
            width:
                MediaQuery.of(context).size.width * 0.2, // 20% of screen width
            color: Colors.blue, // Customize this as needed
            child: HomePage(), // Remplacer par ton widget
          ),

          // Section principale à droite
          Expanded(
            child: Column(
              children: [
               SearchBarWidget(
                  onSearch: _updateSearchQuery, // Associe la recherche
                ),
                SizedBox(height: 20),
                FiltersQuestion(),
                // Card principale avec contenu
                Card(
                  color: Colors.white, // Fond blanc pour la Card
                  elevation: 4, // Ajoute de l'ombre
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        10), // Coins arrondis pour la card
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Contenu de _buildHeaderAndTabs
                        _buildHeaderAndTabs(),
                        SizedBox(height: 10),
                        // Contenu de _buildQuestionCard
                        _buildQuestionCard(), // Pas besoin de Expanded ici, la Card s'ajuste automatiquement
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildQuestionCard() {
        final filteredQuestions = _filteredQuestions();
    return errorMessage.isNotEmpty
        ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
        : SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height *
                      0.65, // Adjust the height
                  child: ListView.builder(
                   itemCount: _filteredQuestions().length,

                    itemBuilder: (context, index) {
                     final question = _filteredQuestions()[index]['question'] as Question;
final responses = _filteredQuestions()[index]['responses'] as List<Response>? ?? [];

                      return Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // Alignement au début
                              children: [
                                Expanded(
                                  child: Text(
                                    '${question.numero}: ${question.question_text}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    final String questionId = question.id ?? '';
                                    final List<String> responseIds = responses
                                        .map((response) => response.id ?? '')
                                        .toList();

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UpdateQuestionPage(
                                          questionId: questionId,
                                          responseIds: responseIds,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Column(
                              children: responses
                                  .map(
                                      (response) => _buildResponseRow(response))
                                  .toList(),
                            ),
                            Divider(thickness: 1),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }

 
  Widget _buildHeaderAndTabs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Questions et réponses",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 180),
            Expanded(child: _buildCategoryTabs()),
          ],
        ),
        SizedBox(height: 10),
        Divider(thickness: 1),
      ],
    );
  }


  Widget _buildCategoryTabs() {
    List<String> categories = [
      "Alimentation",
      "Cadre de vie",
      "Éducation",
      "Pauvreté",
      "Santé physique",
      "Violence",
      "Indices"
    ];

    return Row(
      children: [
        SizedBox(width: 80),
        for (var category in categories)
          Flexible(
            // ✅ Utilisation correcte
            child: Center(
              child: Text(
                category,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  /// 🔹 Tableau des Réponses
  Widget _buildResponseTable(List<Response> responses) {
    return Column(
      children:
          responses.map((response) => _buildResponseRow(response)).toList(),
    );
  }

  /// 🔹 Widget affichant le label ("Oui" ou "Non")

  Widget _buildResponseValues(Response response) {
    // Crée une liste de catégories à afficher, en utilisant les propriétés de la réponse,
    // et convertit les valeurs non-String en String si nécessaire.
    List<String> categories = [
      (response.alimentation?.toString() ?? "Non spécifié"),
      (response.cadre_vie?.toString() ?? "Non spécifié"),
      (response.education?.toString() ?? "Non spécifié"),
      (response.pauvrete?.toString() ?? "Non spécifié"),
      (response.sante_physique?.toString() ?? "Non spécifié"),
      (response.violence?.toString() ?? "Non spécifié"),
      (response.indice_sortir?.toString() ?? "Non spécifié"),
    ];

    return Expanded(
      child: Row(
        children: categories.map((categoryValue) {
          return Expanded(
            child: Center(
              child: Text(
                categoryValue, // Affiche la valeur de chaque catégorie
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResponseRow(Response response) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Afficher la question ou la réponse textuelle (avec vérification si vide)
          SizedBox(
            width: 300,
            child: response.reponse_text.isNotEmpty
                ? Text(
                    response
                        .reponse_text, // Affichage de la réponse textuelle si elle existe
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  )
                : TextField(
                    enabled:
                        false, // Désactive le champ de texte pour éviter toute modification
                    decoration: InputDecoration(
                      hintText: "Réponse non fournie", // Texte de remplacement
                      filled: true,
                      fillColor: Colors.grey[
                          300], // Couleur de fond pour indiquer que c'est un champ non modifiable
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ), // Affichage du champ de texte obscurci
          ),

          // Affichage des valeurs de réponses spécifiques par catégorie
          SizedBox(width: 150),
          _buildResponseValues(
              response), // Passer la réponse à la méthode _buildResponseValues
        ],
      ),
    );
  }
}
