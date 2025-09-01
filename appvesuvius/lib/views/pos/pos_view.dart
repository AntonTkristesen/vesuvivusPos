import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../models/menu_item.dart';
import '../../viewmodels/pos_view_model.dart';

class PosView extends StatelessWidget {
  static const route = '/pos';
  const PosView({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderModel routeOrder = (ModalRoute.of(context)?.settings.arguments) as OrderModel? ??
        context.watch<PosViewModel>().order!;

    final vm = context.watch<PosViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Table ${routeOrder.tableNumber} • Order #${routeOrder.id}'),
        actions: [
          TextButton.icon(
            onPressed: (vm.order?.status == 'paid')
                ? null
                : () async {
                    await context.read<PosViewModel>().markPaid();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order marked as paid')));
                    }
                  },
            icon: const Icon(Icons.check_circle, size: 18),
            label: const Text('Pay', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          IconButton(
            onPressed: () => context.read<PosViewModel>().refreshOrder(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          )
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: _MenuList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 2,
            child: _OrderPanel(),
          ),
        ],
      ),
    );
  }
}

class _MenuList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PosViewModel>();
    if (vm.loadingMenu) {
      return const Center(child: CircularProgressIndicator());
    }
    final groups = <String, List<MenuItemModel>>{};
    for (var m in vm.items) {
      if (!m.isAvailable) continue;
      groups.putIfAbsent(m.category, () => []).add(m);
    }
    final cats = groups.keys.toList()..sort();
    return DefaultTabController(
      length: cats.isEmpty ? 1 : cats.length,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: TabBar(
              isScrollable: true,
              tabs: (cats.isEmpty ? ['All'] : cats).map((c) => Tab(text: c)).toList(),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: TabBarView(
              children: (cats.isEmpty ? ['All'] : cats).map((c) {
                final items = c == 'All'
                    ? vm.items.where((e) => e.isAvailable).toList()
                    : groups[c]!;
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _MenuTile(item: items[i]),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final MenuItemModel item;
  const _MenuTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PosViewModel>();
    return ListTile(
      title: Text(item.name),
      subtitle: Text('${item.category} • ${item.price.toStringAsFixed(2)}'),
      trailing: FilledButton.icon(
        onPressed: vm.order?.status == 'paid' ? null : () async {
          await context.read<PosViewModel>().add(item);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.name} added')));
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}

class _OrderPanel extends StatelessWidget {
  const _OrderPanel();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PosViewModel>();
    final order = vm.order;

    if (vm.loadingOrder || order == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        ListTile(
          title: const Text('Current order'),
          subtitle: Text('Status: ${order.status}'),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: order.items.length,
            itemBuilder: (_, i) {
              final it = order.items[i];
              return ListTile(
                title: Text('${it.name} × ${it.quantity}'),
                subtitle: Text('Status: ${it.status}'),
                trailing: Text((it.price * it.quantity).toStringAsFixed(2)),
              );
            },
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Spacer(),
              Text('Total: ', style: Theme.of(context).textTheme.titleMedium),
              Text(vm.total.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        )
      ],
    );
  }
}
