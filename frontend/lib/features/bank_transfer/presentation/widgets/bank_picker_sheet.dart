import 'package:flutter/material.dart';

import '../../../data/models/bank_transfer_models.dart';

/// Lets the user search and pick a bank. Returns it, or null if dismissed.
Future<Bank?> showBankPickerSheet(
  BuildContext context, {
  required List<Bank> banks,
  Bank? selected,
}) {
  return showModalBottomSheet<Bank>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _BankPicker(banks: banks, selected: selected),
  );
}

class _BankPicker extends StatefulWidget {
  const _BankPicker({required this.banks, required this.selected});

  final List<Bank> banks;
  final Bank? selected;

  @override
  State<_BankPicker> createState() => _BankPickerState();
}

class _BankPickerState extends State<_BankPicker> {
  String _query = '';

  List<Bank> get _filtered {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return widget.banks;
    return widget.banks
        .where((bank) => bank.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final banks = _filtered;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: TextField(
                autocorrect: false,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Search bank',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Expanded(
              child: banks.isEmpty
                  ? const Center(child: Text('No bank found'))
                  : ListView.builder(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: banks.length,
                      itemBuilder: (context, index) {
                        final bank = banks[index];
                        final isSelected = bank == widget.selected;

                        return ListTile(
                          title: Text(bank.name),
                          trailing: isSelected ? const Icon(Icons.check) : null,
                          selected: isSelected,
                          onTap: () => Navigator.of(context).pop(bank),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
