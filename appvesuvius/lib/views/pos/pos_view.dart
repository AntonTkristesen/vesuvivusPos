import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../models/menu_item.dart';
import '../../viewmodels/pos_view_model.dart';
import '../../viewmodels/auth_view_model.dart';

class _Constants {
    static const double wideScreenBreakpoint = 600.0;
    static const double cardBorderRadius = 12.0;
    static const double minButtonHeight = 48.0;
    static const EdgeInsets defaultPadding = EdgeInsets.all(8.0);
    static const EdgeInsets tilePadding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);

    static const String searchHint = 'Søg efter mad eller drikke...';
    static const String orderPaidMessage = 'Ordreren er betalt';
    static const String payButtonLabel = 'Betal';
    static const String menuTabLabel = 'Menu';
    static const String orderTabLabel = 'Ordre';
    static const String currentOrderTitle = 'Nuværende ordre';
    static const String totalLabel = 'Total: ';
    static const String statusLabel = 'Status: ';
}

class PosView extends StatelessWidget {
    static const route = '/pos';
    
    const PosView({super.key});

    @override
    Widget build(BuildContext context) {
        final OrderModel routeOrder = _getRouteOrder(context);
        final bool isWideScreen = _isWideScreen(context);

        return Scaffold(
            appBar: _buildAppBar(routeOrder),
            body: isWideScreen ? _buildWideLayout() : const _MobileView(),
        );
    }

    OrderModel _getRouteOrder(BuildContext context) {
        return (ModalRoute.of(context)?.settings.arguments) as OrderModel? ??
            context.watch<PosViewModel>().order!;
    }

    bool _isWideScreen(BuildContext context) {
        return MediaQuery.of(context).size.width > _Constants.wideScreenBreakpoint;
    }

    AppBar _buildAppBar(OrderModel order) {
        return AppBar(
            title: Text('Bord ${order.tableNumber} • Ordre #${order.id}'),
            actions: const [
            ],
        );
    }

    Widget _buildWideLayout() {
        return const Row(
            children: [
                Expanded(flex: 3, child: _MenuList()),
                VerticalDivider(width: 1),
                Expanded(flex: 2, child: _OrderPanel()),
            ],
        );
    }
}

class _MobileView extends StatefulWidget {
    const _MobileView();

    @override
    State<_MobileView> createState() => _MobileViewState();
}

class _MobileViewState extends State<_MobileView> {
    int _selectedIndex = 0;

    @override
    Widget build(BuildContext context) {
        final vm = context.watch<PosViewModel>();

        return Column(
            children: [
                Expanded(child: _buildContent()),
                if (_shouldShowPayButton(vm)) _buildPayButton(context, vm),
                _buildNavigationBar(),
            ],
        );
    }

    Widget _buildContent() {
        return IndexedStack(
            index: _selectedIndex,
            children: const [
                _MenuList(),
                _OrderPanel(),
            ],
        );
    }

    bool _shouldShowPayButton(PosViewModel vm) {
        return vm.order?.status != 'paid';
    }

    Widget _buildPayButton(BuildContext context, PosViewModel vm) {
        return Padding(
            padding: _Constants.tilePadding,
            child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(_Constants.minButtonHeight),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_Constants.cardBorderRadius),
                    ),
                ),
                onPressed: () => _handlePayment(context, vm),
                icon: const Icon(Icons.check_circle),
                label: const Text(
                    _Constants.payButtonLabel,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
            ),
        );
    }

    Future<void> _handlePayment(BuildContext context, PosViewModel vm) async {
        await vm.markPaid();
        if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(_Constants.orderPaidMessage)),
            );
        }
    }

    Widget _buildNavigationBar() {
        return NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            destinations: const [
                NavigationDestination(
                    icon: Icon(Icons.restaurant_menu),
                    label: _Constants.menuTabLabel,
                ),
                NavigationDestination(
                    icon: Icon(Icons.receipt_long),
                    label: _Constants.orderTabLabel,
                ),
            ],
        );
    }
}

class _MenuList extends StatefulWidget {
    const _MenuList();

    @override
    State<_MenuList> createState() => _MenuListState();
}

class _MenuListState extends State<_MenuList> {
    String _searchQuery = '';

    @override
    Widget build(BuildContext context) {
        final vm = context.watch<PosViewModel>();
        
        if (vm.loadingMenu) {
            return const Center(child: CircularProgressIndicator());
        }

        final categories = _organizeItemsByCategory(vm.items);
        final categoryNames = categories.keys.toList()..sort();

        return DefaultTabController(
            length: categoryNames.isEmpty ? 1 : categoryNames.length,
            child: Column(
                children: [
                    _buildSearchField(),
                    _buildTabBar(categoryNames),
                    const Divider(height: 1),
                    _buildTabBarView(categoryNames, categories, vm.items),
                ],
            ),
        );
    }

    Map<String, List<MenuItemModel>> _organizeItemsByCategory(List<MenuItemModel> items) {
        final Map<String, List<MenuItemModel>> groups = {};
        for (final item in items) {
            if (item.isAvailable) {
                groups.putIfAbsent(item.category, () => []).add(item);
            }
        }
        return groups;
    }

    Widget _buildSearchField() {
        return Padding(
            padding: _Constants.defaultPadding,
            child: TextField(
                decoration: InputDecoration(
                    hintText: _Constants.searchHint,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(_Constants.cardBorderRadius),
                    ),
                    contentPadding: _Constants.tilePadding,
                ),
                onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
        );
    }

    Widget _buildTabBar(List<String> categoryNames) {
        return Material(
            color: Colors.transparent,
            child: TabBar(
                isScrollable: true,
                tabs: (categoryNames.isEmpty ? ['All'] : categoryNames)
                    .map((category) => Tab(text: _mapCategoryName(category)))
                    .toList(),
            ),
        );
    }

    Widget _buildTabBarView(
        List<String> categoryNames,
        Map<String, List<MenuItemModel>> categories,
        List<MenuItemModel> allItems,
    ) {
        return Expanded(
            child: TabBarView(
                children: (categoryNames.isEmpty ? ['All'] : categoryNames).map((category) {
                    final items = category == 'All'
                        ? allItems.where((item) => item.isAvailable).toList()
                        : categories[category]!;
                    
                    final filteredItems = _filterItems(items);
                    
                    return ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, index) => _MenuTile(item: filteredItems[index]),
                    );
                }).toList(),
            ),
        );
    }

    List<MenuItemModel> _filterItems(List<MenuItemModel> items) {
        if (_searchQuery.isEmpty) return items;
        
        return items.where((item) {
            return item.name.toLowerCase().contains(_searchQuery) ||
                item.category.toLowerCase().contains(_searchQuery);
        }).toList();
    }
}

class _MenuTile extends StatelessWidget {
    final MenuItemModel item;
    
    const _MenuTile({required this.item});

    @override
    Widget build(BuildContext context) {
        final vm = context.watch<PosViewModel>();
        final isOrderPaid = vm.order?.status == 'paid';

        return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_Constants.cardBorderRadius),
            ),
            child: ListTile(
                contentPadding: _Constants.tilePadding,
                title: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('${_mapCategoryName(item.category)} • ${item.price.toStringAsFixed(2)}'),
                trailing: IconButton.filled(
                    onPressed: isOrderPaid ? null : () => _addItemToOrder(context, vm),
                    icon: const Icon(Icons.add),
                ),
            ),
        );
    }

    Future<void> _addItemToOrder(BuildContext context, PosViewModel vm) async {
        await vm.add(item);
        if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item.name} tilføjet')),
            );
        }
    }
}

class _OrderPanel extends StatelessWidget {
    const _OrderPanel();

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
                _buildOrderItemsList(order),
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
                _Constants.currentOrderTitle,
                style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${_Constants.statusLabel}${order.status}'),
        );
    }

    Widget _buildOrderItemsList(OrderModel order) {
        return Expanded(
            child: ListView.builder(
                itemCount: order.items.length,
                itemBuilder: (context, index) {
                    final item = order.items[index];
                    return ListTile(
                        title: Text('${item.name} × ${item.quantity}'),
                        subtitle: Text('${_Constants.statusLabel}${item.status}'),
                        trailing: Text(
                            (item.price * item.quantity).toStringAsFixed(2),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                    );
                },
            ),
        );
    }

    Widget _buildOrderTotal(BuildContext context, PosViewModel vm) {
        return Padding(
            padding: _Constants.tilePadding,
            child: Row(
                children: [
                    const Spacer(),
                    Text(
                        _Constants.totalLabel,
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

String _mapCategoryName(String category) {
    switch (category.toLowerCase()) {
        case 'drink':
            return 'Drikke';
        case 'food':
            return 'Mad';
        default:
            return category;
    }
}