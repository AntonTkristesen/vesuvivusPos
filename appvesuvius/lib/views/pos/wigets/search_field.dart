import 'package:flutter/material.dart';
import '../pos_constants.dart';

class SearchField extends StatelessWidget {
    final ValueChanged<String>? onChanged;

    const SearchField({Key? key, this.onChanged}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: PosConstants.defaultPadding,
            child: TextField(
                decoration: InputDecoration(
                    hintText: PosConstants.searchHint,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(PosConstants.cardBorderRadius),
                    ),
                    contentPadding: PosConstants.tilePadding,
                ),
                onChanged: (value) => onChanged?.call(value.toLowerCase()),
            ),
        );
    }
}