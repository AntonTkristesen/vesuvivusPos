import 'package:vesuvivus_pos/models/receipt.dart';

import '../api/api_client.dart';

class ReceiptRepository {
    final ApiClient _api;
    ReceiptRepository(this._api);
    Future<List<Receipt>> fetchReceipts() async {
        final data = await _api.get('receipts');
        print(data);
        final list = (data['receipts'] as List).map((e) => Receipt.fromJson(e)).toList();
        return list;
    }
}
