import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/funding_models.dart';
import '../../data/repositories/fund_account_repository.dart';
import '../bloc/fund_account_bloc.dart';
import '../bloc/fund_account_event.dart';
import '../bloc/fund_account_state.dart';

/// Register this path in your router (nested under /fund-account).
const fundAccountCheckoutRoute = '/fund-account/checkout';

/// 1000000 -> 1,000,000
String _formatNaira(double value) {
  return value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );
}

/// Pops with `true` when the home screen should refresh its balance
/// (payment confirmed, or still pending).
class FundAccountPage extends StatelessWidget {
  const FundAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FundAccountBloc(
        repository: context.read<FundAccountRepository>(),
      ),
      child: const _FundAccountView(),
    );
  }
}

class _FundAccountView extends StatefulWidget {
  const _FundAccountView();

  @override
  State<_FundAccountView> createState() => _FundAccountViewState();
}

class _FundAccountViewState extends State<_FundAccountView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  FundingMethod _method = FundingMethod.card;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  /// Parses the typed amount in naira. The input formatter already limits it
  /// to 2 decimal places.
  double? _parseNaira(String? text) {
    return double.tryParse((text ?? '').replaceAll(',', '').trim());
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<FundAccountBloc>().add(
          FundingSubmitted(
            amountInNaira: _parseNaira(_amountController.text)!,
            method: _method,
          ),
        );
  }

  Future<void> _handleState(
    BuildContext context,
    FundAccountState state,
  ) async {
    final bloc = context.read<FundAccountBloc>();

    switch (state) {
      case FundAccountAwaitingPayment(:final session):
        await context.push<void>(
          fundAccountCheckoutRoute,
          extra: session.authorizationUrl,
        );
        if (!bloc.isClosed) bloc.add(const PaymentWindowClosed());
      case FundAccountSuccess():
        await _showResultDialog(
          context,
          title: 'Payment confirmed',
          message: 'Your wallet has been funded.',
        );
        if (context.mounted) context.pop(true);
      case FundAccountPending():
        await _showResultDialog(
          context,
          title: 'Payment processing',
          message: 'We have not received confirmation yet. '
              'Your balance will update once the payment clears.',
        );
        if (context.mounted) context.pop(true);
      case FundAccountFailure(:final message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      case FundAccountInitial() ||
            FundAccountInitializing() ||
            FundAccountVerifying():
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
    return BlocConsumer<FundAccountBloc, FundAccountState>(
      listener: _handleState,
      builder: (context, state) {
        final isInitializing = state is FundAccountInitializing;
        final isVerifying = state is FundAccountVerifying;

        // The user must not leave while the payment is being confirmed.
        return PopScope(
          canPop: !isVerifying,
          child: Scaffold(
            appBar: AppBar(title: const Text('Fund account')),
            body: SafeArea(
              child: isVerifying
                  ? const _VerifyingView()
                  : Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
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
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ),
                              LengthLimitingTextInputFormatter(10),
                            ],
                            decoration: const InputDecoration(
                              prefixText: '₦ ',
                              hintText: '0.00',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              final naira = _parseNaira(value);
                              if (naira == null) return 'Enter an amount';
                              if (naira < FundingLimits.minimumNaira) {
                                return 'Minimum amount is '
                                    '₦${_formatNaira(FundingLimits.minimumNaira)}';
                              }
                              if (naira > FundingLimits.maximumNaira) {
                                return 'Maximum amount is '
                                    '₦${_formatNaira(FundingLimits.maximumNaira)}';
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