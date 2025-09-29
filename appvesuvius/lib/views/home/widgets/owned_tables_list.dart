import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/auth_view_model.dart';
import 'order_tile.dart';

class OwnedTablesList extends StatelessWidget {
    const OwnedTablesList({super.key});

    @override
    Widget build(BuildContext context) {
        final authViewModel = context.watch<AuthViewModel>();
        final orders = authViewModel.currentUser?.orders ?? [];

        if (orders.isEmpty) {
            return const Expanded(
                child: Center(
                    child: Text(
                        'Ingen aktive ordrer',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                ),
            );
        }

        return Expanded(
            child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) => OrderTile(order: orders[index]),
            ),
        );
    }
}
