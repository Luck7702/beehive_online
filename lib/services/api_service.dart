import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/product.dart';

class ApiService {
  static String get baseUrl => '${dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:3000'}/api';

  // Store the JWT token after login
  static String? _token;
  static String? _role;
  static String? _userName;

  static String? get token => _token;
  static String? get role => _role;
  static String? get userName => _userName;

  static Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // ============================
  // PRODUCTS
  // ============================
  static Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Failed to connect to the backend: $e');
    }
  }

  // ============================
  // AUTHENTICATION
  // ============================
  static Future<Map<String, dynamic>> login(String nim, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'nim': nim, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
        _role = data['role'];
        _userName = data['name'];
        return {'success': true, 'role': _role};
      } else {
        return {'success': false};
      }
    } catch (e) {
      return {'success': false};
    }
  }

  static Future<bool> signup(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static void logout() {
    _token = null;
    _role = null;
    _userName = null;
  }

  // ============================
  // ORDERS (Worker Bulletin)
  // ============================
  static Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      throw Exception('Failed to fetch orders: $e');
    }
  }

  static Future<bool> updateOrderStatus(int orderId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: _authHeaders,
        body: json.encode({'status': status}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ============================
  // PLACE ORDER (Student)
  // ============================
  static Future<int?> placeOrder({
    required int totalPrice,
    required String building,
    required String floor,
    required String room,
    required List<Map<String, dynamic>> items,
    required String paymentMethod,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: _authHeaders,
        body: json.encode({
          'total_price': totalPrice,
          'delivery_building': building,
          'delivery_floor': floor,
          'delivery_room': room,
          'items': items,
          'payment_method': paymentMethod,
        }),
      );
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['orderId'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============================
  // QRIS & HISTORY (Student)
  // ============================
  static Future<List<Map<String, dynamic>>> getOrderHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/history'),
        headers: _authHeaders,
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error fetching history: $e');
      return [];
    }
  }

  static Future<bool> uploadPaymentProof(int orderId, String filePath) async {
    if (_token == null) return false;
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/orders/$orderId/payment-proof'),
      );
      request.headers['Authorization'] = 'Bearer $_token';
      request.files.add(await http.MultipartFile.fromPath('proof', filePath));

      var response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      print('Error uploading proof: $e');
      return false;
    }
  }

  // ============================
  // WORKER PAYMENT VERIFICATION
  // ============================
  static Future<bool> verifyPayment(int orderId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId/verify'),
        headers: _authHeaders,
        body: json.encode({'status': status}), // 'verified' or 'failed'
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
