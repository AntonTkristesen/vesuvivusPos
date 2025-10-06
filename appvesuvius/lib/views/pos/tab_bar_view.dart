import 'package:flutter/material.dart';
import '../../models/menu_item.dart';
import 'wigets/menu_tile.dart';

class CategoryTabBarView extends StatelessWidget {
    final List<String> categoryNames;
    final Map<String, List<MenuItemModel>> categories;
    final List<MenuItemModel> allItems;
    final String searchQuery;
    const CategoryTabBarView(
        this.categoryNames,
        this.categories,
        this.allItems,
        this.searchQuery,
    );

    @override
    Widget build(BuildContext context) {
        return _buildTabBarView(categoryNames, categories, allItems);
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
                        itemBuilder: (_, index) => MenuTile(item: filteredItems[index]),
                    );
                }).toList(),
            ),
        );
    }

    List<MenuItemModel> _filterItems(List<MenuItemModel> items) {
        if (searchQuery.isEmpty) return items;

        return items.where((item) {
            return item.name.toLowerCase().contains(searchQuery) ||
                item.category.toLowerCase().contains(searchQuery);
        }).toList();
    }
}