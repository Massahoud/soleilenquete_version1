import 'package:flutter/material.dart';
import '../../models/question_model.dart';
import '../../models/reponse_model.dart';
import '../../services/question_service.dart';
import '../../services/response_service.dart';
class SurveyCard extends StatefulWidget {
  
  @override
  _SurveyCardState createState() => _SurveyCardState();
}

class _SurveyCardState extends State<SurveyCard> {
  String? selectedOption;
  List<int> dropdownValues = List.generate(6, (index) => 1);
String selectedType = 'text';

  TextEditingController questionController =
      TextEditingController(text: "Es-tu un ancien de NOOMDO ?");
  List<String> options = ["Oui, mais je ne le suis plus", "Non"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(title: Text("Survey Question")),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        width: 200,
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border:
                              Border.all(color: Colors.grey.shade400, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: TextField(
                          controller: questionController,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 10),

                  
                    DropdownButton<String>(
                      value: selectedType,
                      onChanged: (String? newValue) {
                        setState(() {});
                      },
                      items: <String>[
                        'text',
                        'reponseunique',
                        'reponsemultiples',
                        'photos'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                SizedBox(height: 15),

                
                Column(
                  children:
                      options.map((option) => buildOption(option)).toList(),
                ),

             
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      options.add("Nouvelle option");
                    });
                  },
                  icon: Icon(Icons.add, color: Colors.orange),
                  label: Text("Ajouter une option",
                      style: TextStyle(color: Colors.orange)),
                ),

                SizedBox(height: 10),

               
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.copy, color: Colors.grey),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildOption(String text) {
    TextEditingController optionController = TextEditingController(text: text);
    return Column(
      children: [
        ListTile(
          leading: Radio<String>(
            value: text,
            groupValue: selectedOption,
            onChanged: (value) {
              setState(() {
                selectedOption = value;
              });
            },
          ),
          title: Container(
            width: 200, 
            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade400, width: 1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: TextField(
              controller: optionController,
              style: TextStyle(fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
              onChanged: (value) {
              
                setState(() {
                  options[options.indexOf(text)] = value;
                });
              },
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(6, (dropdownIndex) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: SizedBox(
                  width: 100,
                  child: DropdownButton<int>(
                    value: dropdownValues[dropdownIndex],
                    items: List.generate(
                        5,
                        (i) => DropdownMenuItem(
                            value: i + 1, child: Text('${i + 1}'))),
                    onChanged: (value) {
                      setState(() {
                        dropdownValues[dropdownIndex] = value!;
                      });
                    },
                  ),
                ),
              );
            }),
          ),
        ),
        Divider(),
      ],
    );
  }
}
