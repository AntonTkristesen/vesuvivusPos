import 'package:flutter/foundation.dart';
import '../data/repositories/receipt_repository.dart';
import '../models/receipt.dart';

class ReceiptViewModel extends ChangeNotifier {
  final ReceiptRepository repository;
  ReceiptViewModel(this.repository);

  bool _busy = false;
  Object? _error;
  List<Receipt> _receipts = [];

  bool get busy => _busy;
  Object? get error => _error;
  List<Receipt> get receipts => _receipts;

  Future<void> load() async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      _receipts = await repository.fetchReceipts();
    } catch (e) {
      _error = e;
      _receipts = [];
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
