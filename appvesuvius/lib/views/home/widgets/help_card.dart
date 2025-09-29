import 'package:flutter/material.dart';
import '../home_constants.dart';

class HelpCard extends StatelessWidget {
    const HelpCard({super.key});

    @override
    Widget build(BuildContext context) {
        return Card(
            child: Padding(
                padding: HomeConstants.cardPadding,
                child: Row(
                    children: const [
                        Icon(Icons.info_outline),
                        SizedBox(width: HomeConstants.spacingMedium),
                        Expanded(child: Text(HomeConstants.helpText)),
                    ],
                ),
            ),
        );
    }
}
