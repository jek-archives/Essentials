class OrderItemPayload {
  final int product;
  final int quantity;
  final double price;

  OrderItemPayload({required this.product, required this.quantity, required this.price});

  Map<String, dynamic> toJson() => {
    'product': product,
    'quantity': quantity,
    'price': price,
  };
}

class OrderPayload {
  final List<OrderItemPayload> items;

  OrderPayload({required this.items});

  Map<String, dynamic> toJson() => {
    'items': items.map((item) => item.toJson()).toList(),
  };
} 