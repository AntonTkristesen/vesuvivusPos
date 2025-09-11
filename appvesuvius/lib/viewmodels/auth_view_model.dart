import 'package:flutter/foundation.dart';
import '../data/repositories/auth_repository.dart';
import '../models/user.dart';
import '../models/order.dart';

class AuthViewModel extends ChangeNotifier {
    final AuthRepository _repo;

    AuthViewModel(this._repo);

    User? currentUser;
    bool busy = false;
    String? error;

    Future<bool> login(String email, String password) async {
        busy = true; error = null; notifyListeners();
        try {
            currentUser = await _repo.login(email, password);
            return true;
        } catch (e) {
            error = e.toString();
            return false;
        } finally {
            busy = false; notifyListeners();
        }
    }

    Future<bool> register(String name, String email, String password) async {
        busy = true; error = null; notifyListeners();
        try {
            currentUser = await _repo.register(name, email, password);
            return true;
        } catch (e) {
            error = e.toString();
            return false;
        } finally {
            busy = false; notifyListeners();
        }
    }

    Future<void> logout() async {
        await _repo.logout();
        currentUser = null;
        notifyListeners();
    }

    Future<void> loadCurrentUser() async {
        currentUser = await _repo.getCurrentUser();
        notifyListeners();
    }

    void addOrder(OrderModel order) {
        currentUser?.orders ??= [];
        if (!hasOrder(order.id)) {
            currentUser?.orders!.add(order);
            notifyListeners();
        }
    }

    void updateOrder(OrderModel order) {
        final idx = currentUser?.orders?.indexWhere((o) => o.id == order.id) ?? -1;
        if (idx != -1) {
            currentUser?.orders?[idx] = order;
            notifyListeners();
        } else {
            addOrder(order);
        }
    }

    void removeOrder(int orderId) {
        if (currentUser == null) return;
        final orders = currentUser!.orders ?? [];
        orders.removeWhere((o) => o.id == orderId);
        currentUser!.orders = orders;
        notifyListeners();
    }

    bool hasOrder(int id) {
        return currentUser?.orders?.any((o) => o.id == id) ?? false;
    }
}
