import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Must equal the callback_url your backend sends to Paystack when it
/// initializes the transaction.
const paymentCallbackUrl = 'https://yourapp.example.com/payment/callback';

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
                                                                                        onNavigationRequest: (request) {
                                                                                                    if (request.url.startsWith(paymentCallbackUrl)) {
                                                                                                                  _close();
                                                                                                                                return NavigationDecision.prevent;
                                                                                                                                            }
                                                                                                                                                        return NavigationDecision.navigate;
                                                                                                                                                                  },
                                                                                                                                                                          ),
                                                                                                                                                                                )
                                                                                                                                                                                      ..loadRequest(Uri.parse(widget.checkoutUrl));
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
                                                                                                                                                                                                                                                                          bottom: _progress < 100
                                                                                                                                                                                                                                                                                      ? PreferredSize(
                                                                                                                                                                                                                                                                                                      preferredSize: const Size.fromHeight(2),
                                                                                                                                                                                                                                                                                                                      child: LinearProgressIndicator(value: _progress / 100),
                                                                                                                                                                                                                                                                                                                                    )
                                                                                                                                                                                                                                                                                                                                                : null,
                                                                                                                                                                                                                                                                                                                                                      ),
                                                                                                                                                                                                                                                                                                                                                            body: WebViewWidget(controller: _controller),
                                                                                                                                                                                                                                                                                                                                                                );
                                                                                                                                                                                                                                                                                                                                                                  }
                                                                                                                                                                                                                                                                                                                                                                  }