class ProductModel {
  final int id;
  final String image;
  final String title;
  final String brandName;
  final String category;
  final double price;
  final List<String> sizes;
  final int stockQuantity;
  final int reorderLevel;
  final String stockStatus;

  ProductModel({
    required this.id,
    required this.image,
    required this.title,
    required this.brandName,
    required this.category,
    required this.price,
    required this.sizes,
    this.stockQuantity = 0,
    this.reorderLevel = 10,
    this.stockStatus = 'in_stock',
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      image: json['image'],
      title: json['title'],
      brandName: json['brand_name'],
      category: json['category']['name'],
      price: double.parse(json['price'].toString()),
      sizes: List<String>.from(json['sizes'] ?? []),
      stockQuantity: json['stock_quantity'] ?? 0,
      reorderLevel: json['reorder_level'] ?? 10,
      stockStatus: json['stock_status'] ?? 'in_stock',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'title': title,
      'brand_name': brandName,
      'category': category,
      'price': price,
      'sizes': sizes,
      'stock_quantity': stockQuantity,
      'reorder_level': reorderLevel,
      'stock_status': stockStatus,
    };
  }
}

List<ProductModel> products = [
  ProductModel(
    id: 1,
    image: "assets/images/female_uniform.png",
    title: "Female Set Uniform",
    brandName: "USTP",
    category: "Uniforms",
    price: 950.00,
    sizes: ["S", "M", "L", "XL"],
  ),
  ProductModel(
    id: 2,
    image: "assets/images/executive_jacket.png",
    title: "Executive Jacket",
    brandName: "USTP",
    category: "Essentials",
    price: 1180.00,
    sizes: ["M", "L", "XL"],
  ),
  ProductModel(
    id: 3,
    image: "assets/images/male_uniform.png",
    title: "Male Set Uniform",
    brandName: "USTP",
    category: "Uniforms",
    price: 1000.00,
    sizes: ["S", "M", "L", "XL"],
  ),
  ProductModel(
    id: 4,
    image: "assets/images/physicaleduc_uniform.png",
    title: "Physical Education Uniform",
    brandName: "USTP",
    category: "Uniforms",
    price: 450.00,
    sizes: ["28", "30", "32", "34"],
  ),
];
  