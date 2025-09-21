import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/receipt_view_model.dart';

class ReceiptView extends StatefulWidget {
  static const route = '/receipts';
  const ReceiptView({super.key});

  @override
  State<ReceiptView> createState() => _ReceiptViewState();
}

class _ReceiptViewState extends State<ReceiptView> {

  @override
  void initState() {
    super.initState();
    // Like your HomeView: call into VM on init
    // It's safe to use context.read<> in initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ReceiptViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReceiptViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kvitteringer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
        ),
      ),
      body: Builder(
        builder: (_) {
          if (vm.busy) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.error != null) {
            return _ErrorBox(message: vm.error.toString());
          }
          if (vm.receipts.isEmpty) {
            return const _EmptyState();
          }
          return ListView.separated(
            itemCount: vm.receipts.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (_, i) {
              final r = vm.receipts[i];
              return ListTile(
                title: Text('Receipt #${r.id} • Order ${r.orderId}'),
                subtitle: Text(
                  'Dato: ${_formatDate(r.date)}\n'
                  'Varer: ${r.items.join(", ")}',
                ),
                isThreeLine: true,
                trailing: Text(
                  _formatTotal(r.total),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 32),
            const SizedBox(height: 8),
            const Text('Kunne ikke hente kvitteringer.'),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Ingen kvitteringer fundet',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}

String _formatDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
String _formatTotal(double t) => 'DKK ${t.toStringAsFixed(2)}';
