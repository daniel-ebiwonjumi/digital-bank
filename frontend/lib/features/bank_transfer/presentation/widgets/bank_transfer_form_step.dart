import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/naira_formatter.dart';
import '../../data/models/bank_transfer_models.dart';
import '../bloc/bank_transfer_state.dart';

/// Step 1: bank, account number, recipient name, amount and narration.
class BankTransferFormStep extends StatelessWidget {
  const BankTransferFormStep({
    super.key,
    required this.formKey,
    required this.state,
    required this.accountNumberController,
    required this.amountController,
    required this.narrationController,
    required this.availableBalanceInNaira,
    required this.onPickBank,
    required this.onAccountNumberChanged,
    required this.onContinue,
  });

  final GlobalKey<FormState> formKey;
  final BankTransferEditing state;
  final TextEditingController accountNumberController;
  final TextEditingController amountController;
  final TextEditingController narrationController;
  final double? availableBalanceInNaira;
  final VoidCallback onPickBank;
  final ValueChanged<String> onAccountNumberChanged;
  final VoidCallback onContinue;

  String? _validateAmount(String? value) {
    final naira = double.tryParse((value ?? '').replaceAll(',', '').trim());
    if (naira == null) return 'Enter an amount';
    if (naira < BankTransferRules.minimumNaira) {
      return 'Minimum amount is '
          '${formatNaira(BankTransferRules.minimumNaira, decimals: 0)}';
    }
    if (naira > BankTransferRules.maximumNaira) {
      return 'Maximum amount is '
          '${formatNaira(BankTransferRules.maximumNaira, decimals: 0)}';
    }
    final balance = availableBalanceInNaira;
    if (balance != null && naira > balance) return 'Insufficient balance';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final balance = availableBalanceInNaira;
    final canEnterAmount =
        state.lookupStatus == RecipientLookupStatus.resolved &&
        !state.isQuoting;
    final errorMessage = state.errorMessage;

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
          InkWell(
            onTap: state.isQuoting ? null : onPickBank,
            borderRadius: BorderRadius.circular(4),
            child: InputDecorator(
              isEmpty: state.selectedBank == null,
              decoration: const InputDecoration(
                labelText: 'Bank',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
              child: Text(state.selectedBank?.name ?? ''),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: accountNumberController,
            enabled: !state.isQuoting,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            maxLength: BankTransferRules.accountNumberLength,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              labelText: 'Account number',
              border: const OutlineInputBorder(),
              counterText: '',
              suffixIcon: state.lookupStatus == RecipientLookupStatus.loading
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
              return BankTransferRules.isValidAccountNumber(value ?? '')
                  ? null
                  : 'Enter a ${BankTransferRules.accountNumberLength}-digit '
                        'account number';
            },
          ),
          _RecipientStatus(state: state),
          const SizedBox(height: 20),
          TextFormField(
            controller: amountController,
            enabled: canEnterAmount,
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
            enabled: canEnterAmount,
            maxLength: BankTransferRules.maxNarrationLength,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              if (state.canContinue) onContinue();
            },
            decoration: const InputDecoration(
              labelText: 'Narration (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 8),
            _ErrorBanner(message: errorMessage),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: state.canContinue ? onContinue : null,
            child: state.isQuoting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

class _RecipientStatus extends StatelessWidget {
  const _RecipientStatus({required this.state});

  final BankTransferEditing state;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final recipient = state.recipient;

    final child = switch (state.lookupStatus) {
      RecipientLookupStatus.loading => const Row(
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
      RecipientLookupStatus.failed => Text(
        state.lookupMessage ?? 'We could not verify this account.',
        style: TextStyle(color: colors.error),
      ),
      RecipientLookupStatus.resolved =>
        recipient == null
            ? const SizedBox.shrink()
            : Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(recipient.accountName),
                  subtitle: Text(recipient.bank.name),
                ),
              ),
      RecipientLookupStatus.idle =>
        state.selectedBank == null &&
                BankTransferRules.isValidAccountNumber(state.accountNumber)
            ? const Text('Select a bank to verify this account.')
            : const SizedBox.shrink(),
    };

    // liveRegion makes screen readers announce the result of the lookup.
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Semantics(liveRegion: true, child: child),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: colors.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colors.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
