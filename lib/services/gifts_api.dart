import 'package:flutter_application_1/database/api.dart';
import 'dart:convert';
import 'package:flutter_application_1/model/gifts.dart';

String baseUrl = ApiService.baseUrl;
final _client = ApiService.client;

// Fetch all gifts
Future<List<Gift>> fetchGifts() async {
  final response = await _client.get(Uri.parse("$baseUrl?table=gifts"));
  if (response.statusCode == 200) {
    Iterable json = jsonDecode(response.body);
    return List<Gift>.from(json.map((model) => Gift.fromJson(model)));
  } else {
    throw Exception('Failed to load gifts');
  }
}

// Fetch gift by id
Future<Gift> fetchGiftById(int id) async {
  final response = await _client.get(Uri.parse("$baseUrl?table=gifts&id=$id"));
  if (response.statusCode == 200) {
    return Gift.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load gift');
  }
}

// Fetch gifts by category
Future<List<Gift>> fetchGiftsByCategory(String category) async {
  final response = await _client.get(Uri.parse("$baseUrl?table=gifts&category=\"$category\""));
  if (response.statusCode == 200) {
    Iterable json = jsonDecode(response.body);
    return List<Gift>.from(json.map((model) => Gift.fromJson(model)));
  } else {
    throw Exception('Failed to load gifts');
  }
}

// Add a gift
Future<void> addGift(String name, double price, String image, int quantity, String category) async {
  final response = await _client.post(
    Uri.parse("$baseUrl?table=gifts"),
    body: jsonEncode({
      "name": name,
      "price": price,
      "image": image,
      "quantity": quantity,
      "category": category,
    }),
    headers: {"Content-Type": "application/json"},
  );
  if (response.statusCode != 201) { // Assuming 201 Created for a successful addition
    throw Exception('Failed to add gift');
  }
}

// Update a gift
Future<void> updateGift(int id, String name, double price, String image, int quantity, String category) async {
  final response = await _client.put(
    Uri.parse("$baseUrl?table=gifts&id=$id"),
    body: jsonEncode({
      "name": name,
      "price": price,
      "image": image,
      "quantity": quantity,
      "category": category,
    }),
    headers: {"Content-Type": "application/json"},
  );
  if (response.statusCode != 200) { // Assuming 200 OK for a successful update
    throw Exception('Failed to update gift');
  }
}

// Delete a gift
Future<void> deleteGift(int id) async {
  final response = await _client.delete(Uri.parse("$baseUrl?table=gifts&id=$id"));
  if (response.statusCode != 200) { // Assuming 200 OK for a successful deletion
    throw Exception('Failed to delete gift');
  }
}
