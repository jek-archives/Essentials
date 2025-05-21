import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class User {
  String? name;
  String? dob;
  String? phone;
  String? gender;
  String? email;
  String? imageUrl;
  String? token;

  static final User _instance = User._internal();

  factory User() => _instance;

  User._internal() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('auth_token');
      print('DEBUG: Loaded token from SharedPreferences: $token');
    } catch (e) {
      print('DEBUG: Error loading token: $e');
    }
  }

  String getDisplayValue(String? value) {
    return (value == null || value.isEmpty) ? 'Not set' : value;
  }

  void updateFromMap(Map<String, dynamic> data) {
    name = data['name'] ?? name;
    dob = data['dob'] ?? dob;
    phone = data['phone'] ?? phone;
    gender = data['gender'] ?? gender;
    email = data['email'] ?? email;
    imageUrl = data['imageUrl'] ?? imageUrl;
    token = data['token'] ?? token;
  }

  void updateFromRegistration({
    required String firstName,
    required String lastName,
    required String email,
    String? token,
  }) {
    name = '$firstName $lastName';
    this.email = email;
    if (token != null) {
      this.token = token;
      _saveToken(token);
    }
  }

  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      print('DEBUG: Saved token to SharedPreferences: $token');
    } catch (e) {
      print('DEBUG: Error saving token: $e');
    }
  }

  Future<bool> saveToBackend() async {
    if (token == null) {
      print('DEBUG: Cannot save user data - no token available');
      return false;
    }

    try {
      final response = await http.put(
        Uri.parse('${apiBaseUrl}/users/me/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode({
          'name': name,
          'dob': dob,
          'phone': phone,
          'gender': gender,
          'email': email,
          'imageUrl': imageUrl,
        }),
      );

      if (response.statusCode == 200) {
        print('DEBUG: Successfully saved user data to backend');
        // Save to SharedPreferences as backup
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', name ?? '');
        await prefs.setString('user_email', email ?? '');
        await prefs.setString('user_image', imageUrl ?? '');
        return true;
      } else {
        print('DEBUG: Failed to save user data. Status code: ${response.statusCode}');
        print('DEBUG: Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('DEBUG: Error saving user data: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      token = null;
      name = null;
      email = null;
      imageUrl = null;
      print('DEBUG: User logged out and token removed');
    } catch (e) {
      print('DEBUG: Error during logout: $e');
    }
  }
}