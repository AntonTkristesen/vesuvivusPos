import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../data/repositories/order_repository.dart';
import '../models/order.dart';
import 'auth_view_model.dart';
import 'pos_view_model.dart';
import '../views/pos/pos_view.dart';

class HomeViewModel extends ChangeNotifier {
    final OrderRepository _orders;

    HomeViewModel(this._orders);

    OrderModel? currentOrder;
    bool busy = false;
    String? error;

    // --- Core logic ---
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

    // --- UI logic moved here ---
    Future<void> logout(BuildContext context, AuthViewModel authViewModel) async {
        await authViewModel.logout();
        if (context.mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
        }
    }

    Future<void> navigateToReceipts(BuildContext context) async {
        if (context.mounted) {
            Navigator.of(context).pushReplacementNamed('/receipts');
        }
    }

    Future<void> handleOpenTable(
        BuildContext context,
        int? tableNumber,
        AuthViewModel authViewModel,
        PosViewModel posViewModel,
    ) async {
        try {
            final order = await openOrResumeTable(tableNumber);
            if (!context.mounted) return;

            if (!authViewModel.hasOrder(order.id)) {
                authViewModel.addOrder(order);
            }

            await posViewModel.init(order);
            await Navigator.of(context).pushNamed(PosView.route, arguments: order);
        } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$e')),
            );
        }
    }

    Future<void> handleOrderTap(BuildContext context, dynamic order, PosViewModel posViewModel) async {
        try {
            final reopenedOrder = await openOrResumeTable(order.tableNumber);
            if (!context.mounted) return;

            await posViewModel.init(reopenedOrder);
            await Navigator.of(context).pushNamed(PosView.route, arguments: reopenedOrder);
        } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Fejl: $e')),
            );
        }
    }

    Future<void> deleteOrder(BuildContext context, dynamic order, AuthViewModel authViewModel) async {
        try {
            authViewModel.removeOrder(order.id);
        } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Fejl: $e')),
            );
        }
    }

    Future<void> markOrderAsServed(BuildContext context, dynamic order, AuthViewModel authViewModel) async {
        try {
            await authViewModel.markOrderAsServed(order.id);
        } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Fejl: $e')),
            );
        }
    }
}
