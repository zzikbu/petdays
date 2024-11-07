import 'package:flutter/material.dart';
import 'package:pet_log/palette.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsPolicyScreen extends StatefulWidget {
  final bool isTerms;

  const TermsPolicyScreen({
    super.key,
    required this.isTerms,
  });

  @override
  State<TermsPolicyScreen> createState() => _TermsPolicyScreenState();
}

class _TermsPolicyScreenState extends State<TermsPolicyScreen> {
  /// Properties
  late final WebViewController controller;

  bool isLoading = true;

  static const String _termsUri =
      'https://firebasestorage.googleapis.com/v0/b/petdays-38ca6.firebasestorage.app/o/app_documents%2Fterms.html?alt=media&token=b7090ead-2ee7-4e70-94c4-55f988101008';

  static const String _policyUri =
      'https://firebasestorage.googleapis.com/v0/b/petdays-38ca6.firebasestorage.app/o/app_documents%2Fpolicy.html?alt=media&token=788440b6-cbdf-4e1b-8131-437b9c12187c';

  /// Method
  void _initializeController() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
          onPageFinished: (_) {
            setState(() {
              isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.isTerms ? _termsUri : _policyUri));
  }

  /// LifeCycle
  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.white,
      appBar: AppBar(backgroundColor: Palette.white),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: isLoading == true ? null : 1,
            backgroundColor: Colors.transparent,
            color: isLoading == true ? Palette.subGreen : Colors.transparent,
          ),
          Expanded(
            child: WebViewWidget(controller: controller),
          ),
        ],
      ),
    );
  }
}
