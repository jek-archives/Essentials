import 'package:flutter/material.dart';

class CategoryModel {
  final String name;
  final IconData icon;

  CategoryModel({
    required this.name,
    required this.icon,
  });
}

final List<CategoryModel> appCategories = [
  CategoryModel(name: 'All', icon: Icons.apps),
  CategoryModel(name: 'Souvenirs', icon: Icons.card_giftcard),
  CategoryModel(name: 'Uniforms', icon: Icons.checkroom),
  CategoryModel(name: 'Essentials', icon: Icons.book),
];
