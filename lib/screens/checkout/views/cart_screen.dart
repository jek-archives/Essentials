import 'package:flutter/material.dart';
import 'package:shop/models/cart.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/models/order_payload.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/user.dart';
import 'package:shop/route/route_constants.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final Cart _cart = Cart();
  bool _isLoading = false;

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    print('DEBUG: Token from SharedPreferences: $token');
    print('DEBUG: All SharedPreferences keys: ${prefs.getKeys()}');
    
    // Also check User singleton
    final userToken = User().token;
    print('DEBUG: Token from User singleton: $userToken');
    
    // If token is missing from SharedPreferences but present in User singleton, save it
    if (token == null && userToken != null) {
      print('DEBUG: Token missing from SharedPreferences, saving from User singleton');
      await prefs.setString('auth_token', userToken);
      return userToken;
    }
    
    return token;
  }

  Future<void> _checkout() async {
    if (_cart.cartItems.isEmpty) return;
    setState(() { _isLoading = true; });
    final orderPayload = _cart.toOrderPayload();
    final url = Uri.parse('${apiBaseUrl}/orders/');
    final String? token = await getAuthToken();
    print('DEBUG: Attempting checkout with token: $token');
    if (token == null) {
      setState(() { _isLoading = false; });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Not Logged In'),
          content: const Text('Please log in to complete your purchase.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, logInScreenRoute);
              },
              child: const Text('Go to Login'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
      return;
    }
    try {
      print('DEBUG: Sending request to: $url');
      print('DEBUG: Request headers: {"Content-Type": "application/json", "Authorization": "Token $token"}');
      print('DEBUG: Request body: ${jsonEncode(orderPayload.toJson())}');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode(orderPayload.toJson()),
      );
      print('DEBUG: Response status code: ${response.statusCode}');
      print('DEBUG: Response body: ${response.body}');
      setState(() { _isLoading = false; });
      if (response.statusCode == 201) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Checkout Successful'),
            content: const Text('Thank you for your purchase!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _cart.clearCart();
                  });
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        final errorMessage = json.decode(response.body)['error'] ?? response.body;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Checkout Failed'),
            content: Text('Error: $errorMessage'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() { _isLoading = false; });
      print('DEBUG: Checkout error: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Checkout Failed'),
          content: Text('Error: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shopping Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cart.cartItems.isEmpty
          ? const Center(
              child: Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
              ),
            )
          : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _cart.cartItems.length,
              itemBuilder: (context, index) {
                    final cartItem = _cart.cartItems[index];
                    return _buildCartItem(cartItem, index);
                  },
                ),
      bottomNavigationBar: _cart.cartItems.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₱${_cart.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _checkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A4A4A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Proceed to Checkout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCartItem(CartItem cartItem, int index) {
    final item = cartItem.product;
    return Dismissible(
      key: Key('${item.id}_${item.sizes != null && item.sizes!.isNotEmpty ? item.sizes!.first : ''}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          _cart.removeItem(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.title} removed from cart'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  item.image,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.brandName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (item.sizes != null && item.sizes!.isNotEmpty)
                      Text(
                        'Size: ${item.sizes!.first}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '₱${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              // Quantity controls
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      setState(() {
                        _cart.decrementQuantity(index);
                      });
                    },
                  ),
                  Text(
                    cartItem.quantity.toString(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      setState(() {
                        _cart.incrementQuantity(index);
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
