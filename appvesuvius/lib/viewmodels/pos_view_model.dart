import 'package:flutter/foundation.dart';
import '../data/repositories/menu_repository.dart';
import '../data/repositories/order_repository.dart';
import '../models/menu_item.dart';
import '../models/order.dart';
import '../viewmodels/auth_view_model.dart';

class PosViewModel extends ChangeNotifier {
    final MenuRepository _menu;
    final OrderRepository _orders;
    final AuthViewModel authViewModel;

    PosViewModel(this._menu, this._orders, this.authViewModel);

    List<MenuItemModel> items = [];
    OrderModel? order;
    bool loadingMenu = false;
    String? error;

    Future<void> init(OrderModel order) async {
        this.order = order;
        authViewModel.updateOrder(order);
        await loadMenu();
    }

    Future<void> loadMenu() async {
        loadingMenu = true;
        error = null;
        notifyListeners();
        try {
            items = await _menu.fetchMenu();
        } catch (e) {
            error = e.toString();
        } finally {
            loadingMenu = false;
            notifyListeners();
        }
    }

    Future<void> add(MenuItemModel item) async {
        if (order == null) return;
        try {
            await _orders.addItem(orderId: order!.id, menuItemId: item.id);
        } catch (e) {
            error = e.toString();
            notifyListeners();
        }
    }

    double get total =>
        authViewModel.currentUser?.orders?.firstWhere((o) => o.id == order?.id).items.fold(0.0, (sum, it) => sum! + (it.price * it.quantity)) ?? 0.0;

    Future<void> markPaid() async {
        if (order == null) return;
        await _orders.setOrderStatus(order!.id, 'paid');
        authViewModel.updateOrder(order!);
    }

    Map<String, List<MenuItemModel>> organizeItemsByCategory(List<MenuItemModel> items) {
        final Map<String, List<MenuItemModel>> groups = {};
        for (final item in items) {
            if (item.isAvailable) {
                groups.putIfAbsent(item.category, () => []).add(item);
            }
        }
        return groups;
    }

    String mapCategoryName(String category) {
        switch (category.toLowerCase()) {
            case 'drink':
                return 'Drikke';
            case 'food':
                return 'Mad';
            default:
                return category;
        }
    }
}
