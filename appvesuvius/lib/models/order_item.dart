class OrderItemModel {
  final int id;
  final int menuItemId;
  final String name;
  final int quantity;
  final double price;
  final String status;
  final String? notes;

  OrderItemModel({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.status,
    this.notes,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> j) => OrderItemModel(
        id: int.parse(j['id'].toString()),
        menuItemId: int.parse(j['menu_item_id'].toString()),
        name: j['name'] ?? j['menu_name'] ?? '',
        quantity: int.parse(j['quantity'].toString()),
        price: double.tryParse(j['price']?.toString() ?? '0') ?? 0,
        status: j['status'],
        notes: j['notes'],
      );
}
