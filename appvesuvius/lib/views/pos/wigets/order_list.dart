import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/pos_view_model.dart';
import '../pos_constants.dart';
import '../../../../../models/order.dart';

class OrderList extends StatelessWidget {
    const OrderList({super.key});

    @override
    Widget build(BuildContext context) {
        final vm = context.watch<PosViewModel>();
        final order = vm.order;
        if (order == null || order.items.isEmpty) {
            return const Center(
                child: Text(PosConstants.noItemsInOrder),
            );
        }
        return _buildOrderItemsList(order);
    }

    Widget _buildOrderItemsList(OrderModel order) {
        final Map<String, Map<String, dynamic>> grouped = {};
        for (final item in order.items) {
            if (grouped.containsKey(item.name)) {
                grouped[item.name]!['quantity'] += item.quantity;
                grouped[item.name]!['totalPrice'] += item.price * item.quantity;
            } else {
                grouped[item.name] = {
                    'item': item,
                    'quantity': item.quantity,
                    'totalPrice': item.price * item.quantity,
                    'status': item.status,
                };
            }
        }

        final groupedItems = grouped.values.toList();

        return Expanded(
            child: ListView.builder(
                itemCount: groupedItems.length,
                itemBuilder: (context, index) {
                    final groupedItem = groupedItems[index];
                    final item = groupedItem['item'];
                    final quantity = groupedItem['quantity'];
                    final totalPrice = groupedItem['totalPrice'];
                    final status = groupedItem['status'];
                    return ListTile(
                        title: Text('${item.name} × $quantity'),
                        subtitle: Text('${PosConstants.statusLabel}$status'),
                        trailing: Text(
                            totalPrice.toStringAsFixed(2),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                    );
                },
            ),
        );
    }
}