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
        final isWide = MediaQuery.of(context).size.width > 600;

        return Scaffold(
            appBar: AppBar(
                title: Text('Bord ${routeOrder.tableNumber} • Ordre #${routeOrder.id}'),
                actions: [
                  
                ],
            ),
            body: isWide
                ? Row(
                    children: [
                        Expanded(flex: 3, child: _MenuList()),
                        const VerticalDivider(width: 1),
                        Expanded(flex: 2, child: _OrderPanel()),
                    ],
                )
                : const _MobileView(),
        );
    }
}

class _MobileView extends StatefulWidget {
    const _MobileView();

    @override
    State<_MobileView> createState() => _MobileViewState();
}

class _MobileViewState extends State<_MobileView> {
    int _index = 0;

    @override
    Widget build(BuildContext context) {
        final vm = context.watch<PosViewModel>();

        return Column(
            children: [
                Expanded(
                    child: IndexedStack(
                        index: _index,
                        children: [
                            _MenuList(),
                            const _OrderPanel(),
                        ],
                    ),
                ),
                if (vm.order?.status != 'paid')
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                ),
                            ),
                            onPressed: () async {
                                await context.read<PosViewModel>().markPaid();
                                if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Ordreren er betalt')),
                                    );
                                }
                            },
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Betal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                    ),
                NavigationBar(
                    selectedIndex: _index,
                    onDestinationSelected: (i) => setState(() => _index = i),
                    destinations: const [
                        NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'Menu'),
                        NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Order'),
                    ],
                ),
            ],
        );
    }
}

class _MenuList extends StatefulWidget {
    @override
    State<_MenuList> createState() => _MenuListState();
}

class _MenuListState extends State<_MenuList> {
    String _query = '';

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
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: TextField(
                            decoration: InputDecoration(
                                hintText: 'Search food or drinks...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onChanged: (val) => setState(() => _query = val.toLowerCase()),
                        ),
                    ),
                    Material(
                        color: Colors.transparent,
                        child: TabBar(
                          isScrollable: true,
                          tabs: (cats.isEmpty ? ['All'] : cats)
                            .map((c) => Tab(text: categoryMap(c)))
                            .toList(),
                        ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                        child: TabBarView(
                            children: (cats.isEmpty ? ['All'] : cats).map((c) {
                                final items = c == 'All'
                                    ? vm.items.where((e) => e.isAvailable).toList()
                                    : groups[c]!;
                                final filtered = items
                                    .where((e) => e.name.toLowerCase().contains(_query) || e.category.toLowerCase().contains(_query))
                                    .toList();
                                return ListView.separated(
                                    padding: const EdgeInsets.all(12),
                                    itemCount: filtered.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                                    itemBuilder: (_, i) => _MenuTile(item: filtered[i]),
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
        final isDisabled = vm.order?.status == 'paid';

        return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: isDisabled
                    ? null
                    : () async {
                        await context.read<PosViewModel>().add(item);
                        if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${item.name} tilføjet')),
                            );
                        }
                    },
                child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${categoryMap(item.category)} • ${item.price.toStringAsFixed(2)}'),
                    enabled: !isDisabled,
                ),
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

        if (order == null) {
            return const Center(child: CircularProgressIndicator());
        }

        return Column(
            children: [
                ListTile(
                    title: const Text('Nuværende ordre', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                trailing: Text(
                                    (it.price * it.quantity).toStringAsFixed(2),
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
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
                            Text(
                                vm.total.toStringAsFixed(2),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                        ],
                    ),
                ),
            ],
        );
    }
}

String categoryMap(String category) {
    switch (category.toLowerCase()) {
        case 'drink': return 'Drikke';
        case 'food': return 'Mad';
        default: return category;
    }
}
