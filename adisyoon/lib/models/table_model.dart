import 'package:adisyoon/models/order_item_model.dart';

class TableModel {
  final int id;
  final String status;
  final List<OrderItemModel> order;
  final String? note;
  final double total;
  final bool? partialPayment;
  final String? lastPaymentMethod;
  final double? lastPaymentAmount;
  final DateTime? lastPaymentTime;
  final DateTime? readyTime;
  final DateTime? updatedAt;

  TableModel({
    required this.id,
    required this.status,
    required this.order,
    this.note,
    required this.total,
    this.partialPayment,
    this.lastPaymentMethod,
    this.lastPaymentAmount,
    this.lastPaymentTime,
    this.readyTime,
    this.updatedAt,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    List<dynamic> orderItems = json['order'] ?? [];
    List<OrderItemModel> parsedOrder = orderItems
        .map((item) => OrderItemModel.fromJson(item))
        .toList();

    return TableModel(
      id: json['id'],
      status: json['status'],
      order: parsedOrder,
      note: json['note'],
      total: (json['total'] ?? 0.0).toDouble(),
      partialPayment: json['partial_payment'],
      lastPaymentMethod: json['last_payment_method'],
      lastPaymentAmount: json['last_payment_amount'] != null
          ? (json['last_payment_amount']).toDouble()
          : null,
      lastPaymentTime: json['last_payment_time'] != null
          ? DateTime.parse(json['last_payment_time'])
          : null,
      readyTime: json['ready_time'] != null
          ? DateTime.parse(json['ready_time'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'order': order.map((item) => item.toJson()).toList(),
      'note': note,
      'total': total,
      'partial_payment': partialPayment,
      'last_payment_method': lastPaymentMethod,
      'last_payment_amount': lastPaymentAmount,
      'last_payment_time': lastPaymentTime?.toIso8601String(),
      'ready_time': readyTime?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  TableModel copyWith({
    int? id,
    String? status,
    List<OrderItemModel>? order,
    String? note,
    double? total,
    bool? partialPayment,
    String? lastPaymentMethod,
    double? lastPaymentAmount,
    DateTime? lastPaymentTime,
    DateTime? readyTime,
    DateTime? updatedAt,
  }) {
    return TableModel(
      id: id ?? this.id,
      status: status ?? this.status,
      order: order ?? this.order,
      note: note ?? this.note,
      total: total ?? this.total,
      partialPayment: partialPayment ?? this.partialPayment,
      lastPaymentMethod: lastPaymentMethod ?? this.lastPaymentMethod,
      lastPaymentAmount: lastPaymentAmount ?? this.lastPaymentAmount,
      lastPaymentTime: lastPaymentTime ?? this.lastPaymentTime,
      readyTime: readyTime ?? this.readyTime,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 