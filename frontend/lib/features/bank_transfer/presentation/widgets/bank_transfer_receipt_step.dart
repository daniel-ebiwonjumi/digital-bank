import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/naira_formatter.dart';
import '../../data/models/bank_transfer_models.dart';

enum BankTransferReceiptVariant { processing, pending, success, unsuccessful }

/// Step 3: the receipt, in one of four states.
class BankTransferReceiptStep extends StatelessWidget {
  const BankTransferReceiptStep({
    super.key,
    required this.receipt,
    required this.variant,
    required this.onDone,
  });

  final BankTransferReceipt receipt;
  final BankTransferReceiptVariant variant;
  final VoidCallback onDone;

  Future<void> _copyReference(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: receipt.reference));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Reference copied')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = _styleFor(variant, theme.colorScheme);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 16),
        Icon(style.icon, size: 72, color: style.color),
        const SizedBox(height: 16),
        Text(
          style.title,
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        if (style.message != null) ...[
          const SizedBox(height: 8),
          Text(
            style.message!,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
        if (variant == BankTransferReceiptVariant.processing) ...[
          const SizedBox(height: 16),
          const LinearProgressIndicator(),
        ],
        const SizedBox(height: 16),
        Text(
          formatNaira(receipt.amountInNaira),
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          'to ${receipt.recipient.accountName}',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _ReceiptRow(
                  label: 'Reference',
                  value: receipt.reference,
                  trailing: IconButton(
                    tooltip: 'Copy reference',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () => _copyReference(context),
                  ),
                ),
                _ReceiptRow(
                  label: 'Bank',
                  value: receipt.recipient.bank.name,
                ),
                _ReceiptRow(
                  label: 'Account number',
                  value: receipt.recipient.accountNumber,
                ),
                if (receipt.narration.isNotEmpty)
                  _ReceiptRow(label: 'Narration', value: receipt.narration),
                _ReceiptRow(
                  label: 'Amount',
                  value: formatNaira(receipt.amountInNaira),
                ),
                _ReceiptRow(
                  label: 'Fee',
                  value: formatNaira(receipt.feeInNaira),
                ),
                _ReceiptRow(
                  label: 'Total',
                  value: formatNaira(receipt.totalInNaira),
                ),
                _ReceiptRow(
                  label: 'Date',
                  value: formatDateTime(receipt.createdAt),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(onPressed: onDone, child: const Text('Done')),
      ],
    );
  }
}

class _ReceiptStyle {
  const _ReceiptStyle({
    required this.icon,
    required this.color,
    required this.title,
    this.message,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? message;
}

_ReceiptStyle _styleFor(
  BankTransferReceiptVariant variant,
  ColorScheme colors,
) {
  return switch (variant) {
    BankTransferReceiptVariant.processing => _ReceiptStyle(
      icon: Icons.hourglass_top,
      color: colors.primary,
      title: 'Processing transfer',
      message: 'Please wait while we confirm with the bank.',
    ),
    BankTransferReceiptVariant.pending => const _ReceiptStyle(
      icon: Icons.schedule,
      color: Colors.orange,
      title: 'Transfer pending',
      message:
          'Your transfer is being processed. The final status will '
          'appear in your transaction history.',
    ),
    BankTransferReceiptVariant.success => const _ReceiptStyle(
      icon: Icons.check_circle,
      color: Colors.green,
      title: 'Transfer successful',
    ),
    BankTransferReceiptVariant.unsuccessful => _ReceiptStyle(
      icon: Icons.cancel,
      color: colors.error,
      title: 'Transfer unsuccessful',
      message:
          'The transfer could not be completed. Any money debited '
          'will be returned to your account.',
    ),
  };
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({required this.label, required this.value, this.trailing});

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
