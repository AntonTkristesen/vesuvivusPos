import 'package:flutter/foundation.dart';
import '../data/repositories/order_repository.dart';
import '../models/order.dart';
import '../services/realtime_service.dart';

class HomeViewModel extends ChangeNotifier {
    final OrderRepository _orders;
    final RealtimeService _realtime = RealtimeService();

    HomeViewModel(this._orders);

    OrderModel? currentOrder;
    bool busy = false;
    String? error;
    List<OrderModel> liveOrders = [];

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

    void setCurrentOrder(OrderModel order) {
        currentOrder = order;
        notifyListeners();
    }

    void clearCurrentOrder() {
        currentOrder = null;
        notifyListeners();
    }

    void subscribeToOrders(int userId) {
        _realtime.subscribeToUserOrders(userId, (orders) {
            liveOrders = orders;
            notifyListeners();
        });
    }

    void unsubscribeFromOrders(int userId) {
        _realtime.unsubscribeFromUserOrders(userId);
    }
}
