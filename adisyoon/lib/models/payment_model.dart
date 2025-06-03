import 'package:adisyoon/models/order_item_model.dart';

class PaymentModel {
  final int id;
  final int tableId;
  final List<OrderItemModel> order;
  final double total;
  final String paymentMethod;
  final DateTime paymentTime;
  final bool isPartial;
  final double? partialAmount;
  final double? remainingAmount;

  PaymentModel({
    required this.id,
    required this.tableId,
    required this.order,
    required this.total,
    required this.paymentMethod,
    required this.paymentTime,
    this.isPartial = false,
    this.partialAmount,
    this.remainingAmount,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    List<dynamic> orderItems = json['order'] ?? [];
    List<OrderItemModel> parsedOrder = orderItems
        .map((item) => OrderItemModel.fromJson(item))
        .toList();

    return PaymentModel(
      id: json['id'],
      tableId: json['table_id'],
      order: parsedOrder,
      total: (json['total'] ?? 0.0).toDouble(),
      paymentMethod: json['payment_method'],
      paymentTime: DateTime.parse(json['payment_time']),
      isPartial: json['is_partial'] ?? false,
      partialAmount: json['partial_amount'] != null
          ? (json['partial_amount']).toDouble()
          : null,
      remainingAmount: json['remaining_amount'] != null
          ? (json['remaining_amount']).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'table_id': tableId,
      'order': order.map((item) => item.toJson()).toList(),
      'total': total,
      'payment_method': paymentMethod,
      'payment_time': paymentTime.toIso8601String(),
      'is_partial': isPartial,
      'partial_amount': partialAmount,
      'remaining_amount': remainingAmount,
    };
  }
} 