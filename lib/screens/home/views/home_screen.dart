import 'package:flutter/material.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/components/product/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _categories = ['Souvenirs', 'Uniforms', 'Essentials'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          children: [
            // Categories
            SizedBox(
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  _categories.length,
                  (index) => _buildCategoryItem(index),
                ),
              ),
            ),

            // Products Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  itemCount: demoPopularProducts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    final product = demoPopularProducts[index];
                    return ProductCard(
                      product: product, // Pass the entire ProductModel object
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(int index) {
    return GestureDetector(
      onTap: () {
        // Handle category selection
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            index == 0
                ? Icons.card_giftcard
                : index == 1
                    ? Icons.checkroom
                    : Icons.book,
          ),
          const SizedBox(height: 8),
          Text(_categories[index]),
        ],
      ),
    );
  }
}
