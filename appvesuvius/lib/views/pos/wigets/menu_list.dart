import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vesuvivus_pos/views/pos/wigets/tab_bar.dart';
import '../../../viewmodels/pos_view_model.dart';
import 'search_field.dart';
import '../tab_bar_view.dart';

class MenuList extends StatefulWidget {
    const MenuList();

    @override
    State<MenuList> createState() => _MenuListState();
}

class _MenuListState extends State<MenuList> {
    String _searchQuery = '';

    @override
    Widget build(BuildContext context) {
        final vm = context.watch<PosViewModel>();
        
        if (vm.loadingMenu) {
            return const Center(child: CircularProgressIndicator());
        }

        final categories = vm.organizeItemsByCategory(vm.items);
        final categoryNames = categories.keys.toList()..sort();

        return DefaultTabController(
            length: categoryNames.isEmpty ? 1 : categoryNames.length,
            child: Column(
                children: [
                    SearchField(onChanged: (value) {
                        setState(() {
                            _searchQuery = value;
                        });
                    }),
                    const CategoryTabBar(),
                    const Divider(height: 1),
                    Expanded(
                        child: vm.error != null
                            ? Center(child: Text('Fejl: ${vm.error}'))
                            : CategoryTabBarView(categoryNames, categories, vm.items, _searchQuery),
                    ),
                ],
            ),
        );
    }
}