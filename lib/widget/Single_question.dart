import 'package:flutter/material.dart';

class SingleChoiceQuestion extends StatefulWidget {
  final String questionNumber;
  final String question;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const SingleChoiceQuestion({
    Key? key,
    required this.questionNumber,
    required this.question,
    required this.options,
    required this.onChanged,
  }) : super(key: key);

  @override
  _SingleChoiceQuestionState createState() => _SingleChoiceQuestionState();
}

class _SingleChoiceQuestionState extends State<SingleChoiceQuestion> {
  String? _selectedOption;

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
        // Liste des réponses sous forme de Cards
        Column(
          children: widget.options.map((option) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Card(
                elevation: 0.2, // Légère élévation
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.grey[100], // Fond légèrement gris
                child: RadioListTile<String>(
                  value: option,
                  groupValue: _selectedOption,
                  onChanged: (value) {
                    setState(() {
                      _selectedOption = value;
                    });
                    widget.onChanged(value);
                  },
                  title: Text(
                    option,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  activeColor: Colors.orange,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12), // Moins d'espace interne
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
