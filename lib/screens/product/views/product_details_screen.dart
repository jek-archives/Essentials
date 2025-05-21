import 'package:flutter/material.dart';
import 'package:shop/screens/product/views/added_to_cart_message_screen.dart';
import 'package:shop/models/cart.dart';
import 'package:shop/models/product_model.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int id;
  final String name;
  final double price;
  final String imagePath;
  final String category;
  final List<String>? sizes;

  const ProductDetailsScreen({
    super.key,
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.category,
    this.sizes,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String? _selectedSize;
  final Cart _cart = Cart();

  void _addToCart() {
    _cart.addItem(ProductModel(
      id: widget.id,
      image: widget.imagePath,
      title: widget.name,
      brandName: "USTP",
      category: widget.category,
      price: widget.price,
      sizes: [_selectedSize!],
    ));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const AddedToCartMessageScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    widget.imagePath,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Product Details
              Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.category,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '₱${widget.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 24),

              // Available Sizes
              if (widget.sizes != null && widget.sizes!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Sizes:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12.0,
                      runSpacing: 12.0,
                      children: widget.sizes!
                          .map((size) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedSize = size;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _selectedSize == size
                                        ? Colors.blue.shade100
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _selectedSize == size
                                          ? Colors.blue
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                  child: Text(
                                    size,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: _selectedSize == size
                                          ? Colors.blue.shade900
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              const SizedBox(height: 32),

              // Add to Cart Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedSize == null ? null : _addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4A4A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add to Cart',
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
      ),
    );
  }
}
