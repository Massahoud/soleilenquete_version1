import 'package:flutter/material.dart';

class MultipleChoiceQuestion extends StatefulWidget {
  final String questionNumber;
  final String question;
  final List<String> options;
  final ValueChanged<List<String>> onChanged;

  const MultipleChoiceQuestion({
    Key? key,
    required this.questionNumber,
    required this.question,
    required this.options,
    required this.onChanged,
  }) : super(key: key);

  @override
  _MultipleChoiceQuestionState createState() => _MultipleChoiceQuestionState();
}

class _MultipleChoiceQuestionState extends State<MultipleChoiceQuestion> {
  List<String> _selectedOptions = [];

  void _toggleSelection(String option) {
    setState(() {
      if (_selectedOptions.contains(option)) {
        _selectedOptions.remove(option);
      } else {
        _selectedOptions.add(option);
      }
    });
    widget.onChanged(_selectedOptions);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Numéro et texte de la question
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            "${widget.questionNumber}. ${widget.question}",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        // Liste des réponses sous forme de Cards avec Checkbox
        Column(
          children: widget.options.map((option) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Card(
                elevation: 0.5, // Légère élévation
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.grey[100], // Fond légèrement gris
                child: CheckboxListTile(
                  value: _selectedOptions.contains(option),
                  onChanged: (_) => _toggleSelection(option),
                  title: Text(
                    option,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  activeColor: Colors.orange,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12), // Moins d'espace interne
                  controlAffinity: ListTileControlAffinity.leading, // Checkbox à gauche
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
