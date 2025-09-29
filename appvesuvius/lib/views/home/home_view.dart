import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/home_view_model.dart';
import '../../viewmodels/pos_view_model.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../services/realtime_service.dart';
import 'home_constants.dart';
import 'widgets/help_card.dart';
import 'widgets/owned_tables_list.dart';

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
            appBar: _buildAppBar(homeViewModel, authViewModel),
            body: _buildBody(homeViewModel, authViewModel),
        );
    }

    AppBar _buildAppBar(HomeViewModel homeViewModel, AuthViewModel authViewModel) {
        return AppBar(
            title: const Text(HomeConstants.appTitle),
            actions: [
                IconButton(
                    onPressed: () => homeViewModel.logout(context, authViewModel),
                    icon: const Icon(Icons.logout),
                    tooltip: HomeConstants.logoutTooltip,
                ),
                IconButton(
                    onPressed: () => homeViewModel.navigateToReceipts(context),
                    icon: const Icon(Icons.request_quote_rounded),
                    tooltip: 'Kvitteringer',
                ),
            ],
        );
    }

    Widget _buildBody(HomeViewModel homeViewModel, AuthViewModel authViewModel) {
        return Padding(
            padding: const EdgeInsets.all(HomeConstants.defaultPadding),
            child: Column(
                children: [
                    _buildTableSelectionRow(homeViewModel, authViewModel),
                    if (homeViewModel.busy) _buildProgressIndicator(),
                    if (homeViewModel.error != null) _buildErrorMessage(homeViewModel.error!),
                    const SizedBox(height: HomeConstants.spacingMedium),
                    const HelpCard(),
                    const SizedBox(height: HomeConstants.spacingMedium),
                    const OwnedTablesList(),
                ],
            ),
        );
    }

    Widget _buildTableSelectionRow(HomeViewModel homeViewModel, AuthViewModel authViewModel) {
        return Row(
            children: [
                Expanded(child: _buildTableNumberField()),
                const SizedBox(width: HomeConstants.spacingMedium),
                _buildOpenTableButton(homeViewModel, authViewModel),
            ],
        );
    }

    Widget _buildTableNumberField() {
        return TextField(
            controller: _tableController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: HomeConstants.tableNumberLabel,
                border: OutlineInputBorder(),
            ),
        );
    }

    Widget _buildOpenTableButton(HomeViewModel homeViewModel, AuthViewModel authViewModel) {
        return FilledButton.icon(
            onPressed: homeViewModel.busy
                ? null
                : () {
                    final tableNumber = int.tryParse(_tableController.text.trim());
                    if (tableNumber == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text(HomeConstants.invalidTableMessage)),
                        );
                        return;
                    }
                    homeViewModel.handleOpenTable(
                        context,
                        tableNumber,
                        authViewModel,
                        context.read<PosViewModel>(),
                    );
                },
            icon: const Icon(Icons.table_bar),
            label: const Text(HomeConstants.openContinueLabel),
        );
    }

    Widget _buildProgressIndicator() {
        return const Padding(
            padding: EdgeInsets.only(top: HomeConstants.spacingLarge),
            child: LinearProgressIndicator(),
        );
    }

    Widget _buildErrorMessage(String error) {
        return Padding(
            padding: const EdgeInsets.only(top: HomeConstants.spacingSmall),
            child: Text(error, style: const TextStyle(color: Colors.red)),
        );
    }
}
