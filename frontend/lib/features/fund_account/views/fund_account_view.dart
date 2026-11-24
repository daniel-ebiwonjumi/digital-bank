import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/funding_models.dart';
import '../../data/repositories/add_money_repository.dart';
import '../bloc/add_money_bloc.dart';
import '../bloc/add_money_event.dart';
import '../bloc/add_money_state.dart';

/// Register this path in your router (nested under /add-money).
const addMoneyCheckoutRoute = '/add-money/checkout';

const _minimumNaira = 100;

/// Pops with `true` when the home screen should refresh its balance
/// (payment confirmed, or still pending).
class AddMoneyPage extends StatelessWidget {
  const AddMoneyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddMoneyBloc(
        repository: context.read<AddMoneyRepository>(),
      ),
      child: const _AddMoneyView(),
    );
  }
}

class _AddMoneyView extends StatefulWidget {
  const _AddMoneyView();

  @override
  State<_AddMoneyView> createState() => _AddMoneyViewState();
}

class _AddMoneyViewState extends State<_AddMoneyView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  FundingMethod _method = FundingMethod.card;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  /// Naira text to integer kobo. Money is never sent as a double.
  int? _parseKobo(String? text) {
    final naira = double.tryParse((text ?? '').replaceAll(',', '').trim());
    if (naira == null) return null;
    return (naira * 100).round();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AddMoneyBloc>().add(
          FundingSubmitted(
            amountInKobo: _parseKobo(_amountController.text)!,
            method: _method,
          ),
        );
  }

  Future<void> _handleState(BuildContext context, AddMoneyState state) async {
    final bloc = context.read<AddMoneyBloc>();

    switch (state) {
      case AddMoneyAwaitingPayment(:final session):
        await context.push<void>(
          addMoneyCheckoutRoute,
          extra: session.authorizationUrl,
        );
        if (!bloc.isClosed) bloc.add(const PaymentWindowClosed());
      case AddMoneySuccess():
        await _showResultDialog(
          context,
          title: 'Payment confirmed',
          message: 'Your wallet has been funded.',
        );
        if (context.mounted) context.pop(true);
      case AddMoneyPending():
        await _showResultDialog(
          context,
          title: 'Payment processing',
          message: 'We have not received confirmation yet. '
              'Your balance will update once the payment clears.',
        );
        if (context.mounted) context.pop(true);
      case AddMoneyFailure(:final message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      case AddMoneyInitial() || AddMoneyInitializing() || AddMoneyVerifying():
        break;
    }
  }

  Future<void> _showResultDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddMoneyBloc, AddMoneyState>(
      listener: _handleState,
      builder: (context, state) {
        final isInitializing = state is AddMoneyInitializing;
        final isVerifying = state is AddMoneyVerifying;

        return Scaffold(
          appBar: AppBar(title: const Text('Add money')),
          body: SafeArea(
            child: isVerifying
                ? const _VerifyingView()
                : Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        Text(
                          'Amount',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _amountController,
                          enabled: !isInitializing,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          decoration: const InputDecoration(
                            prefixText: '₦ ',
                            hintText: '0.00',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final kobo = _parseKobo(value);
                            if (kobo == null) return 'Enter an amount';
                            if (kobo < _minimumNaira * 100) {
                              return 'Minimum amount is ₦$_minimumNaira';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Payment method',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        for (final method in FundingMethod.values)
                          _MethodTile(
                            method: method,
                            selected: method == _method,
                            enabled: !isInitializing,
                            onTap: () => setState(() => _method = method),
                          ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: isInitializing ? null : _submit,
                          child: isInitializing
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Continue'),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.method,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final FundingMethod method;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? colors.primary : colors.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: ListTile(
        enabled: enabled,
        selected: selected,
        leading: Icon(
          method == FundingMethod.card
              ? Icons.credit_card
              : Icons.account_balance,
        ),
        title: Text(method.label),
        subtitle: Text(method.description),
        trailing: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _VerifyingView extends StatelessWidget {
  const _VerifyingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Confirming your payment…'),
        ],
      ),
    );
  }
}