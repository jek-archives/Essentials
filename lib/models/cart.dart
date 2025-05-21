import 'package:flutter/foundation.dart';
import 'product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'order_payload.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, required this.quantity});
}

class Cart extends ChangeNotifier {
  static final Cart _instance = Cart._internal();
  factory Cart() => _instance;
  Cart._internal();

  final List<CartItem> _items = [];
  List<CartItem> get cartItems => List.unmodifiable(_items);
  double get total => _items.fold(0, (sum, item) => sum + (item.product.price * item.quantity));

  void addItem(ProductModel product) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(product: product, quantity: 1));
    }
    notifyListeners();
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void incrementQuantity(int index) {
    if (index >= 0 && index < _items.length) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(int index) {
    if (index >= 0 && index < _items.length) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  Future<void> saveCartForUser(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(_items.map((item) => {
        'productId': item.product.id,
        'quantity': item.quantity,
      }).toList());
      
      await prefs.setString('cart_$email', cartJson);
      print('DEBUG: Saved cart items for user $email');
    } catch (e) {
      print('DEBUG: Error saving cart: $e');
    }
  }

  Future<void> loadCartForUser(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('cart_$email');
      
      if (cartJson != null) {
        final List<dynamic> cartData = jsonDecode(cartJson);
        _items.clear();
        
        for (var item in cartData) {
          final productId = item['productId'] as int;
          final quantity = item['quantity'] as int;
          
          // Find the product in the products list
          final product = products.firstWhere(
            (p) => p.id == productId,
            orElse: () => throw Exception('Product not found: $productId'),
          );
          
          _items.add(CartItem(product: product, quantity: quantity));
        }
        
        notifyListeners();
        print('DEBUG: Loaded cart items for user $email');
      }
    } catch (e) {
      print('DEBUG: Error loading cart: $e');
    }
  }

  OrderPayload toOrderPayload() {
    print('DEBUG: Converting cart to order payload');
    print('DEBUG: Cart items: ${_items.map((item) => '${item.product.id}: ${item.quantity}').join(', ')}');
    return OrderPayload(
      items: _items.map((cartItem) => OrderItemPayload(
        product: cartItem.product.id,
        quantity: cartItem.quantity,
        price: cartItem.product.price,
      )).toList(),
    );
  }
}
