import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../models/pickup_location_model.dart';
import '../constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Use the API URL from constants
  static String get baseUrl => AppConstants.apiUrl;
  String? _authToken; // Add this for authentication

  // Set auth token
  void setAuthToken(String token) {
    _authToken = token;
  }

  // Get headers with auth if available
  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Token $_authToken';
    }
    return headers;
  }

  // Products
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ProductModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load products: ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<ProductModel> getProduct(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$id/'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return ProductModel.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to load product: ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Pickup Locations
  Future<List<PickupLocation>> getPickupLocations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pickup-locations/'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => PickupLocation.fromJson(json)).toList();
      }
      throw Exception('Failed to load pickup locations: ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Stock Management
  Future<ProductModel> updateStock(int productId, int quantity) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products/$productId/update_stock/'),
        headers: _headers,
        body: json.encode({'quantity': quantity}),
      );
      if (response.statusCode == 200) {
        return ProductModel.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to update stock: ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Order Placement
  Future<bool> placeOrder({
    required int productId,
    required int quantity,
    required String size,
    required double price,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/'),
        headers: _headers,
        body: json.encode({
          'items': [
            {
              'product': productId,
              'quantity': quantity,
              'price': price,
            }
          ],
        }),
      );
      
      if (response.statusCode == 201) {
        return true;
      }
      throw Exception('Failed to place order: ${response.body}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
} 