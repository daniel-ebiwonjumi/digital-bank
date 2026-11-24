import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/naira_formatter.dart';
import '../../data/models/transfer_models.dart';

/// Step 3: the receipt.
class TransferSuccessStep extends StatelessWidget {
  const TransferSuccessStep({
    super.key,
    required this.receipt,
    required this.onDone,
  });

  final TransferReceipt receipt;
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

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 16),
        const Icon(Icons.check_circle, size: 72, color: Colors.green),
        const SizedBox(height: 16),
        Text(
          'Transfer successful',
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          formatNaira(receipt.amountInNaira),
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          'sent to ${receipt.recipient.accountName}',
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
                  label: 'Account number',
                  value: receipt.recipient.accountNumber,
                ),
                if (receipt.narration.isNotEmpty)
                  _ReceiptRow(label: 'Narration', value: receipt.narration),
                _ReceiptRow(
                  label: 'Date',
                  value: _formatDateTime(receipt.createdAt),
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

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// 24 Nov 2026, 3:42 PM
String _formatDateTime(DateTime date) {
  final hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour < 12 ? 'AM' : 'PM';
  return '${date.day} ${_months[date.month - 1]} ${date.year}, '
      '$hour12:$minute $period';
}
