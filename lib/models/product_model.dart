class ProductModel {
  final int id;
  final String image, brandName, title, category;
  final double price;
  final List<String>? sizes; // Added sizes property

  ProductModel({
    required this.id,
    required this.image,
    required this.brandName,
    required this.title,
    required this.category,
    required this.price,
    this.sizes,
  });
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
  