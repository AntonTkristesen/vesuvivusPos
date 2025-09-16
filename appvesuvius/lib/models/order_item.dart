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
        id: int.tryParse(j['id']?.toString() ?? '') ?? 0,
        menuItemId: int.tryParse(j['menu_item_id']?.toString() ?? '') ?? 0,
        name: j['name'] ?? j['menu_name'] ?? '',
        quantity: int.tryParse(j['quantity']?.toString() ?? '') ?? 1,
        price: double.tryParse(j['price']?.toString() ?? '0') ?? 0,
        status: j['status'] ?? 'unknown',
        notes: j['notes'],
    );
}
