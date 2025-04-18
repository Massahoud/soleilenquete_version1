import 'package:flutter/material.dart';
import 'package:soleilenquete/component/sign_up_form.dart';
class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Row(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/Noomdo2.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.white,
            child:SingleChildScrollView(child:
             Padding(

              
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/téléchargement.jpeg',
                    height: 150,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Complétez vos informations pour continuer.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  SignUpForm(),
                ],
              ),
            ),
            ),
          )),
        ],
      ),
      
    );
    
  }
}



