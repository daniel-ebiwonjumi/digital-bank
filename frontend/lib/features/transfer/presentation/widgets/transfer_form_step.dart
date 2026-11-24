import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/naira_formatter.dart';
import '../../data/models/transfer_models.dart';
import '../bloc/transfer_state.dart';

/// Step 1: account number, recipient name, amount and narration.
class TransferFormStep extends StatelessWidget {
  const TransferFormStep({
    super.key,
    required this.formKey,
    required this.state,
    required this.accountNumberController,
    required this.amountController,
    required this.narrationController,
    required this.availableBalanceInNaira,
    required this.onAccountNumberChanged,
    required this.onContinue,
  });

  final GlobalKey<FormState> formKey;
  final TransferState state;
  final TextEditingController accountNumberController;
  final TextEditingController amountController;
  final TextEditingController narrationController;
  final double? availableBalanceInNaira;
  final ValueChanged<String> onAccountNumberChanged;
  final VoidCallback onContinue;

  String? _validateAmount(String? value) {
    final naira = double.tryParse((value ?? '').replaceAll(',', '').trim());
    if (naira == null) return 'Enter an amount';
    if (naira < TransferRules.minimumNaira) {
      return 'Minimum amount is '
          '${formatNaira(TransferRules.minimumNaira, decimals: 0)}';
    }
    if (naira > TransferRules.maximumNaira) {
      return 'Maximum amount is '
          '${formatNaira(TransferRules.maximumNaira, decimals: 0)}';
    }
    final balance = availableBalanceInNaira;
    if (balance != null && naira > balance) return 'Insufficient balance';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isResolved = state is TransferRecipientResolved;
    final isLookingUp = state is TransferLookingUpRecipient;
    final balance = availableBalanceInNaira;

    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (balance != null) ...[
            Text(
              'Available balance: ${formatNaira(balance)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: accountNumberController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            maxLength: TransferRules.accountNumberLength,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              labelText: 'Account number',
              border: const OutlineInputBorder(),
              counterText: '',
              suffixIcon: isLookingUp
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
            onChanged: onAccountNumberChanged,
            validator: (value) {
              return TransferRules.isValidAccountNumber(value ?? '')
                  ? null
                  : 'Enter a ${TransferRules.accountNumberLength}-digit '
                        'account number';
            },
          ),
          _RecipientStatus(state: state),
          const SizedBox(height: 20),
          TextFormField(
            controller: amountController,
            enabled: isResolved,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: '₦ ',
              hintText: '0.00',
              border: OutlineInputBorder(),
            ),
            validator: _validateAmount,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: narrationController,
            enabled: isResolved,
            maxLength: TransferRules.maxNarrationLength,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              if (isResolved) onContinue();
            },
            decoration: const InputDecoration(
              labelText: 'Narration (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: isResolved ? onContinue : null,
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

class _RecipientStatus extends StatelessWidget {
  const _RecipientStatus({required this.state});

  final TransferState state;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final child = switch (state) {
      TransferLookingUpRecipient() => const Row(
        children: [
          SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text('Checking account…'),
        ],
      ),
      TransferRecipientLookupFailed(:final message) => Text(
        message,
        style: TextStyle(color: colors.error),
      ),
      TransferRecipientResolved(:final recipient) => Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(recipient.accountName),
          subtitle: const Text('Account found'),
        ),
      ),
      _ => const SizedBox.shrink(),
    };

    // liveRegion makes screen readers announce the result of the lookup.
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Semantics(liveRegion: true, child: child),
    );
  }
}
