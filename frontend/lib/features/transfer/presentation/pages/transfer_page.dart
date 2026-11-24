import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/transfer_repository.dart';
import '../bloc/transfer_bloc.dart';
import '../bloc/transfer_event.dart';
import '../bloc/transfer_state.dart';
import '../widgets/transaction_pin_sheet.dart';
import '../widgets/transfer_form_step.dart';
import '../widgets/transfer_review_step.dart';
import '../widgets/transfer_success_step.dart';

/// One route that hosts the whole flow (form, review, receipt).
///
/// Pops with `true` when the home screen should refresh its balance
/// (the transfer succeeded, or its outcome is unknown).
class TransferPage extends StatelessWidget {
  const TransferPage({super.key, this.availableBalanceInNaira});

  /// Used only for an early "insufficient balance" hint. The backend is the
  /// source of truth.
  final double? availableBalanceInNaira;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransferBloc(
        repository: context.read<TransferRepository>(),
      ),
      child: _TransferView(availableBalanceInNaira: availableBalanceInNaira),
    );
  }
}

class _TransferView extends StatefulWidget {
  const _TransferView({required this.availableBalanceInNaira});

  final double? availableBalanceInNaira;

  @override
  State<_TransferView> createState() => _TransferViewState();
}

class _TransferViewState extends State<_TransferView> {
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

  void _onAccountNumberChanged(String value) {
    context.read<TransferBloc>().add(RecipientAccountNumberChanged(value));
  }

  void _onContinue() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(
      _amountController.text.replaceAll(',', '').trim(),
    );
    if (amount == null) return;

    FocusScope.of(context).unfocus();
    context.read<TransferBloc>().add(
      TransferReviewRequested(
        amountInNaira: amount,
        narration: _narrationController.text,
      ),
    );
  }

  Future<void> _onConfirm() async {
    final bloc = context.read<TransferBloc>();

    final pin = await showTransactionPinSheet(context);
    if (pin == null || bloc.isClosed) return;

    bloc.add(TransferConfirmed(pin));
  }

  void _onEdit() {
    context.read<TransferBloc>().add(const TransferEditRequested());
  }

  void _handleBack(TransferState state) {
    switch (state) {
      case TransferSubmitting():
        break; // never leave while the request is in flight
      case TransferReviewing() || TransferFailed():
        _onEdit();
      case TransferSucceeded() || TransferOutcomeUnknown():
        context.pop(true); // balance may have changed
      case TransferInitial() ||
          TransferLookingUpRecipient() ||
          TransferRecipientLookupFailed() ||
          TransferRecipientResolved():
        context.pop();
    }
  }

  bool _isFormStep(TransferState state) => switch (state) {
    TransferInitial() ||
    TransferLookingUpRecipient() ||
    TransferRecipientLookupFailed() ||
    TransferRecipientResolved() => true,
    _ => false,
  };

  String _titleFor(TransferState state) => switch (state) {
    TransferReviewing() ||
    TransferSubmitting() ||
    TransferFailed() ||
    TransferOutcomeUnknown() => 'Confirm transfer',
    TransferSucceeded() => 'Receipt',
    _ => 'Transfer',
  };

  Widget _buildBody(TransferState state) {
    return switch (state) {
      TransferInitial() ||
      TransferLookingUpRecipient() ||
      TransferRecipientLookupFailed() ||
      TransferRecipientResolved() => TransferFormStep(
        formKey: _formKey,
        state: state,
        accountNumberController: _accountNumberController,
        amountController: _amountController,
        narrationController: _narrationController,
        availableBalanceInNaira: widget.availableBalanceInNaira,
        onAccountNumberChanged: _onAccountNumberChanged,
        onContinue: _onContinue,
      ),
      TransferReviewing(:final draft) => TransferReviewStep(
        draft: draft,
        onConfirm: _onConfirm,
        onEdit: _onEdit,
        onClose: () => context.pop(true),
      ),
      TransferSubmitting(:final draft) => TransferReviewStep(
        draft: draft,
        isSubmitting: true,
        onConfirm: _onConfirm,
        onEdit: _onEdit,
        onClose: () => context.pop(true),
      ),
      TransferFailed(:final draft, :final message) => TransferReviewStep(
        draft: draft,
        errorMessage: message,
        onConfirm: _onConfirm,
        onEdit: _onEdit,
        onClose: () => context.pop(true),
      ),
      TransferOutcomeUnknown(:final draft, :final message) =>
        TransferReviewStep(
          draft: draft,
          errorMessage: message,
          isOutcomeUnknown: true,
          onConfirm: _onConfirm,
          onEdit: _onEdit,
          onClose: () => context.pop(true),
        ),
      TransferSucceeded(:final receipt) => TransferSuccessStep(
        receipt: receipt,
        onDone: () => context.pop(true),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransferBloc, TransferState>(
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
              automaticallyImplyLeading: state is! TransferSucceeded,
            ),
            body: SafeArea(child: _buildBody(state)),
          ),
        );
      },
    );
  }
}
