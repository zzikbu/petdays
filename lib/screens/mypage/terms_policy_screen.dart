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
      'https://firebasestorage.googleapis.com/v0/b/petlog-6e23a.appspot.com/o/app_privacy_rule%2Fterms.html?alt=media&token=25e1494e-9ace-4caf-a1aa-979ca3887545';

  static const String _policyUri =
      'https://firebasestorage.googleapis.com/v0/b/petlog-6e23a.appspot.com/o/app_privacy_rule%2Fpolicy.html?alt=media&token=6b401804-d623-45a2-ab96-5f2c6de58687';

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
