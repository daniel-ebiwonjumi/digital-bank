import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Must equal the callback_url your backend sends to Paystack when it
/// initializes the transaction.
final paymentCallbackUri = Uri.parse(
  'https://yourapp.example.com/payment/callback',
);

bool _isCallback(Uri uri) {
  return uri.scheme == paymentCallbackUri.scheme &&
      uri.host == paymentCallbackUri.host &&
      uri.path == paymentCallbackUri.path;
}

/// Shows the hosted checkout. Pops itself when the callback URL is reached or
/// the user taps close. It never decides success; the bloc verifies afterwards.
class PaymentWebViewPage extends StatefulWidget {
  const PaymentWebViewPage({super.key, required this.checkoutUrl});

  final String checkoutUrl;

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;
  int _progress = 0;
  bool _hasError = false;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress);
          },
          onNavigationRequest: _onNavigationRequest,
          onWebResourceError: (error) {
            if ((error.isForMainFrame ?? true) && mounted) {
              setState(() => _hasError = true);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  NavigationDecision _onNavigationRequest(NavigationRequest request) {
    final uri = Uri.tryParse(request.url);
    if (uri == null) return NavigationDecision.prevent;

    if (_isCallback(uri)) {
      _close();
      return NavigationDecision.prevent;
    }

    // Only https pages (and about:blank, used internally by some checkouts).
    final isAllowed = uri.scheme == 'https' || request.url == 'about:blank';
    return isAllowed ? NavigationDecision.navigate : NavigationDecision.prevent;
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _progress = 0;
    });
    _controller.loadRequest(Uri.parse(widget.checkoutUrl));
  }

  void _close() {
    if (_closing || !mounted) return;
    _closing = true;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _close,
        ),
        bottom: _progress < 100 && !_hasError
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(value: _progress / 100),
              )
            : null,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_hasError) _CheckoutErrorView(onRetry: _retry),
        ],
      ),
    );
  }
}

class _CheckoutErrorView extends StatelessWidget {
  const _CheckoutErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 48),
              const SizedBox(height: 16),
              const Text(
                'We could not load the payment page.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}