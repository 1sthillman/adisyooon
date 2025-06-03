class OrderItemModel {
  final int id;
  final String name;
  final double price;
  final int quantity;

  OrderItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'],
      name: json['name'],
      price: (json['price'] ?? 0.0).toDouble(),
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  OrderItemModel copyWith({
    int? id,
    String? name,
    double? price,
    int? quantity,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
} 