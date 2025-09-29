import 'package:flutter/foundation.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/order_repository.dart';
import '../models/user.dart';
import '../models/order.dart';
import '../services/realtime_service.dart';

class AuthViewModel extends ChangeNotifier {
    final AuthRepository _repo;
    final OrderRepository _orderRepo;

    AuthViewModel(this._repo, this._orderRepo);

    User? currentUser;
    bool busy = false;
    String? error;

    Future<bool> login(String email, String password) async {
        busy = true; 
        error = null; 
        notifyListeners();
        
        try {
            currentUser = await _repo.login(email, password);
            
            if (currentUser != null) {
                _initializeRealtime();
            }
            
            return true;
        } catch (e) {
            error = e.toString();
            return false;
        } finally {
            busy = false; 
            notifyListeners();
        }
    }

    Future<bool> register(String name, String email, String password) async {
        busy = true; 
        error = null; 
        notifyListeners();
        
        try {
            currentUser = await _repo.register(name, email, password);
            
            if (currentUser != null) {
                _initializeRealtime();
            }
            
            return true;
        } catch (e) {
            error = e.toString();
            return false;
        } finally {
            busy = false; 
            notifyListeners();
        }
    }

    Future<void> logout() async {
        await _repo.logout();
        currentUser = null;
        notifyListeners();
    }

    Future<void> loadCurrentUser() async {
        try {
            currentUser = await _repo.getCurrentUser();

            if (currentUser != null) {
                await _repo.initializeRealtimeIfAuthenticated();
                _initializeRealtime();
            }
            
            notifyListeners();
        } catch (e) {
            if (kDebugMode) {
                print('Error loading current user: $e');
            }
            currentUser = null;
            notifyListeners();
        }
    }

    void _initializeRealtime() {
        if (currentUser != null) {
            RealtimeService().subscribeToUserOrders(currentUser!.id, (orders) {
                if (kDebugMode) {
                    print('AuthViewModel: Received ${orders.length} orders via realtime');
                }
                updateAllOrders(orders);
            });
        }
    }

    void initializeRealtimeForCurrentUser() {
        _initializeRealtime();
    }

    bool hasOrder(int orderId) {
        return currentUser?.orders?.any((order) => order.id == orderId) ?? false;
    }

    void addOrder(OrderModel order) {
        if (currentUser == null) return;
        
        if (currentUser!.orders == null) {
            currentUser!.orders = [];
        }
        
        if (!hasOrder(order.id)) {
            currentUser!.orders!.add(order);
            notifyListeners();
        }
    }

    void updateOrder(OrderModel updatedOrder) {
        if (currentUser?.orders == null) return;
        
        final index = currentUser!.orders!.indexWhere((o) => o.id == updatedOrder.id);
        if (index != -1) {
            currentUser!.orders![index] = updatedOrder;
            notifyListeners();
        } else {
            addOrder(updatedOrder);
        }
    }

    void updateAllOrders(List<OrderModel> orders) {
        if (currentUser == null) return;
        for (final o in orders) {
            updateOrder(o);
        }
    }

    void removeOrder(int orderId) {
        currentUser?.orders?.removeWhere((o) => o.id == orderId);
        if (currentUser?.orders != null) {
            _orderRepo.removeOrder(orderId);
            notifyListeners();
        }
    }

    Future<void> markOrderAsServed(int orderId) async {
        try {
            await _orderRepo.setOrderStatus(orderId, 'served');
        } catch (e) {
            if (kDebugMode) {
                print('Error marking order as served: $e');
            }
        }
    }

    int? get userId => currentUser?.id;

    bool get isAuthenticated => currentUser != null;
}