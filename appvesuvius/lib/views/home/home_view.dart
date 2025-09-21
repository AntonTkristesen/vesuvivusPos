import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/home_view_model.dart';
import '../../viewmodels/pos_view_model.dart';
import '../pos/pos_view.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../services/realtime_service.dart';

class _Constants {
    static const double defaultPadding = 16.0;
    static const double spacingSmall = 8.0;
    static const double spacingMedium = 12.0;
    static const double spacingLarge = 24.0;
    static const EdgeInsets cardPadding = EdgeInsets.all(16.0);

    static const String appTitle = 'Vesuvivus — Bord';
    static const String logoutTooltip = 'Log ud';
    static const String tableNumberLabel = 'Bordnummer';
    static const String openContinueLabel = 'Åbn / Fortsæt';
    static const String invalidTableMessage = 'Indtast et gyldigt bordnummer';
    static const String helpText = 'Indtast et bordnummer and press "Åbn / Fortsæt". På næste skærm kan du tilføje menupunkter og markere ordren som betalt.';
    static const String orderIdLabel = 'Ordre ID: ';
    static const String statusLabel = ' - Status: ';
    static const String tableLabel = 'Bord ';
    static const String errorOpeningOrder = 'Fejl: ';
}

class HomeView extends StatefulWidget {
    const HomeView({super.key});

    @override
    State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
    final _tableController = TextEditingController();

    @override
    void initState() {
        super.initState();
        _initializeRealtimeConnection();
    }

    @override
    void dispose() {
        _tableController.dispose();
        RealtimeService().disconnect();
        super.dispose();
    }

    void _initializeRealtimeConnection() {
        final auth = context.read<AuthViewModel>();
        if (auth.isAuthenticated) {
            auth.initializeRealtimeForCurrentUser();
        }
    }

    @override
    Widget build(BuildContext context) {
        final homeViewModel = context.watch<HomeViewModel>();
        final authViewModel = context.watch<AuthViewModel>();

        return Scaffold(
            appBar: _buildAppBar(authViewModel),
            body: _buildBody(homeViewModel, authViewModel),
        );
    }

    AppBar _buildAppBar(AuthViewModel authViewModel) {
        return AppBar(
            title: const Text(_Constants.appTitle),
            actions: [
                IconButton(
                    onPressed: () => _handleLogout(authViewModel),
                    icon: const Icon(Icons.logout),
                    tooltip: _Constants.logoutTooltip,
                ),
                 IconButton(
                    onPressed: () => _navigateToReceipts(),
                    icon: const Icon(Icons.request_quote_rounded),
                    tooltip: _Constants.logoutTooltip,
                ),
            ],
        );
    }

    Widget _buildBody(HomeViewModel homeViewModel, AuthViewModel authViewModel) {
        return Padding(
            padding: const EdgeInsets.all(_Constants.defaultPadding),
            child: Column(
                children: [
                    _buildTableSelectionRow(homeViewModel, authViewModel),
                    if (homeViewModel.busy) _buildProgressIndicator(),
                    if (homeViewModel.error != null) _buildErrorMessage(homeViewModel.error!),
                    const SizedBox(height: _Constants.spacingMedium),
                    const _HelpCard(),
                    const SizedBox(height: _Constants.spacingMedium),
                    _OwnedTablesList(),
                ],
            ),
        );
    }

    Widget _buildTableSelectionRow(HomeViewModel homeViewModel, AuthViewModel authViewModel) {
        return Row(
            children: [
                Expanded(child: _buildTableNumberField()),
                const SizedBox(width: _Constants.spacingMedium),
                _buildOpenTableButton(homeViewModel, authViewModel),
            ],
        );
    }

    Widget _buildTableNumberField() {
        return TextField(
            controller: _tableController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: _Constants.tableNumberLabel,
                border: OutlineInputBorder(),
            ),
        );
    }

    Widget _buildOpenTableButton(HomeViewModel homeViewModel, AuthViewModel authViewModel) {
        return FilledButton.icon(
            onPressed: homeViewModel.busy ? null : () => _handleOpenTable(homeViewModel, authViewModel),
            icon: const Icon(Icons.table_bar),
            label: const Text(_Constants.openContinueLabel),
        );
    }

    Widget _buildProgressIndicator() {
        return const Padding(
            padding: EdgeInsets.only(top: _Constants.spacingLarge),
            child: LinearProgressIndicator(),
        );
    }

    Widget _buildErrorMessage(String error) {
        return Padding(
            padding: const EdgeInsets.only(top: _Constants.spacingSmall),
            child: Text(
                error,
                style: const TextStyle(color: Colors.red),
            ),
        );
    }

    Future<void> _handleLogout(AuthViewModel authViewModel) async {
        await authViewModel.logout();
        if (mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
        }
    }

    Future<void> _navigateToReceipts() async {
        if (mounted) {
            Navigator.of(context).pushReplacementNamed('/receipts');
          }
    }

    Future<void> _handleOpenTable(HomeViewModel homeViewModel, AuthViewModel authViewModel) async {
        final tableNumber = _parseTableNumber();
        if (tableNumber == null) {
            _showErrorSnackBar(_Constants.invalidTableMessage);
            return;
        }

        try {
            final order = await homeViewModel.openOrResumeTable(tableNumber);
            if (!mounted) return;

            if (!authViewModel.hasOrder(order.id)) {
                authViewModel.addOrder(order);
            }

            await context.read<PosViewModel>().init(order);
            await Navigator.of(context).pushNamed(PosView.route, arguments: order);
        } catch (e) {
            if (!mounted) return;
            _showErrorSnackBar('$e');
        }
    }

    int? _parseTableNumber() {
        return int.tryParse(_tableController.text.trim());
    }

    void _showErrorSnackBar(String message) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
        );
    }
}

class _HelpCard extends StatelessWidget {
    const _HelpCard();

    @override
    Widget build(BuildContext context) {
        return Card(
            child: Padding(
                padding: _Constants.cardPadding,
                child: Row(
                    children: const [
                        Icon(Icons.info_outline),
                        SizedBox(width: _Constants.spacingMedium),
                        Expanded(
                            child: Text(_Constants.helpText),
                        ),
                    ],
                ),
            ),
        );
    }
}

class _OwnedTablesList extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        final authViewModel = context.watch<AuthViewModel>();
        final orders = authViewModel.currentUser?.orders ?? [];

        if (orders.isEmpty) {
            return const Expanded(
                child: Center(
                    child: Text(
                        'Ingen aktive ordrer',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                        ),
                    ),
                ),
            );
        }

        return Expanded(
            child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) => _OrderTile(order: orders[index]),
            ),
        );
    }
}

class _OrderTile extends StatelessWidget {
    final dynamic order;
    
    const _OrderTile({required this.order});

    @override
    Widget build(BuildContext context) {
        return ListTile(
            title: Text('${_Constants.tableLabel}${order.tableNumber}'),
            subtitle: Text('${_Constants.orderIdLabel}${order.id}${_Constants.statusLabel}${order.status}'),
            onTap: () => _handleOrderTap(context),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusIcon(),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _handleDeleteOrder(context),
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

    Future<void> _handleOrderTap(BuildContext context) async {
        try {
            final homeViewModel = context.read<HomeViewModel>();
            final reopenedOrder = await homeViewModel.openOrResumeTable(order.tableNumber);
            
            if (!context.mounted) return;
            
            await context.read<PosViewModel>().init(reopenedOrder);
            await Navigator.of(context).pushNamed(PosView.route, arguments: reopenedOrder);
        } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${_Constants.errorOpeningOrder}$e')),
            );
        }
    }

    Future<void> _handleDeleteOrder(BuildContext context) async {
        try {
            final authViewModel = context.read<AuthViewModel>();
            authViewModel.removeOrder(order.id);
        } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${_Constants.errorOpeningOrder}$e')),
            );
        }
    }
}