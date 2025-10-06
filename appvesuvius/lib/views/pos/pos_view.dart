import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../viewmodels/pos_view_model.dart';
import 'pos_constants.dart';
import 'wigets/menu_list.dart';
import 'order_view.dart';
import 'mobile_view.dart';

class PosView extends StatelessWidget {
    static const route = '/pos';
    
    const PosView({super.key});

    @override
    Widget build(BuildContext context) {
        final OrderModel routeOrder = _getRouteOrder(context);
        final bool isWideScreen = _isWideScreen(context);

        return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: _buildAppBar(routeOrder),
            body: isWideScreen ? _buildWideLayout() : const MobileView(),
        );
    }

    OrderModel _getRouteOrder(BuildContext context) {
        return (ModalRoute.of(context)?.settings.arguments) as OrderModel? ??
            context.watch<PosViewModel>().order!;
    }

    bool _isWideScreen(BuildContext context) {
        return MediaQuery.of(context).size.width > PosConstants.wideScreenBreakpoint;
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
                Expanded(flex: 3, child: MenuList()),
                VerticalDivider(width: 1),
                Expanded(flex: 2, child: const OrderView()),
            ],
        );
    }
}