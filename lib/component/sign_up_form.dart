import 'package:flutter/material.dart';
import 'package:soleilenquete/component/main_layout.dart';
import 'package:soleilenquete/component/resetPassword.dart';

import 'package:soleilenquete/views/auth/login_screen.dart';
import 'package:soleilenquete/widget/children_Card.dart';
import 'package:soleilenquete/widget/custom_text_field.dart';

class SignUpForm extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[200],
          child: Icon(Icons.add_a_photo, size: 40, color: Colors.orange),
        ),
        SizedBox(height: 10),
        Text(
          'Ajouter une photo',
          style: TextStyle(
              fontSize: 14, color: Colors.orange, fontWeight: FontWeight.w600),
        ),
        CustomTextField(
            controller: nameController,
            hintText: 'Votre nom',
            labelText: 'Nom'),
        SizedBox(height: 15),
        CustomTextField(
            controller: surnameController,
            hintText: 'Votre prénom',
            labelText: 'Prénom'),
        SizedBox(height: 15),
        CustomTextField(
            controller: passwordController,
            hintText: 'Créer un mot de passe',
            labelText: 'Mot de passe',
            obscureText: true),
        SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPages()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            minimumSize: Size(double.infinity, 50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          ),
          child: Text(
            "S'inscrire",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
