import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/menu_item.dart';
import '../../../viewmodels/pos_view_model.dart';
import '../../../views/pos/pos_constants.dart';

class MenuTile extends StatelessWidget {
    final MenuItemModel item;

    const MenuTile({required this.item, super.key});

    @override
    Widget build(BuildContext context) {
        final vm = context.watch<PosViewModel>();
        final isOrderPaid = vm.order?.status == 'paid';

        return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PosConstants.cardBorderRadius),
            ),
            child: InkWell(
                borderRadius: BorderRadius.circular(PosConstants.cardBorderRadius),
                onTap: isOrderPaid ? null : () => _addItemToOrder(context, vm),
                child: Padding(
                    padding: PosConstants.tilePadding,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Expanded(
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        Text(
                                            item.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16,
                                                color: Colors.black87
                                            ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                            '${vm.mapCategoryName(item.category)} • ${item.price.toStringAsFixed(2)}',
                                            style: const TextStyle(color: Colors.black54),
                                        ),
                                    ],
                                ),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }

    Future<void> _addItemToOrder(BuildContext context, PosViewModel vm) async {
        await vm.add(item);

        if (context.mounted) {
            final overlay = Overlay.of(context);
            final overlayEntry = OverlayEntry(
                builder: (context) => Positioned(
                    top: 20,
                    right: 20,
                    child: Material(
                        color: Colors.transparent,
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                                '${item.name} tilføjet',
                                style: const TextStyle(color: Colors.white),
                            ),
                        ),
                    ),
                ),
            );

            overlay.insert(overlayEntry);
            await Future.delayed(const Duration(seconds: 2));
            overlayEntry.remove();
        }
    }
}
