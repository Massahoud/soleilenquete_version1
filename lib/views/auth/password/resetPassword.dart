import 'package:flutter/material.dart';
import 'package:soleilenquete/widget/custom_text_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
   final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;

  Future<void> _requestPasswordReset() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    final String email = _emailController.text.trim();
   final Uri url = Uri.parse('https://api.enquetesoleil.com/api/auth/request-reset-password');


    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _message = "Un email de réinitialisation a été envoyé.";
        });
      } else {
        setState(() {
          _message = "Erreur : ${jsonDecode(response.body)['message']}";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Une erreur s'est produite. Vérifiez votre connexion internet.";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
    
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Noomdo2.jpg'), 
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.4), 
            ),
          ),
          Center(
            child: Container(
              width: 450, 
              height: 310, 
              child: Card(
                color: Colors.white, 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Réinitialiser mon mot de passe",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[300], 
                            ),
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.black87),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      CustomTextField(
                        controller: _emailController,
                        hintText: "Votre e-mail",
                        labelText: "E-mail",
                      ),
                      SizedBox(height: 24),
                      _isLoading
                ? CircularProgressIndicator()
                :  ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                             minimumSize: const Size(
                                                    double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                           
                          ),
                          onPressed:  _requestPasswordReset,
                          child: Text(
                            "Réinitialiser",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      
                       if (_message != null)
              Text(
                _message!,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
