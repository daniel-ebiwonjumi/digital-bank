import 'package:flutter/material.dart';

import '../../../../core/utils/naira_formatter.dart';
import '../../data/models/bank_transfer_models.dart';

/// Step 2: summary with the fee, any error, and the confirm button.
class BankTransferReviewStep extends StatelessWidget {
  const BankTransferReviewStep({
    super.key,
    required this.draft,
    required this.availableBalanceInNaira,
    required this.onConfirm,
    required this.onEdit,
    required this.onClose,
    this.isSubmitting = false,
    this.errorMessage,
    this.isOutcomeUnknown = false,
    this.requiresReview = false,
  });

  final BankTransferDraft draft;
  final double? availableBalanceInNaira;
  final VoidCallback onConfirm;
  final VoidCallback onEdit;
  final VoidCallback onClose;
  final bool isSubmitting;
  final String? errorMessage;
  final bool isOutcomeUnknown;

  /// The fee changed: the only way forward is to review the transfer again.
  final bool requiresReview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = errorMessage;
    final balance = availableBalanceInNaira;
    final isBalanceTooLow = balance != null && draft.totalInNaira > balance;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'You are sending',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          formatNaira(draft.amountInNaira),
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _SummaryRow(label: 'To', value: draft.recipient.accountName),
                _SummaryRow(label: 'Bank', value: draft.recipient.bank.name),
                _SummaryRow(
                  label: 'Account number',
                  value: draft.recipient.accountNumber,
                ),
                if (draft.narration.isNotEmpty)
                  _SummaryRow(label: 'Narration', value: draft.narration),
                const Divider(height: 24),
                _SummaryRow(
                  label: 'Amount',
                  value: formatNaira(draft.amountInNaira),
                ),
                _SummaryRow(
                  label: 'Fee',
                  value: formatNaira(draft.feeInNaira),
                ),
                _SummaryRow(
                  label: 'Total',
                  value: formatNaira(draft.totalInNaira),
                  emphasize: true,
                ),
              ],
            ),
          ),
        ),
        if (isBalanceTooLow && !isOutcomeUnknown) ...[
          const SizedBox(height: 12),
          Text(
            'Your balance is too low to cover the amount and the fee.',
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ],
        if (error != null) ...[
          const SizedBox(height: 16),
          _ErrorBanner(message: error, isOutcomeUnknown: isOutcomeUnknown),
        ],
        const SizedBox(height: 24),
        if (requiresReview)
          FilledButton(onPressed: onEdit, child: const Text('Review again'))
        else ...[
          FilledButton(
            onPressed: (isSubmitting || (isBalanceTooLow && !isOutcomeUnknown))
                ? null
                : onConfirm,
            child: isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(isOutcomeUnknown ? 'Try again' : 'Confirm transfer'),
          ),
          const SizedBox(height: 8),
          if (isOutcomeUnknown)
            OutlinedButton(onPressed: onClose, child: const Text('Close'))
          else
            TextButton(
              onPressed: isSubmitting ? null : onEdit,
              child: const Text('Edit details'),
            ),
        ],
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: emphasize ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.isOutcomeUnknown});

  final String message;
  final bool isOutcomeUnknown;

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(color: colors.onErrorContainer),
                  ),
                  if (isOutcomeUnknown) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Check your transaction history before starting a new '
                      'transfer. Trying again is safe and will not send the '
                      'money twice.',
                      style: TextStyle(color: colors.onErrorContainer),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
