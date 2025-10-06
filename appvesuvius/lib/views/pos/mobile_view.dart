import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/pos_view_model.dart';
import 'pos_constants.dart';
import 'wigets/menu_list.dart';
import 'wigets/pay_button.dart';
import 'order_view.dart';

class MobileView extends StatefulWidget {
    const MobileView();

    @override
    State<MobileView> createState() => _MobileViewState();
}

class _MobileViewState extends State<MobileView> {
    int _selectedIndex = 0;

    @override
    Widget build(BuildContext context) {
        final vm = context.watch<PosViewModel>();

        return SafeArea(
            child: Column(
                children: [
                    Expanded(child: _buildContent()),
                    if (_shouldShowPayButton(vm)) const PayButton(),
                    _buildNavigationBar(),
                ],
            ),
        );
    }

    Widget _buildContent() {
        return IndexedStack(
            index: _selectedIndex,
            children: const [
                const MenuList(),
                const OrderView(),
            ],
        );
    }

    bool _shouldShowPayButton(PosViewModel vm) {
        return vm.order?.status != 'paid';
    }

    Widget _buildNavigationBar() {
        return NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            destinations: const [
                NavigationDestination(
                    icon: Icon(Icons.restaurant_menu),
                    label: PosConstants.menuTabLabel,
                ),
                NavigationDestination(
                    icon: Icon(Icons.receipt_long),
                    label: PosConstants.orderTabLabel,
                ),
            ],
        );
    }
}