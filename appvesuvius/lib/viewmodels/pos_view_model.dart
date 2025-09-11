import 'package:flutter/foundation.dart';
import '../data/repositories/menu_repository.dart';
import '../data/repositories/order_repository.dart';
import '../models/menu_item.dart';
import '../models/order.dart';

class PosViewModel extends ChangeNotifier {
    final MenuRepository _menu;
    final OrderRepository _orders;

    PosViewModel(this._menu, this._orders);

    List<MenuItemModel> items = [];
    OrderModel? order;
    bool loadingMenu = false;
    bool loadingOrder = false;
    String? error;

    Future<void> init(OrderModel order) async {
        this.order = order;
        await Future.wait([loadMenu(), refreshOrder()]);
    }

    Future<void> loadMenu() async {
        loadingMenu = true; error = null; notifyListeners();
        try {
            items = await _menu.fetchMenu();
        } catch (e) {
            error = e.toString();
        } finally {
            loadingMenu = false; notifyListeners();
        }
    }

    Future<void> refreshOrder() async {
        if (order == null) return;
            loadingOrder = true; notifyListeners();
        try {
            this.order = await _orders.getOrder(order!.id);
        } finally {
            loadingOrder = false; notifyListeners();
        }
    }

    Future<void> add(MenuItemModel item) async {
        if (order == null) return;
        try {
            await _orders.addItem(orderId: order!.id, menuItemId: item.id);
            await refreshOrder();
        } catch (e) {
            error = e.toString();
            notifyListeners();
        }
    }

    double get total => order?.items.fold(0.0, (sum, it) => sum! + (it.price * it.quantity)) ?? 0.0;

    Future<void> markPaid() async {
        if (order == null) return;
        await _orders.setOrderStatus(order!.id, 'paid');
        await refreshOrder();
    }
}
