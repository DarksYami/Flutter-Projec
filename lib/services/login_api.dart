import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/view/home_page.dart';
import 'package:flutter_application_1/view/users_dashboard.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginApi {
  static final HttpClient _httpClient = HttpClient()
    ..badCertificateCallback = 
      (X509Certificate cert, String host, int port) => true; // Bypass verification
  static final http.Client client = IOClient(_httpClient);

  static const String baseUrl = "https://192.168.0.81/PHP_API/login.php";

  static Future<void> loginUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      print("Sending email: $email, password: $password");

      final response = await client.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json", // Set content type to JSON
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 1) {
          // Save user data to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('email', email);
          await prefs.setInt('id', data['id']);
          await prefs.setString('isAdmin', data['isAdmin'] as int == 1 ? "Admin" : "Member");

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login successful!')),
          );
          if (data['isAdmin'] as int == 1){
            Navigator.pushReplacement(context, 
            MaterialPageRoute(builder: (context) => UserManagementDashboard()));
          }else{
            Navigator.pushReplacement(context, 
            MaterialPageRoute(builder: (context) => HomePage()));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${data['message']}')),
          );
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}