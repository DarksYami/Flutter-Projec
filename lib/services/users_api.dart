import 'package:flutter_application_1/database/api.dart';
import 'dart:convert';

String baseUrl = ApiService.baseUrl;
final _client = ApiService.client;

  // Fetch all users
  Future<List<dynamic>> fetchUsers() async {
    final response = await _client.get(Uri.parse("$baseUrl?table=users"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load users');
    }
  }

  //  Fetch user by id
  Future <List<dynamic>> fetchUserById(int id) async {
    final response = await _client.get(Uri.parse("$baseUrl?table=users&id=$id"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user');
    }
  }

  //  Fetch user by email
  Future <List<dynamic>> fetchUserByEmail(String email) async {
    final response = await _client.get(Uri.parse("$baseUrl?table=users&email=\"$email\""));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user');
    }
  }

  // Add a user
  Future<void> addUser(String email, String password, int isAdmin) async {
    final response = await _client.post(
      Uri.parse("$baseUrl?table=users"),
      body: jsonEncode({
        "email": email,
        "password": password,
        "isAdmin": isAdmin
      }),
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add user');
    }
  }

  // Update a user
  Future<void> updateUser(int id, String email, String password, int isAdmin) async {
    final response = await _client.put(
      Uri.parse("$baseUrl?table=users&id=$id"),
      body: jsonEncode({
        "email": email,
        "password": password,
        "isAdmin": isAdmin,
      }),
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update user');
    }
  }

  // Delete a user
  Future<void> deleteUser(int id) async {
    final response = await _client.delete(Uri.parse("$baseUrl?table=users&id=$id"));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete user');
    }
  }

