import 'pos_constants.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../viewmodels/pos_view_model.dart';
import '../../viewmodels/auth_view_model.dart';
import 'wigets/order_list.dart';
import 'package:flutter/material.dart';

class OrderView extends StatelessWidget {
    const OrderView({super.key});

    @override
    Widget build(BuildContext context) {
        final vm = context.watch<PosViewModel>();
        final order = _getCurrentOrder(context, vm);

        if (order == null) {
            return const Center(child: CircularProgressIndicator());
        }

        return Column(
            children: [
                _buildOrderHeader(order),
                const Divider(height: 1),
                const OrderList(),
                const Divider(height: 1),
                _buildOrderTotal(context, vm),
            ],
        );
    }

    OrderModel? _getCurrentOrder(BuildContext context, PosViewModel vm) {
        final orderId = vm.order?.id;
        final auth = context.watch<AuthViewModel>();
        
        return auth.currentUser?.orders?.firstWhere(
            (order) => order.id == orderId,
            orElse: () => vm.order!,
        );
    }

    Widget _buildOrderHeader(OrderModel order) {
        return ListTile(
            title: const Text(
                PosConstants.currentOrderTitle,
                style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${PosConstants.statusLabel}${order.status}'),
        );
    }

    Widget _buildOrderTotal(BuildContext context, PosViewModel vm) {
        return Padding(
            padding: PosConstants.tilePadding,
            child: Row(
                children: [
                    const Spacer(),
                    Text(
                        PosConstants.totalLabel,
                        style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                        vm.total.toStringAsFixed(2),
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                ],
            ),
        );
    }
}