import 'package:flutter/material.dart';
import 'package:shop/models/cart.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        centerTitle: true,
      ),
      body: Cart.cartItems.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty!',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: Cart.cartItems.length,
              itemBuilder: (context, index) {
                final item = Cart.cartItems[index];
                return ListTile(
                  leading: Image.asset(
                    item.image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(item.title),
                  subtitle: Text('Size: ${item.sizes?.first ?? 'N/A'}'),
                  trailing: Text(
                    '₱${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
