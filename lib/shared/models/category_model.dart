import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final int productCount;
  final Color bgColor;
  final Color iconColor;
  final String? image;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.productCount,
    required this.bgColor,
    required this.iconColor,
    this.image,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

