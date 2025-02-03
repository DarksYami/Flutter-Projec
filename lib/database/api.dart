import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class ApiService {
  static final HttpClient _httpClient = HttpClient()
  ..badCertificateCallback = 
    (X509Certificate cert, String host, int port) => true; // Bypass verification
  static final http.Client client = IOClient(_httpClient);

  static const String baseUrl = "https://192.168.0.81/PHP_API/api.php";
}