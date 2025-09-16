import 'package:flutter/foundation.dart';
import '../data/repositories/order_repository.dart';
import '../models/order.dart';

class HomeViewModel extends ChangeNotifier {
    final OrderRepository _orders;

    HomeViewModel(this._orders);

    OrderModel? currentOrder;
    bool busy = false;
    String? error;

    Future<OrderModel> openOrResumeTable(int? table) async {
        busy = true; 
        error = null; 
        notifyListeners();
        
        try {
            final existing = await _orders.getActiveOrderForTable(table);
            if (existing != null) {
                currentOrder = existing;
            } else {
                currentOrder = await _orders.openOrderForTable(table);
            }

            return currentOrder!;
        } catch (e) {
            error = e.toString();
            rethrow;
        } finally {
            busy = false; 
            notifyListeners();
        }
    }
}
