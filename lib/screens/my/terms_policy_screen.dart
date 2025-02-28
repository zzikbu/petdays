import 'package:flutter/material.dart';
import 'package:petdays/palette.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../common/widgets/pd_app_bar.dart';

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
      'https://ivy-badge-8b0.notion.site/137adee28c6580ac9842d2a634635002?pvs=4';

  static const String _policyUri =
      'https://ivy-badge-8b0.notion.site/136adee28c65809f8d69e62e604adf23?pvs=4';

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
      appBar: const PDAppBar(backgroundColor: Palette.white),
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
