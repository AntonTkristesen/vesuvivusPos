import '../api/api_client.dart';
import '../../models/menu_item.dart';

class MenuRepository {
    final ApiClient _api;
    MenuRepository(this._api);

    Future<List<MenuItemModel>> fetchMenu() async {
        final data = await _api.get('menu');

        final list = (data['items'] as List).map((e) => MenuItemModel.fromJson(e)).toList();
        return list;
    }
}
