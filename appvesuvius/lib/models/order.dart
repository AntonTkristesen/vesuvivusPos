import 'order_item.dart';

class OrderModel {
    final int id;
    final int tableNumber;
    final String status;
    final double total;
    final List<OrderItemModel> items;

    OrderModel({
        required this.id,
        required this.tableNumber,
        required this.status,
        required this.total,
        required this.items,
    });

    factory OrderModel.fromJson(Map<String, dynamic> j) => OrderModel(
        id: int.tryParse(j['id']?.toString() ?? '') ?? 0,
        tableNumber: int.tryParse(j['table_number']?.toString() ?? '') ?? 0,
        status: j['status'] ?? 'unknown',
        total: double.tryParse(j['total']?.toString() ?? '0') ?? 0,
        items: (j['items'] as List? ?? [])
            .map((x) => OrderItemModel.fromJson(x as Map<String, dynamic>))
            .toList(),
    );
}
