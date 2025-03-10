import 'package:flutter/material.dart';

class Category {
  String name;
  Color color;

  static List<Category> categories = [
    Category(name: 'Food', color: Colors.red),
    Category(name: 'Transport', color: Colors.blue),
    Category(name: 'Housing', color: Colors.purple),
    Category(name: 'Income', color: Colors.orange),
  ];

  Category({required this.name, required this.color});
  
  // Convert to and from JSON for storage
  Map<String, dynamic> toJson() => {
    'name': name,
    'color': color.value,
  };
  
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'],
      color: Color(json['color']),
    );
  }

  static List<Category> getInstance() {
    return categories;
  }
}