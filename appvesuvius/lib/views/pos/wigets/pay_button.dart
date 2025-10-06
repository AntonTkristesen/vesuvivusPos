import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/pos_view_model.dart';
import '../pos_constants.dart';

class PayButton extends StatelessWidget {
    const PayButton();

    @override
    Widget build(BuildContext context) {
        final vm = context.watch<PosViewModel>();
        return _buildPayButton(context, vm);
    }

    Widget _buildPayButton(BuildContext context, PosViewModel vm) {
        return Padding(
            padding: PosConstants.tilePadding,
            child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(PosConstants.minButtonHeight),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(PosConstants.cardBorderRadius),
                    ),
                ),
                onPressed: () => _handlePayment(context, vm),
                icon: const Icon(Icons.check_circle),
                label: const Text(
                    PosConstants.payButtonLabel,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
            ),
        );
    }

    Future<void> _handlePayment(BuildContext context, PosViewModel vm) async {
        await vm.markPaid();
  
        if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(PosConstants.orderPaidMessage)),
            );
        }
    }
}