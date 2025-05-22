import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/components/cart_button.dart';
import 'package:shop/components/custom_modal_bottom_sheet.dart';
import 'package:shop/screens/product/views/added_to_cart_message_screen.dart';
import 'package:shop/screens/product/views/components/product_list_tile.dart';
import 'package:shop/screens/product/views/size_guide_screen.dart';
import 'package:shop/models/cart.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/models/pickup_location_model.dart';
import 'package:shop/services/api_service.dart';

import '../../../constants.dart';
import 'components/product_quantity.dart';
import 'components/selected_size.dart';
import 'components/unit_price.dart';

class ProductBuyNowScreen extends StatefulWidget {
  final int id;
  final String name;
  final double price;
  final String imagePath;
  final String category;
  final List<String>? sizes;
  final String? selectedSize;

  const ProductBuyNowScreen({
    super.key,
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.category,
    this.sizes,
    this.selectedSize,
  });

  @override
  _ProductBuyNowScreenState createState() => _ProductBuyNowScreenState();
}

class _ProductBuyNowScreenState extends State<ProductBuyNowScreen> {
  String? _selectedSize;
  int _quantity = 1;
  final Cart _cart = Cart();
  PickupLocation? _pickupLocation;
  bool _isLoadingPickup = true;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.selectedSize;
    _fetchPickupLocation();
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

  Future<void> _placeOrder() async {
    if (_selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a size first')),
      );
      return;
    }

    try {
      // Place the order
      final orderSuccess = await ApiService().placeOrder(
        productId: widget.id,
        quantity: _quantity,
        size: _selectedSize!,
        price: widget.price,
      );

      if (orderSuccess) {
        // Decrement stock after successful order
        await ApiService().updateStock(widget.id, -_quantity);
        
        if (mounted) {
          customModalBottomSheet(
            context,
            isDismissible: false,
            child: const AddedToCartMessageScreen(),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CartButton(
        price: widget.price * _quantity,
        title: "Add to cart",
        subTitle: "Total price",
        press: _placeOrder,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding / 2, vertical: defaultPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BackButton(),
                Text(
                  widget.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset("assets/icons/Bookmark.svg",
                      color: Theme.of(context).textTheme.bodyLarge!.color),
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                    child: AspectRatio(
                      aspectRatio: 1.05,
                      child: Image.asset(
                        widget.imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(defaultPadding),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: UnitPrice(
                            price: widget.price,
                            priceAfterDiscount: widget.price * 0.93, // 7% discount
                          ),
                        ),
                        ProductQuantity(
                          numOfItem: _quantity,
                          onIncrement: () {
                            setState(() {
                              _quantity++;
                            });
                          },
                          onDecrement: () {
                            if (_quantity > 1) {
                              setState(() {
                                _quantity--;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: Divider()),
                if (widget.sizes != null && widget.sizes!.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SelectedSize(
                      sizes: widget.sizes!,
                      selectedIndex: widget.sizes!.indexOf(_selectedSize ?? widget.sizes![0]),
                      press: (value) {
                        setState(() {
                          _selectedSize = widget.sizes![value];
                        });
                      },
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                  sliver: ProductListTile(
                    title: "Size guide",
                    svgSrc: "assets/icons/Sizeguid.svg",
                    isShowBottomBorder: true,
                    press: () {
                      customModalBottomSheet(
                        context,
                        height: MediaQuery.of(context).size.height * 0.9,
                        child: const SizeGuideScreen(),
                      );
                    },
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                  sliver: SliverToBoxAdapter(
                    child: _isLoadingPickup
                        ? const Center(child: CircularProgressIndicator())
                        : _pickupLocation == null
                            ? const Text('Pickup location is currently unavailable. Please try again later.', style: TextStyle(color: Colors.red))
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: defaultPadding / 2),
                                  Text(
                                    "Pickup Location",
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: defaultPadding / 2),
                                  Container(
                                    padding: const EdgeInsets.all(defaultPadding),
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
                  ),
                ),
                const SliverToBoxAdapter(
                    child: SizedBox(height: defaultPadding))
              ],
            ),
          )
        ],
      ),
    );
  }
}
