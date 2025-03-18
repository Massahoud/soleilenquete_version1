
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';


class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;
  String? _role;

  String? get token => _token;
  String? get userId => _userId;
  String? get role => _role;

  Future<void> loadUser() async {
    final storage = FlutterSecureStorage();
    _token = await storage.read(key: 'authToken');
    _userId = await storage.read(key: 'userId');
    _role = await storage.read(key: 'userRole');
    notifyListeners();
  }
}