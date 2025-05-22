import 'package:flutter/material.dart';
import 'package:shop/screens/product/views/added_to_cart_message_screen.dart';
import 'package:shop/models/cart.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/screens/product/views/product_buy_now_screen.dart';
import 'package:shop/components/custom_modal_bottom_sheet.dart';
import 'package:shop/models/pickup_location_model.dart';
import 'package:shop/services/api_service.dart';

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

class _ProductDetailsScreenState extends State<ProductDetailsScreen> with SingleTickerProviderStateMixin {
  String? _selectedSize;
  final Cart _cart = Cart();
  bool _isAddingToCart = false;
  bool _isBuyingNow = false;
  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnimation;
  OverlayEntry? _overlayEntry;
  PickupLocation? _pickupLocation;
  bool _isLoadingPickup = true;

  // Mock product details - In a real app, these would come from your backend
  final Map<String, String> _productDetails = {
    'Material': 'Premium Cotton Blend',
    'Care Instructions': 'Machine wash cold, tumble dry low',
    'Fit': 'Regular fit',
    'Style': 'Casual',
    'Collection': 'Summer 2024',
    'Origin': 'Made in Philippines',
  };

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: Curves.easeInOut,
      ),
    );
    _fetchPickupLocation();
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showToast(String message, bool isSuccess) {
    _removeOverlay();
    
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: size.height * 0.1,
        left: size.width * 0.1,
        right: size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSuccess ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSuccess ? Icons.check_circle : Icons.error,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
    Future.delayed(const Duration(seconds: 2), _removeOverlay);
  }

  Future<void> _addToCart() async {
    if (_selectedSize == null) {
      _showToast('Please select a size first', false);
      return;
    }
    
    setState(() {
      _isAddingToCart = true;
    });
    
    try {
      await _buttonController.forward();
      await _buttonController.reverse();
      
      _cart.addItem(ProductModel(
        id: widget.id,
        image: widget.imagePath,
        title: widget.name,
        brandName: "USTP",
        category: widget.category,
        price: widget.price,
        sizes: [_selectedSize!],
      ));

      if (mounted) {
        _showToast('Added to cart successfully!', true);
        customModalBottomSheet(
          context,
          isDismissible: false,
          child: const AddedToCartMessageScreen(),
        );
      }
    } catch (e) {
      if (mounted) {
        _showToast('Failed to add to cart', false);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  Future<void> _buyNow() async {
    if (_selectedSize == null) {
      _showToast('Please select a size first', false);
      return;
    }
    
    setState(() {
      _isBuyingNow = true;
    });
    
    try {
      await _buttonController.forward();
      await _buttonController.reverse();

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductBuyNowScreen(
              id: widget.id,
              name: widget.name,
              price: widget.price,
              imagePath: widget.imagePath,
              category: widget.category,
              sizes: widget.sizes,
              selectedSize: _selectedSize,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showToast('Failed to proceed with purchase', false);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBuyingNow = false;
        });
      }
    }
  }

  Future<void> _fetchPickupLocation() async {
    setState(() { _isLoadingPickup = true; });
    try {
      final locations = await ApiService().getPickupLocations();
      if (locations.isNotEmpty) {
        setState(() {
          _pickupLocation = locations.first;
        });
      }
    } catch (e) {
      // handle error
    } finally {
      setState(() { _isLoadingPickup = false; });
    }
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
    required bool isLoading,
    required Color backgroundColor,
  }) {
    return Expanded(
      child: ScaleTransition(
        scale: _buttonScaleAnimation,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                Container(
                  height: 400,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                  ),
                  child: Image.asset(
                    widget.imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.category,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Price
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₱${widget.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Product Description
                  const Text(
                    'Product Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Experience the perfect blend of style and comfort with our premium ${widget.name}. Crafted with attention to detail and using high-quality materials, this piece is designed to elevate your wardrobe while ensuring maximum comfort.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Available Sizes
                  if (widget.sizes != null && widget.sizes!.isNotEmpty) ...[
                    const Text(
                      'Available Sizes',
                      style: TextStyle(
                        fontSize: 20,
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
                    const SizedBox(height: 24),
                  ],

                  // Product Details
                  const Text(
                    'Product Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._productDetails.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildDetailItem(entry.key, entry.value),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Stock Status and Quantity
                  Row(
                    children: [
                      Text(
                        'Stock: ',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        widget.price > 0 && widget.sizes != null
                            ? (widget.price > 0 ? (widget.sizes!.isNotEmpty ? 'In Stock' : 'Out of Stock') : 'Out of Stock')
                            : 'Out of Stock',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: widget.price > 0 && widget.sizes != null && widget.sizes!.isNotEmpty
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Pickup Location
                  _isLoadingPickup
                      ? const Center(child: CircularProgressIndicator())
                      : _pickupLocation == null
                          ? const Text('Pickup location is currently unavailable. Please try again later.', style: TextStyle(color: Colors.red))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  "Pickup Location",
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Theme.of(context).dividerColor,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: Theme.of(context).primaryColor,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _pickupLocation!.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _pickupLocation!.address,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Available for pickup during office hours (${_pickupLocation!.operatingHours})",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                  // Action Buttons
                  Row(
                    children: [
                      _buildActionButton(
                        text: 'Add to Cart',
                        onPressed: _addToCart,
                        isLoading: _isAddingToCart,
                        backgroundColor: const Color(0xFF4A4A4A),
                      ),
                      const SizedBox(width: 16),
                      _buildActionButton(
                        text: 'Buy Now',
                        onPressed: _buyNow,
                        isLoading: _isBuyingNow,
                        backgroundColor: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
