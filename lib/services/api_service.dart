// import 'dart:convert';
// import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  // Replace this with your actual Go backend URL later (e.g., http://10.0.2.2:8080 for Android Emulator)
  static const String baseUrl = 'http://localhost:8080/api';

  static Future<List<Product>> getProducts() async {
    try {
      // Simulation of a backend request for now
      // TODO: Uncomment actual HTTP request when backend is ready
      /*
      final response = await http.get(Uri.parse('$baseUrl/products'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
      */

      // Simulated network delay to mimic Go backend fetching from MySQL
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock Data representing what Go/MySQL will return
      return [
        Product(id: '1', name: 'Es Kopi Susu Aren', price: 'Rp 15.000', category: 'Drink'),
        Product(id: '2', name: 'Chitato Sapi Panggang', price: 'Rp 11.000', category: 'Snack'),
        Product(id: '3', name: 'Teh Botol Sosro', price: 'Rp 6.000', category: 'Drink'),
        Product(id: '4', name: 'Roti Kasur Cokelat', price: 'Rp 12.000', category: 'Food'),
      ];

    } catch (e) {
      throw Exception('Failed to connect to the backend: $e');
    }
  }

  static Future<bool> login(String identifier, String password) async {
    try {
      // TODO: Uncomment actual HTTP request when backend is ready
      /*
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'identifier': identifier, 'password': password}),
      );
      return response.statusCode == 200;
      */
      
      await Future.delayed(const Duration(seconds: 1));
      return true; // Mock success
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> signup(Map<String, dynamic> userData) async {
    try {
      // TODO: Uncomment actual HTTP request when backend is ready
      /*
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );
      return response.statusCode == 201; // Created
      */
      
      await Future.delayed(const Duration(seconds: 1));
      return true; // Mock success
    } catch (e) {
      return false;
    }
  }
}
