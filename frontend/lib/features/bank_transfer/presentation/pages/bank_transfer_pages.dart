import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// The PIN sheet is shared with the same-bank transfer feature.
import '../../../transfer/presentation/widgets/transaction_pin_sheet.dart';
import '../../data/models/bank_transfer_failure.dart';
import '../../data/models/bank_transfer_models.dart';
import '../../data/repositories/bank_transfer_repository.dart';
import '../bloc/bank_transfer_bloc.dart';
import '../bloc/bank_transfer_event.dart';
import '../bloc/bank_transfer_state.dart';
import '../widgets/bank_picker_sheet.dart';
import '../widgets/bank_transfer_form_step.dart';
import '../widgets/bank_transfer_receipt_step.dart';
import '../widgets/bank_transfer_review_step.dart';

/// One route that hosts the whole flow (form, review, receipt).
///
/// Pops with `true` when the home screen should refresh its balance (a
/// transfer was submitted, or its outcome is unknown).
class BankTransferPage extends StatelessWidget {
  const BankTransferPage({super.key, this.availableBalanceInNaira});

  /// Used only for early "insufficient balance" hints. The backend is the
  /// source of truth.
  final double? availableBalanceInNaira;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BankTransferBloc(
        repository: context.read<BankTransferRepository>(),
      )..add(const BanksRequested()),
      child: _BankTransferView(
        availableBalanceInNaira: availableBalanceInNaira,
      ),
    );
  }
}

class _BankTransferView extends StatefulWidget {
  const _BankTransferView({required this.availableBalanceInNaira});

  final double? availableBalanceInNaira;

  @override
  State<_BankTransferView> createState() => _BankTransferViewState();
}

class _BankTransferViewState extends State<_BankTransferView> {
  final _formKey = GlobalKey<FormState>();
  final _accountNumberController = TextEditingController();
  final _amountController = TextEditingController();
  final _narrationController = TextEditingController();

  @override
  void dispose() {
    _accountNumberController.dispose();
    _amountController.dispose();
    _narrationController.dispose();
    super.dispose();
  }

  Future<void> _onPickBank(BankTransferEditing state) async {
    final bloc = context.read<BankTransferBloc>();

    final bank = await showBankPickerSheet(
      context,
      banks: state.banks,
      selected: state.selectedBank,
    );
    if (bank == null || bloc.isClosed) return;

    bloc.add(BankSelected(bank));
  }

  void _onAccountNumberChanged(String value) {
    context.read<BankTransferBloc>().add(AccountNumberChanged(value));
  }

  void _onContinue() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(
      _amountController.text.replaceAll(',', '').trim(),
    );
    if (amount == null) return;

    FocusScope.of(context).unfocus();
    context.read<BankTransferBloc>().add(
      BankTransferReviewRequested(
        amountInNaira: amount,
        narration: _narrationController.text,
      ),
    );
  }

  Future<void> _onConfirm() async {
    final bloc = context.read<BankTransferBloc>();

    final pin = await showTransactionPinSheet(context);
    if (pin == null || bloc.isClosed) return;

    bloc.add(BankTransferConfirmed(pin));
  }

  void _onEdit() {
    context.read<BankTransferBloc>().add(const BankTransferEditRequested());
  }

  void _handleBack(BankTransferState state) {
    switch (state) {
      case BankTransferSubmitting():
        break; // never leave while the request is in flight
      case BankTransferReviewing() || BankTransferFailed():
        _onEdit();
      case BankTransferOutcomeUnknown() ||
          BankTransferProcessing() ||
          BankTransferPending() ||
          BankTransferSucceeded() ||
          BankTransferUnsuccessful():
        context.pop(true); // the balance may have changed
      case BankTransferLoadingBanks() ||
          BankTransferBanksFailed() ||
          BankTransferEditing():
        context.pop();
    }
  }

  bool _isFormStep(BankTransferState state) {
    return state is BankTransferLoadingBanks ||
        state is BankTransferBanksFailed ||
        state is BankTransferEditing;
  }

  bool _isReceipt(BankTransferState state) {
    return state is BankTransferProcessing ||
        state is BankTransferPending ||
        state is BankTransferSucceeded ||
        state is BankTransferUnsuccessful;
  }

  String _titleFor(BankTransferState state) {
    if (_isReceipt(state)) return 'Receipt';
    if (_isFormStep(state)) return 'Transfer to other banks';
    return 'Confirm transfer';
  }

  Widget _review(
    BankTransferDraft draft, {
    bool isSubmitting = false,
    String? errorMessage,
    bool isOutcomeUnknown = false,
    bool requiresReview = false,
  }) {
    return BankTransferReviewStep(
      draft: draft,
      availableBalanceInNaira: widget.availableBalanceInNaira,
      isSubmitting: isSubmitting,
      errorMessage: errorMessage,
      isOutcomeUnknown: isOutcomeUnknown,
      requiresReview: requiresReview,
      onConfirm: _onConfirm,
      onEdit: _onEdit,
      onClose: () => context.pop(true),
    );
  }

  Widget _receipt(
    BankTransferReceipt receipt,
    BankTransferReceiptVariant variant,
  ) {
    return BankTransferReceiptStep(
      receipt: receipt,
      variant: variant,
      onDone: () => context.pop(true),
    );
  }

  Widget _buildBody(BankTransferState state) {
    return switch (state) {
      BankTransferLoadingBanks() => const Center(
        child: CircularProgressIndicator(),
      ),
      BankTransferBanksFailed(:final message) => _BanksErrorView(
        message: message,
        onRetry: () {
          context.read<BankTransferBloc>().add(const BanksRequested());
        },
      ),
      BankTransferEditing editing => BankTransferFormStep(
        formKey: _formKey,
        state: editing,
        accountNumberController: _accountNumberController,
        amountController: _amountController,
        narrationController: _narrationController,
        availableBalanceInNaira: widget.availableBalanceInNaira,
        onPickBank: () => _onPickBank(editing),
        onAccountNumberChanged: _onAccountNumberChanged,
        onContinue: _onContinue,
      ),
      BankTransferReviewing(:final draft) => _review(draft),
      BankTransferSubmitting(:final draft) => _review(
        draft,
        isSubmitting: true,
      ),
      BankTransferFailed(:final draft, :final message, :final code) => _review(
        draft,
        errorMessage: message,
        requiresReview: code == BankTransferErrorCode.feeChanged,
      ),
      BankTransferOutcomeUnknown(:final draft, :final message) => _review(
        draft,
        errorMessage: message,
        isOutcomeUnknown: true,
      ),
      BankTransferProcessing(:final receipt) => _receipt(
        receipt,
        BankTransferReceiptVariant.processing,
      ),
      BankTransferPending(:final receipt) => _receipt(
        receipt,
        BankTransferReceiptVariant.pending,
      ),
      BankTransferSucceeded(:final receipt) => _receipt(
        receipt,
        BankTransferReceiptVariant.success,
      ),
      BankTransferUnsuccessful(:final receipt) => _receipt(
        receipt,
        BankTransferReceiptVariant.unsuccessful,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BankTransferBloc, BankTransferState>(
      builder: (context, state) {
        return PopScope(
          // Only the form step can be left directly. The other steps handle
          // back themselves (see _handleBack).
          canPop: _isFormStep(state),
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _handleBack(state);
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(_titleFor(state)),
              automaticallyImplyLeading: !_isReceipt(state),
            ),
            body: SafeArea(child: _buildBody(state)),
          ),
        );
      },
    );
  }
}

class _BanksErrorView extends StatelessWidget {
  const _BanksErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
