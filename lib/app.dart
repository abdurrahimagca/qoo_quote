import 'package:flutter/material.dart';
import 'core/theme/theme.dart';
import 'routes.dart';
import 'utils/deep_link_handler.dart';

class QooQuoteApp extends StatefulWidget {
  const QooQuoteApp({super.key});

  @override
  State<QooQuoteApp> createState() => _QooQuoteAppState();
}

class _QooQuoteAppState extends State<QooQuoteApp> {
  @override
  void initState() {
    super.initState();
    _initializeDeepLinks();
  }

  Future<void> _initializeDeepLinks() async {
    await DeepLinkHandler.handleInitialLink(context);
    DeepLinkHandler.initDeepLinkListener(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qoo Quote',
      theme: appTheme,
      initialRoute: '/login-or-signup',
      routes: routes,
    );
  }
}
