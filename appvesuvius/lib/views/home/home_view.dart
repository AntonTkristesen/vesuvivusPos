import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/home_view_model.dart';
import '../../viewmodels/pos_view_model.dart';
import '../pos/pos_view.dart';
import '../../viewmodels/auth_view_model.dart';

class HomeView extends StatefulWidget {
    const HomeView({super.key});

    @override
    State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
    final _tableCtrl = TextEditingController();

    @override
    Widget build(BuildContext context) {
        final hv = context.watch<HomeViewModel>();
        final auth = context.watch<AuthViewModel>();

        return Scaffold(
            appBar: AppBar(
                title: const Text('Vesuvivus POS — Bord'),
                actions: [
                    IconButton(
                        onPressed: () async {
                            await auth.logout();
                            if (mounted) Navigator.of(context).pushReplacementNamed('/login');
                        },
                        icon: const Icon(Icons.logout),
                        tooltip: 'Log ud',
                    )
                ],
            ),
            body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    children: [
                        Row(
                            children: [
                                Expanded(
                                    child: TextField(
                                        controller: _tableCtrl,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                            labelText: 'Bordnummer',
                                            border: OutlineInputBorder(),
                                        ),
                                    ),
                                ),
                                const SizedBox(width: 12),
                                FilledButton.icon(
                                    onPressed: hv.busy
                                        ? null
                                        : () async {
                                            final t = int.tryParse(_tableCtrl.text.trim());
                                            if (t == null) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Indtast et gyldigt bordnummer'))
                                                );
                                                return;
                                            }
                                            try {
                                                final order = await hv.openOrResumeTable(t);
                                                if (!mounted) return;

                                                if (!auth.hasOrder(order.id)) {
                                                    auth.addOrder(order);
                                                }

                                                await context.read<PosViewModel>().init(order);
                                                await Navigator.of(context).pushNamed(PosView.route, arguments: order);
                                            } catch (e) {
                                                if (!mounted) return;
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('$e'))
                                                );
                                            }
                                        },
                                    icon: const Icon(Icons.table_bar),
                                    label: const Text('Åbn / Fortsæt'),
                                )
                            ],
                        ),
                        if (hv.busy)
                            const Padding(
                                padding: EdgeInsets.only(top: 24),
                                child: LinearProgressIndicator()
                            ),
                        if (hv.error != null)
                            Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(hv.error!, style: const TextStyle(color: Colors.red)),
                            ),
                        const SizedBox(height: 12),
                        const _HelpCard(),
                        const SizedBox(height: 12),
                        const _OwnedTablesList(),
                    ],
                ),
            ),
        );
    }
}

class _HelpCard extends StatelessWidget {
    const _HelpCard();

    @override
    Widget build(BuildContext context) {
        return Card(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                    children: const [
                        Icon(Icons.info_outline),
                        SizedBox(width: 12),
                        Expanded(
                            child: Text(
                                'Indtast et bordnummer and press "Åbn / Fortsæt". På næste skærm kan du tilføje menupunkter og markere ordren som betalt.'
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}

class _OwnedTablesList extends StatelessWidget {
    const _OwnedTablesList();

    @override
    Widget build(BuildContext context) {
        final user = context.watch<AuthViewModel>().currentUser;
        final hv = context.watch<HomeViewModel>();

        return Expanded(
            child: ListView.builder(
                itemCount: user?.orders?.length ?? 0,
                itemBuilder: (context, index) {
                    final order = user?.orders?[index];
                    return ListTile(
                        title: Text('Bord ${order?.tableNumber}'),
                        subtitle: Text('Ordre ID: ${order?.id} - Status: ${order?.status}'),
                        onTap: () async {
                            final o = await hv.openOrResumeTable(order?.tableNumber);
                            Navigator.of(context).pushNamed(PosView.route, arguments: o);
                        },
                    );
                },
            ),
        );
    }
}
