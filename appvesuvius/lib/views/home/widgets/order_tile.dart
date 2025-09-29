import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/home_view_model.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../../../viewmodels/pos_view_model.dart';
import '../home_constants.dart';

class OrderTile extends StatelessWidget {
    final dynamic order;

    const OrderTile({super.key, required this.order});

    @override
    Widget build(BuildContext context) {
        if (order.status == 'paid') {
            return const SizedBox.shrink();
        }
    
        return ListTile(
            title: Text('${HomeConstants.tableLabel}${order.tableNumber}'),
            subtitle: Text(
                '${HomeConstants.orderIdLabel}${order.id}'
                '${HomeConstants.statusLabel}${order.status}',
            ),
            onTap: () => context.read<HomeViewModel>().handleOrderTap(
                context,
                order,
                context.read<PosViewModel>(),
            ),
            trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                    _buildStatusIcon(),
                    IconButton(
                        icon: const Icon(Icons.done),
                        onPressed: () => context.read<HomeViewModel>().markOrderAsServed(
                            context,
                            order,
                            context.read<AuthViewModel>(),
                        ),
                        tooltip: 'Markér som serveret',
                    ),
                    IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => context.read<HomeViewModel>().deleteOrder(
                            context,
                            order,
                            context.read<AuthViewModel>(),
                        ),
                        tooltip: 'Slet ordre',
                    ),
                ],
            ),
        );
    }

    Widget _buildStatusIcon() {
        IconData iconData;
        Color iconColor;

        switch (order.status.toString().toLowerCase()) {
            case 'paid':
                iconData = Icons.check_circle;
                iconColor = Colors.green;
                break;
            case 'pending':
                iconData = Icons.pending;
                iconColor = Colors.orange;
                break;
            default:
                iconData = Icons.restaurant;
                iconColor = Colors.blue;
                break;
        }

        return Icon(iconData, color: iconColor);
    }
}
