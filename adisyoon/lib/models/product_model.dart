class ProductModel {
  final int id;
  final String name;
  final double price;
  final String category;
  final String? image;
  final bool active;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.image,
    this.active = true,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      price: (json['price'] ?? 0.0).toDouble(),
      category: json['category'],
      image: json['image'],
      active: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'image': image,
      'active': active,
    };
  }

  ProductModel copyWith({
    int? id,
    String? name,
    double? price,
    String? category,
    String? image,
    bool? active,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      image: image ?? this.image,
      active: active ?? this.active,
    );
  }
} 