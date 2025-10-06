import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/pos_view_model.dart';

class CategoryTabBar extends StatelessWidget {
    const CategoryTabBar({super.key});

    @override
    Widget build(BuildContext context) {
        final vm = context.watch<PosViewModel>();
        if (vm.loadingMenu) {
            return const Center(child: CircularProgressIndicator());
        }

        final categories = vm.organizeItemsByCategory(vm.items);
        final categoryNames = categories.keys.map(vm.mapCategoryName).toList()..sort();
        return buildTabBar(categoryNames);
    }

    Widget buildTabBar(List<String> categoryNames) {
        return Material(
            color: Colors.transparent,
            child: TabBar(
                isScrollable: true,
                tabs: (categoryNames.isEmpty ? ['All'] : categoryNames)
                    .map((category) => Tab(text: category))
                    .toList(),
            ),
        );
    }
}
