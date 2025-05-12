import 'package:flutter/material.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/screens/product/views/added_to_cart_message_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String name;
  final double price;
  final String imagePath;
  final String category;
  final List<String>? sizes;

  const ProductDetailsScreen({
    super.key,
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
  String? _selectedSize; // To store the selected size

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: const Color(0xFF4A4A4A),
      ),
      body: Padding(
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
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    widget.category == 'Souvenir' ? Icons.card_giftcard : Icons.checkroom,
                    size: 100,
                    color: Colors.black45,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Product Details
            Text(
              widget.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.category,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₱${widget.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),

            // Available Sizes
            if (widget.sizes != null && widget.sizes!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Sizes:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    children: widget.sizes!
                        .map((size) => ChoiceChip(
                              label: Text(size),
                              selected: _selectedSize == size,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedSize = selected ? size : null;
                                });
                              },
                              selectedColor: Colors.blue.shade100,
                              backgroundColor: Colors.grey.shade200,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            const Spacer(),

            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedSize == null
                    ? null // Disable button if no size is selected
                    : () {
                        // Add the product to the cart
                        final product = ProductModel(
                          image: widget.imagePath,
                          title: widget.name,
                          brandName: 'USTP', // Replace with actual brand if needed
                          category: widget.category,
                          price: widget.price,
                          sizes: [_selectedSize!], // Add the selected size
                        );

                        // Navigate to the AddedToCartMessageScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddedToCartMessageScreen(),
                          ),
                        );

                        // Show a message or perform any other action
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Product added to cart with size $_selectedSize!'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A4A4A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}