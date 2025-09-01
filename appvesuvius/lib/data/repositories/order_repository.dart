import '../api/api_client.dart';
import '../../models/order.dart';
import '../../models/order_item.dart';

class OrderRepository {
  final ApiClient _api;
  OrderRepository(this._api);

  Future<OrderModel> openOrderForTable(int tableNumber) async {
    final data = await _api.post('open_order.php', {'table_number': tableNumber});
    return OrderModel.fromJson(data['order']);
  }

  Future<OrderModel?> getActiveOrderForTable(int tableNumber) async {
    final data = await _api.get('order_by_table.php', query: {'table_number': '$tableNumber'});
    if (data['order'] == null) return null;
    return OrderModel.fromJson(data['order']);
  }

  Future<OrderModel> getOrder(int orderId) async {
    final data = await _api.get('order.php', query: {'id': '$orderId'});
    return OrderModel.fromJson(data['order']);
  }

  Future<OrderItemModel> addItem({
    required int orderId,
    required int menuItemId,
    int quantity = 1,
    String? notes,
  }) async {
    final data = await _api.post('add_item.php', {
      'order_id': orderId,
      'menu_item_id': menuItemId,
      'quantity': quantity,
      'notes': notes
    });
    return OrderItemModel.fromJson(data['item']);
  }

  Future<void> setOrderStatus(int orderId, String status) async {
    await _api.post('set_order_status.php', {'order_id': orderId, 'status': status});
  }
}
