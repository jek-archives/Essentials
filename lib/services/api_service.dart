import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../models/pickup_location_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String baseUrl = 'http://localhost:8000/api';
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
    final response = await http.get(Uri.parse('$baseUrl/products/'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ProductModel.fromJson(json)).toList();
    }
    throw Exception('Failed to load products');
  }

  Future<ProductModel> getProduct(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/products/$id/'));
    if (response.statusCode == 200) {
      return ProductModel.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load product');
  }

  // Pickup Locations
  Future<List<PickupLocation>> getPickupLocations() async {
    final response = await http.get(Uri.parse('$baseUrl/pickup-locations/'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => PickupLocation.fromJson(json)).toList();
    }
    throw Exception('Failed to load pickup locations');
  }

  // Stock Management
  Future<ProductModel> updateStock(int productId, int quantity) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products/$productId/update_stock/'),
      headers: _headers,
      body: json.encode({'quantity': quantity}),
    );
    if (response.statusCode == 200) {
      return ProductModel.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to update stock');
  }

  // Order Placement
  Future<bool> placeOrder({
    required int productId,
    required int quantity,
    required String size,
    required double price,
  }) async {
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
  }
} 