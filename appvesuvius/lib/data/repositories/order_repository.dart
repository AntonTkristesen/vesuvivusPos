import 'package:vesuvivus_pos/viewmodels/auth_view_model.dart';

import '../api/api_client.dart';
import '../../models/order.dart';
import '../../models/order_item.dart';

class OrderRepository {
  final ApiClient _api;
  OrderRepository(this._api);
  AuthViewModel? _auth;
  Future<OrderModel> openOrderForTable(int? tableNumber) async {
    final data = await _api.post('orders/open', {'table_number': tableNumber, 'server_id': _auth?.currentUser?.id});
    return OrderModel.fromJson(data['order']);
  }


  Future<OrderModel?> getActiveOrderForTable(int? tableNumber) async {
    final data = await _api.get('orders/by-table', query: {'table_number': '$tableNumber'});
    if (data['order'] == null) return null;
    return OrderModel.fromJson(data['order']);
  }

  Future<OrderModel> getOrder(int? orderId) async {
    final data = await _api.get('orders/$orderId');
    return OrderModel.fromJson(data['order']);
  }


  Future<OrderItemModel> addItem({required int orderId, required int menuItemId, int quantity = 1, String? notes}) async {
  final data = await _api.post('orders/items', {
    'order_id': orderId,
    'menu_item_id': menuItemId,
    'quantity': quantity,
    'notes': notes
  });
  return OrderItemModel.fromJson(data['item']);
}

Future<void> setOrderStatus(int orderId, String status) async {
  await _api.post('orders/status', {'order_id': orderId, 'status': status});
}
}
