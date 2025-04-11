import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:soleilenquete/app_routes.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Supprime le "#" dans l'URL
  setUrlStrategy(PathUrlStrategy());

  // Vérifier et enregistrer le token
  Uri uri = Uri.base;
  String? token = uri.queryParameters["token"];

  if (token != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);

    // Nettoyer l'URL (supprimer le token)
    html.window.history.pushState(null, '', uri.path);
  }

  runApp(MyApp());
}
