import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/models/transfer_models.dart';

/// Asks for the transaction PIN. Returns it, or null if dismissed.
/// The PIN lives only in this sheet's text field and is never stored.
Future<String?> showTransactionPinSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _PinSheet(),
  );
}

class _PinSheet extends StatefulWidget {
  const _PinSheet();

  @override
  State<_PinSheet> createState() => _PinSheetState();
}

class _PinSheetState extends State<_PinSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isComplete => TransferRules.isValidPin(_controller.text);

  void _submit() {
    if (!_isComplete) return;
    Navigator.of(context).pop(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Enter your transaction PIN',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: TransferRules.pinLength,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: Theme.of(context).textTheme.headlineSmall,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              counterText: '',
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isComplete ? _submit : null,
              child: const Text('Confirm'),
            ),
          ),
        ],
      ),
    );
  }
}
